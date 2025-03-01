extends Node3D
class_name HexRoom

@export var wall_scene : PackedScene
@export var full_collision_scene : PackedScene
@export var exit_collision_scene : PackedScene
@export var corridor_scene : PackedScene
@export var guillotine_scene : PackedScene
@export var coin_scene : PackedScene

@export var materials : Array[Material]

@onready var entrance_detector : Area3D = $EntranceDetector

var room_data : CellData
var material_index : int = 0

var room_size : float

signal entered(coords : Vector3i)

func initialize(data : CellData):
	room_data = data
	position = room_data.position

	if room_data.type == room_data.Type.NORMAL:
		room_size = Globals.HEX_SIZE
	else:
		room_size = Globals.SMALL_HEX_SIZE

	material_index = randi_range(0, 4)
	
	var exits : Array [int] = [Globals.N, Globals.NE, Globals.SE, Globals.S, Globals.SW, Globals.NW]
	
	if room_data.has_hole:
		add_ceiling_light()


	if room_data.exits.size() == 0:
		for i in exits.size():
			room_data.exits.append(room_data.layout & exits[i] > 0)
		define_corridors()
		define_guillotines()
		define_coins()
		


	place_walls()	
	place_collisions()
	place_corridors()
	place_guillotines()
	place_coins()
	


func _ready() -> void:
	$Body.set_surface_override_material(0, materials[material_index])


func add_ceiling_light():
	$Ceiling.mesh = load("res://meshes/ceiling_hole.res")
	var light : OmniLight3D = OmniLight3D.new()

	light.position = Vector3.UP * 3
	light.light_energy = 0.5
	light.omni_range = 5
	light.omni_attenuation = 1.5

	add_child(light)

func place_walls() -> void:	
	for i in room_data.exits.size():
		if room_data.exits[i] == false:
			var wall : Wall = wall_scene.instantiate()
			wall.rotation_degrees = Vector3(0, i * -60, 0)
			var direction = Vector3.FORWARD.rotated(Vector3.UP, wall.rotation.y)
			wall.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
			wall.material = materials[material_index]
			add_child(wall)


func place_collisions() -> void:
	for i in room_data.exits.size():
		var static_body : StaticBody3D
		if room_data.exits[i]:
			static_body = exit_collision_scene.instantiate()
		
		else:
			static_body = full_collision_scene.instantiate()

		static_body.rotation_degrees = Vector3(0, i * -60, 0)
		var direction = Vector3.FORWARD.rotated(Vector3.UP, static_body.rotation.y)
		static_body.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5) + Vector3.UP * (Globals.HEX_HEIGHT - 0.5) * 0.5

		add_child(static_body)

func define_corridors():
	for i in room_data.exits.size():
		if room_data.exits[i]:
			var neighbour : Vector3i = room_data.coords + Globals.directions[i]
			if !Globals.maze[neighbour].corridors[wrapi(i + 3, 0, 6)]:
				room_data.corridors[i] = true

func place_corridors() -> void:
	var corridor_index : int = 0
	for i in room_data.corridors.size():
		if room_data.corridors[i]:
			var neighbour : Vector3i = room_data.coords + Globals.directions[i]
			var corridor_type : CorridorSlope.Type
			var offset : int
			
			if Globals.maze[room_data.coords].type == room_data.Type.NORMAL and Globals.maze[neighbour].type == room_data.Type.NORMAL:
				corridor_type = CorridorSlope.Type.NORMAL
			elif Globals.maze[room_data.coords].type == room_data.Type.SMALL and Globals.maze[neighbour].type == room_data.Type.SMALL:
				corridor_type = CorridorSlope.Type.LONG
			elif Globals.maze[room_data.coords].type == room_data.Type.NORMAL and Globals.maze[neighbour].type == room_data.Type.SMALL:
				corridor_type = CorridorSlope.Type.SEMI_LONG
				offset = 1
			else:
				corridor_type = CorridorSlope.Type.SEMI_LONG
				offset = -1


			var corridor : CorridorSlope = corridor_scene.instantiate()
			corridor.initialize(corridor_index, position.y, Globals.maze[neighbour].position.y, corridor_type)
	
			corridor.rotation_degrees = Vector3(0, i * -60, 0)
			var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(corridor.rotation_degrees.y))
			corridor.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.5) - Vector3.UP * position.y

			if corridor_type == CorridorSlope.Type.SEMI_LONG:
				corridor.position += offset * direction * sqrt(3) * (Globals.HEX_SIZE - Globals.SMALL_HEX_SIZE) * 0.25

			corridor.coin_picked.connect(_on_corridor_coin_picked)

			$Corridors.add_child(corridor)
			corridor_index += 1

func define_guillotines():
	for i in room_data.exits.size():
		room_data.guillotines.append(!(room_data.exits[i] == false or randf() > 0.05))


func place_guillotines():
	for i in room_data.guillotines.size():
		if room_data.guillotines[i]:
			var guillotine = guillotine_scene.instantiate()
			guillotine.rotation_degrees = Vector3(0, i * -60, 0)
			var direction = Vector3.FORWARD.rotated(Vector3.UP, guillotine.rotation.y)
			guillotine.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
			add_child(guillotine)



func define_coins():
	var coin_count : int = randi_range(0, 5)
	var max_offset : int = 10
	if room_data.type == room_data.Type.SMALL:
		coin_count = randi_range(0, 3)
		max_offset = 5
		
	for i in coin_count:
		room_data.coins.append(randi_range(0, max_offset))

	define_corridor_coins()


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

func place_coins():
	if room_data.coins.size() == 0:
		return
	var angle_increment : float = TAU / room_data.coins.size()
	for i in room_data.coins.size():
		if room_data.coins[i] > 0:
			var radius : float = room_size - 1.25 - 0.1 * room_data.coins[i]
			var coin : Coin = coin_scene.instantiate()
			coin.idx = i
			coin.position = Vector3.FORWARD.rotated(Vector3.UP, angle_increment * i) * radius + Vector3.UP * 0.4
			
			coin.picked.connect(_on_coin_picked)
			$Coins.add_child(coin)

	var corridor_index : int = 0
	for i in room_data.corridors.size():
		if room_data.corridors[i]:
			var corridor : CorridorSlope = $Corridors.get_child(corridor_index)
			corridor.place_coins(room_data.corridor_coins[corridor_index])
			corridor_index += 1

func disable_detector():
	entrance_detector.monitoring = false

func enable_detector():
	entrance_detector.monitoring = true


func toggle_visibility(visibility : bool):
	$Body.visible = visibility
	$Floor.visible = visibility
	$Ceiling.visible = visibility
	$Coins.visible = visibility
	for corridor : CorridorSlope in $Corridors.get_children():
		corridor.toggle_visibility(visibility)


func _on_coin_picked(idx : int):
	room_data.coins[idx] = -1

func _on_corridor_coin_picked(idx : int, corridor_idx : int):
	room_data.corridor_coins[corridor_idx][idx] = -1

func _on_entrance_detector_body_entered(body:Node3D) -> void:
	if body is Player:
		entered.emit(room_data.coords)
		body.current_room = room_data.coords
	elif body is Enemy:
		body.current_room = room_data.coords
		body.is_in_instantiated_room = true
