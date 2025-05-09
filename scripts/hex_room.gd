
extends Node3D
class_name HexRoom

@export var wall_scene : PackedScene
@export var full_collision_scene : PackedScene
@export var exit_collision_scene : PackedScene
@export var corridor_scene : PackedScene
@export var guillotine_scene : PackedScene
@export var coin_scene : PackedScene
@export var potion_scene : PackedScene

@export var materials : Array[Material]
@export var object_scenes : Dictionary[CellData.ObjectType, PackedScene]

#@onready var entrance_detector : Area3D = $EntranceDetector

var room_data : CellData
var material_index : int = 0

var room_size : float

signal entered(coords : Vector3i)
signal item_picked(item_type : CellData.ObjectType)

func initialize(data : CellData):
	room_data = data
	position = room_data.position

	if room_data.type == room_data.Type.NORMAL:
		room_size = Globals.HEX_SIZE
	else:
		room_size = Globals.SMALL_HEX_SIZE

	material_index = randi_range(0, 4)

	if !room_data.has_been_instantiated:
		room_data.has_been_instantiated = true
		define_guillotines()
		define_objects()
		define_subtype()
		
	if room_data.subtype == CellData.SubType.HOLE:
		add_ceiling_light()
	elif room_data.subtype == CellData.SubType.HIGH:
		var extension : MeshInstance3D = MeshInstance3D.new()
		extension.layers = 2
		extension.mesh = load("res://meshes/hexes/extension.res")
		extension.scale = Vector3(0.5, 1.0, 0.5)
		extension.material_override = materials[material_index]
		extension.position.y = 2.0
		add_child(extension)

		$Ceiling.position.y += 2.0

	elif room_data.subtype == CellData.SubType.DOME:
		$Ceiling.mesh = load("res://meshes/hexes/dome.res")
		$Ceiling.material_override = materials[material_index]
	

	place_walls()	
	place_collisions()
	place_corridors()
	place_guillotines()
	place_objects()
	


func _ready() -> void:
	$Body.set_surface_override_material(0, materials[material_index])
	item_picked.connect(Globals.player._on_item_picked)

func add_ceiling_light():
	$Ceiling.mesh = load("res://meshes/ceiling_hole.res")
	var light : OmniLight3D = OmniLight3D.new()
	$Floor.layers = 1
	light.position = Vector3.UP * 3
	light.light_energy = 0.6
	light.omni_range = 7
	light.omni_attenuation = 1.5

	add_child(light)

