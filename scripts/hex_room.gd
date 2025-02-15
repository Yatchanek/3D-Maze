extends Node3D
class_name HexRoom

@export var wall_scene : PackedScene
@export var full_collision_scene : PackedScene
@export var exit_collision_scene : PackedScene

var layout : int = 0

func _ready() -> void:
	var exits : Array [int] = [Globals.N, Globals.NE, Globals.SE, Globals.S, Globals.SW, Globals.NW]
	for i in exits.size():
		create_wall(i, layout & exits[i])
		add_collision(i, layout & exits[i])

func create_wall(idx: int, exit : int) -> void:
	if exit != 0:
		return
	var wall : Wall = wall_scene.instantiate()
	wall.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(wall.rotation_degrees.y))
	wall.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 - Globals.WALL_WIDTH * 0.5) + Vector3.UP * (Globals.HEX_HEIGHT - 0.5) * 0.5

	add_child(wall)

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
