extends MeshInstance3D
class_name Wall

@onready var outline : MeshInstance3D = $Outline

var material_idx : int 

func _ready() -> void:
	mesh.material = load("res://materials/wall_material_" + str(material_idx) + ".tres")
	mesh.size = Vector3(Globals.HEX_SIZE * 0.375, Globals.HEX_HEIGHT - 0.5, Globals.WALL_WIDTH)
	position.y = mesh.size.y * 0.5
	outline.mesh.size = Vector3(Globals.HEX_SIZE * 0.375, 0.1, Globals.OUTLINE_WIDTH)
	outline.position.z = (-Globals.WALL_WIDTH + Globals.OUTLINE_WIDTH) * 0.5
	outline.position.y = mesh.size.y * 0.5 + 0.55