func place_walls() -> void:	
	for i in 6:
		if 1 << i & room_data.layout == 0:
			var wall : Wall = wall_scene.instantiate()
			wall.rotation_degrees = Vector3(0, i * -60, 0)
			var direction = Vector3.FORWARD.rotated(Vector3.UP, wall.rotation.y)
			wall.position = direction * (Globals.SQRT3 * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
			wall.material = materials[material_index]
			add_child(wall)


func place_collisions() -> void:
	for i in 6:
		var static_body : StaticBody3D
		if 1 << i & room_data.layout > 0:
			static_body = exit_collision_scene.instantiate()
		
		else:
			static_body = full_collision_scene.instantiate()

		static_body.rotation_degrees = Vector3(0, i * -60, 0)
		var direction = Vector3.FORWARD.rotated(Vector3.UP, static_body.rotation.y)
		static_body.position = direction * (Globals.SQRT3 * room_size * 0.5 - Globals.WALL_WIDTH * 0.5) + Vector3.UP * (Globals.HEX_HEIGHT - 0.5) * 0.5

		add_child(static_body)

func define_subtype():
	if room_data.subtype == CellData.SubType.HOLE or room_data.type == CellData.Type.SMALL:
		return
	var roll : float = randf()
	if roll < 0.1:
		room_data.subtype = CellData.SubType.DOME
	elif roll < 0.3:
		room_data.subtype = CellData.SubType.HIGH



func place_corridors() -> void:
	var corridor_index : int = 0
	for i in room_data.corridors.size():
		if room_data.corridors[i] != 0:
			var neighbour : Vector3i = room_data.coords + Globals.directions[i]
			var corridor_type : CorridorSlope.Type = Globals.maze[room_data.coords].corridors[i]
			var offset : int = 0
			
			if corridor_type == CorridorSlope.Type.SEMI_LONG_PLUS:
				offset = 1
			elif corridor_type == CorridorSlope.Type.SEMI_LONG_MINUS:
				offset = -1


			var corridor : CorridorSlope = corridor_scene.instantiate()
			corridor.initialize(corridor_index, position.y, Globals.maze[neighbour].position.y, corridor_type)
	
			corridor.rotation.y = i * -PI / 3
			var direction = Vector3.FORWARD.rotated(Vector3.UP, corridor.rotation.y)
			corridor.position = offset * direction * Globals.SQRT3 * (Globals.HEX_SIZE - Globals.SMALL_HEX_SIZE) * 0.25 + direction * (Globals.SQRT3 * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.5) - Vector3.UP * position.y

			corridor.coin_picked.connect(_on_corridor_coin_picked)

			$Corridors.add_child(corridor)
			corridor_index += 1

func define_guillotines():
	var corridor_index : int = 0
	for i in 6:
		if room_data.corridors[i] != 0:
			if randf() < 0.25:
				room_data.guillotines[i] = Vector2i(corridor_index, randi_range(0, 10))
			else:
				room_data.guillotines[i] = Vector2i(-1, -1)
			corridor_index += 1
		else:
			room_data.guillotines[i] = Vector2i(-1, -1)

func place_guillotines():
	for i in room_data.guillotines.keys():
		var guillotine_data : Vector2i = room_data.guillotines[i]
		if guillotine_data != Vector2i(-1, -1):
			var guillotine : Node3D = guillotine_scene.instantiate()
			guillotine.rotation = Vector3(0, i * -PI / 3, 0)
			var direction = Vector3.FORWARD.rotated(Vector3.UP, guillotine.rotation.y)
			var corridor : CorridorSlope = $Corridors.get_child(guillotine_data.x)
			guillotine.position = direction * (Globals.SQRT3 * room_size * 0.5 + corridor.length * guillotine_data.y * 0.1) + Vector3.UP * corridor.length * guillotine_data.y * 0.1 * tan(corridor.slope_angle) 
			add_child(guillotine)



func define_objects():
	var coin_count : int = randi_range(0, 5)
	var max_offset : int = 10
	if room_data.type == room_data.Type.SMALL:
		coin_count = randi_range(0, 3)
		max_offset = 5

	var angle_increment : float = TAU / coin_count
	var radius : float = room_size - 1.25 - 0.1 * randi_range(0, max_offset)

	for i in coin_count:
		var pos : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, angle_increment * i) * radius + Vector3.UP * 0.4
		var obj_type : CellData.ObjectType
		if randf() < 0.5:
			obj_type = CellData.ObjectType.COIN
		else:
			if randf() < 0.5:
				obj_type = CellData.ObjectType.HEALTH_POTION
			else:
				obj_type = CellData.ObjectType.STAMINA_POTION

		room_data.objects[obj_type].append(pos)


	#define_corridor_coins()


func define_corridor_coins():
	var corridor_idx : int = 0
	for i in room_data.corridors.size():
		if room_data.corridors[i]:	
			var coin_count : int = randi_range(0, 4)
			var arr : PackedInt32Array = []
			room_data.corridor_coins.append(arr)
			for j in coin_count:
				room_data.corridor_coins[corridor_idx].append(1)
			corridor_idx += 1

func place_objects():
	for obj_type in room_data.objects.keys():
		if room_data.objects[obj_type].size() == 0:
			continue
		for i in room_data.objects[obj_type].size():
			if room_data.objects[obj_type][i] == Vector3(999, 999, 999):
				continue
			var obj : PickableObject = object_scenes[obj_type].instantiate()
			obj.type = obj_type
			obj.position = room_data.objects[obj_type][i]

			obj.picked.connect(_on_object_picked)

			$Coins.add_child(obj)




func toggle_visibility(visibility : bool):
	$Body.visible = visibility
	$Floor.visible = visibility
	$Ceiling.visible = visibility
	$Coins.visible = visibility
	for corridor : CorridorSlope in $Corridors.get_children():
		corridor.visible = visibility


func _on_object_picked(idx : int, object_type : CellData.ObjectType):
	room_data.objects[object_type][idx] = Vector3(999, 999, 999)
	item_picked.emit(object_type)

func _on_corridor_coin_picked(idx : int, corridor_idx : int):
	room_data.corridor_coins[corridor_idx][idx] = -1

func _on_entrance_detector_body_entered(body:Node3D) -> void:
	if body is Player and body.current_room != room_data.coords:
		entered.emit(room_data.coords)
	elif body is Enemy:
		body.current_room = room_data.coords
		body.is_in_instantiated_room = true
