extends StaticBody3D
class_name HexRoom

@export var wall_scene : PackedScene

var layout : int = 0

func _ready() -> void:
	var exits : Array [int] = [Globals.N, Globals.NE, Globals.SE, Globals.S, Globals.SW, Globals.NW]
	for i in exits.size():
		create_wall(i, layout & exits[i])


func create_wall(idx: int, exit : int) -> void:
	var wall : Wall = wall_scene.instantiate()
	if exit == 0:
		wall.type = Wall.Type.FULL
	else:
		wall.type = Wall.Type.TOP
	wall.rotation_degrees = Vector3(0, idx * -60, 0)
	var direction = Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(wall.rotation_degrees.y))
	wall.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 - Globals.WALL_WIDTH * 0.5) + Vector3.UP * (Globals.HEX_HEIGHT - 0.5) * 0.5

	add_child(wall)
