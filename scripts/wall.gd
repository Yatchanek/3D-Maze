extends MeshInstance3D
class_name Wall

@onready var outline : MeshInstance3D = $Outline

func _ready() -> void:
	mesh.size = Vector3(Globals.HEX_SIZE * 0.375, Globals.HEX_HEIGHT - 0.5, Globals.WALL_WIDTH)
	position.y = (Globals.HEX_HEIGHT - 0.5) * 0.5
	outline.mesh.size = Vector3(Globals.HEX_SIZE * 0.5, 0.1, Globals.WALL_WIDTH)
	outline.position.y = position.y + mesh.size.y * 0.5 + 0.55
