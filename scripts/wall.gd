extends MeshInstance3D
class_name Wall

var material : Material

func _ready() -> void:
	material_override = material
	mesh.size = Vector3(Globals.HEX_SIZE * 0.375, Globals.HEX_HEIGHT - 0.5, Globals.WALL_WIDTH)
	position.y = mesh.size.y * 0.5

