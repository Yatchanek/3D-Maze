extends Node3D
class_name HexRoom

@export var wall_scene : PackedScene
@export var full_collision_scene : PackedScene
@export var exit_collision_scene : PackedScene
@export var corridor_scene : PackedScene

@onready var entrance_detector : Area3D = $EntranceDetector

var room_data : CellData

signal entered(coords : Vector3i)

func _ready() -> void:
	position = room_data.position
	var exits : Array [int] = [Globals.N, Globals.NE, Globals.SE, Globals.S, Globals.SW, Globals.NW]
	for i in exits.size():
		var mask : int = room_data.layout & exits[i]
		create_wall(i, mask)
		add_collision(i, mask)
		add_detector_collision(i, mask)
		add_corridor(i, mask)

func create_wall(idx: int, exit : int) -> void:
	if exit != 0:
		return
	var wall : Wall = wall_scene.instantiate()
	wall.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(wall.rotation_degrees.y))
	wall.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 - Globals.WALL_WIDTH * 0.5)

	call_deferred("add_child", wall)


func add_corridor(idx : int, exit : int) -> void:
	if exit == 0:
		return
	var corridor : StaticBody3D = corridor_scene.instantiate()
	corridor.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(corridor.rotation_degrees.y))
	corridor.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.25)
	call_deferred("add_child", corridor)

func add_detector_collision(idx: int, exit : int) -> void:
	if exit == 0:
		return
	
	var collision_shape : CollisionShape3D = CollisionShape3D.new()
	var shape : BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(Globals.HEX_SIZE * 0.75, Globals.HEX_HEIGHT, Globals.WALL_WIDTH)
	collision_shape.shape = shape

	collision_shape.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(collision_shape.rotation_degrees.y))
	collision_shape.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.25) + Vector3.UP * Globals.HEX_HEIGHT * 0.5
	entrance_detector.call_deferred("add_child", collision_shape)

func add_collision(idx: int, exit : int) -> void:
	var static_body : StaticBody3D
	if exit == 0:
		static_body = full_collision_scene.instantiate()
	else:
		static_body = exit_collision_scene.instantiate()
	static_body.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(static_body.rotation_degrees.y))
	static_body.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 - Globals.WALL_WIDTH * 0.5) + Vector3.UP * (Globals.HEX_HEIGHT - 0.5) * 0.5

	add_child(static_body)

func disable_detector():
	for collision_shape : CollisionShape3D in entrance_detector.get_children():
		collision_shape.set_deferred("disabled", true)

func enable_detector():
	for collision_shape : CollisionShape3D in entrance_detector.get_children():
		collision_shape.set_deferred("disabled", false)	

func _on_entrance_detector_body_entered(_body:Node3D) -> void:
	entered.emit(room_data.coords)

