extends Node3D
class_name HexRoom

@export var wall_scene : PackedScene
@export var full_collision_scene : PackedScene
@export var exit_collision_scene : PackedScene
@export var detector_collision_scene : PackedScene
@export var corridor_scenes : Array[PackedScene]
@export var corridor_scene : PackedScene

@export var materials : Array[Material]

@onready var entrance_detector : Area3D = $EntranceDetector

var room_data : CellData
var material_index : int = 0

var room_size : float

var children_to_add : Array = []

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
	
	for i in exits.size():
		var mask : int = room_data.layout & exits[i]
		create_wall(i, mask)
		add_collision(i, mask)
		add_detector_collision(i, mask)
		add_corridor(i, mask)

func _ready() -> void:
	$Body.set_surface_override_material(0, materials[material_index])
	for child in children_to_add:
		entrance_detector.call_deferred("add_child", child)

	#$Label3D.text = str(room_data.coords)

func create_wall(idx: int, exit : int) -> void:	
	if exit != 0:
		return

	var wall : Wall = wall_scene.instantiate()
	wall.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(wall.rotation_degrees.y))
	wall.position = direction * (sqrt(3) * room_size * 0.5 - Globals.WALL_WIDTH * 0.5)
	wall.material = materials[material_index]
	call_deferred("add_child", wall)


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
	room_data.corridors[idx] = true
	call_deferred("add_child", corridor)

func add_detector_collision(idx: int, exit : int) -> void:
	if exit == 0:
		return

	var detector_collision = detector_collision_scene.instantiate()
	detector_collision.rotation_degrees = Vector3(0, idx * -60, 0)

	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(detector_collision.rotation_degrees.y))
	detector_collision.position = direction * (sqrt(3) * room_size * 0.5 + Globals.CORRIDOR_LENGTH * 0.15) + Vector3.UP * Globals.HEX_HEIGHT * 0.5

	children_to_add.append(detector_collision)


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

func disable_detector():
	entrance_detector.monitoring = false

func enable_detector():
	entrance_detector.monitoring = true


func make_invisible():
	$Body.hide()
	$Floor.hide()
	$Ceiling.hide()

func make_visible():
	$Body.show()
	$Floor.show()
	$Ceiling.show()

func _on_entrance_detector_body_entered(body:Node3D) -> void:
	if body is Player:
		entered.emit(room_data.coords)
	elif body is Enemy:
		body.current_room = room_data.coords
		body.is_in_instantiated_room = true

func _exit_tree() -> void:
	room_data.corridors = [false, false, false, false, false, false]
