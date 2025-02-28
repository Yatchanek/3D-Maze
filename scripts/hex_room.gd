extends Node3D
class_name HexRoom

@export var wall_scene : PackedScene
@export var full_collision_scene : PackedScene
@export var exit_collision_scene : PackedScene
@export var corridor_scene : PackedScene
@export var guillotine_scene : PackedScene
@export var coin_scene : PackedScene

@export var materials : Array[Material]

@onready var coins_node : Node3D = $Coins
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



	for i in exits.size():
		var mask : int = room_data.layout & exits[i]
		create_wall(i, mask)
		add_collision(i, mask)
		add_corridor(i, mask)
		if room_data.first_instantiate:
			add_guillotine(i, mask)
	
	place_guillotines()
	place_coins()
	room_data.first_instantiate = false


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

func create_wall(idx: int, exit : int) -> void:	
	if exit != 0:
		return

	var wall : Wall = wall_scene.instantiate()
	wall.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(wall.rotation_degrees.y))
	wall.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
	wall.material = materials[material_index]
	add_child(wall)


func add_corridor(idx : int, exit : int) -> void:
	var neighbour : Vector3i = room_data.coords + Globals.directions[idx]
	if exit == 0 or Globals.CORRIDOR_LENGTH <= 0.0 or Globals.maze[neighbour].corridors[wrapi(idx + 3, 0, 6)]:
		return

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
	
	corridor.from = position.y
	corridor.to = Globals.maze[neighbour].position.y
	corridor.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(corridor.rotation_degrees.y))
	corridor.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.5) - Vector3.UP * position.y

	if corridor_type == CorridorSlope.Type.SEMI_LONG:
		corridor.position += offset * direction * sqrt(3) * (Globals.HEX_SIZE - Globals.SMALL_HEX_SIZE) * 0.25

	

	corridor.type = corridor_type
	corridor.add_to_group("Corridors")
	room_data.corridors[idx] = true

	add_child(corridor)


func add_guillotine(i : int, exit : int):
	if exit == 0 or randf() > 0.05:
		return
	var guillotine = guillotine_scene.instantiate()
	guillotine.rotation_degrees = Vector3(0, i * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, guillotine.rotation.y)
	guillotine.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
	room_data.guillotines[i] = true
	add_child(guillotine)	

func place_guillotines():
	if room_data.first_instantiate:
		return
	for i in 6:
		if room_data.guillotines[i]:
			var guillotine = guillotine_scene.instantiate()
			guillotine.rotation_degrees = Vector3(0, i * -60, 0)
			var direction = Vector3.FORWARD.rotated(Vector3.UP, guillotine.rotation.y)
			guillotine.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
			add_child(guillotine)

func add_collision(idx: int, exit : int) -> void:
	var static_body : StaticBody3D
	if exit == 0:
		static_body = full_collision_scene.instantiate()
	else:
		static_body = exit_collision_scene.instantiate()
	static_body.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(static_body.rotation_degrees.y))
	static_body.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5) + Vector3.UP * (Globals.HEX_HEIGHT - 0.5) * 0.5

	add_child(static_body)


func place_coins():
	var radius : float = room_size - 1.25

	if room_data.first_instantiate:
		var coin_count : int = randi_range(3, 7)
		room_data.coin_count = coin_count
		for i in coin_count:
			var coin : Coin = coin_scene.instantiate()
			coin.idx = i
			var angle_increment : float = TAU / coin_count
			coin.position = Vector3.FORWARD.rotated(Vector3.UP, angle_increment * i) * radius + Vector3.UP * 0.4
			
			coin.picked.connect(_on_coin_picked)
			add_child(coin)
			room_data.coins.append(i)
		

	else:
		for i in room_data.coins:
			var angle_increment : float = TAU / room_data.coin_count
			var coin : Coin = coin_scene.instantiate()
			coin.idx = i
			coin.position = Vector3.FORWARD.rotated(Vector3.UP, angle_increment * i) * radius + Vector3.UP * 0.4
			
			coin.picked.connect(_on_coin_picked)
			add_child(coin)



func disable_detector():
	entrance_detector.monitoring = false

func enable_detector():
	entrance_detector.monitoring = true


func make_invisible():
	$Body.hide()
	$Floor.hide()
	$Ceiling.hide()
	$Coins.hide()

func make_visible():
	$Body.show()
	$Floor.show()
	$Ceiling.show()
	$Coins.show()

func _on_coin_picked(idx : int):
	room_data.coins.erase(idx)

func _on_entrance_detector_body_entered(body:Node3D) -> void:
	if body is Player:
		entered.emit(room_data.coords)
		body.current_room = room_data.coords
	elif body is Enemy:
		body.current_room = room_data.coords
		body.is_in_instantiated_room = true


func _exit_tree() -> void:
	room_data.corridors = [false, false, false, false, false, false]