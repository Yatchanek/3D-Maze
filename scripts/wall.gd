extends StaticBody3D
class_name Wall

@onready var wall_body : MeshInstance3D = $WallBody
@onready var collision_shape : CollisionShape3D = $CollisionShape
@onready var outline : MeshInstance3D = $Outline

enum Type {
	FULL,
	TOP
}

var type : Type

func _ready() -> void:
	if type == Type.TOP:
		wall_body.mesh.size = Vector3(Globals.HEX_SIZE * 0.375, 0.75, Globals.WALL_WIDTH)
		position.y = Globals.HEX_HEIGHT - 0.375
		collision_shape.set_deferred("disabled", true)
		outline.queue_free()
	else:
		wall_body.mesh.size = Vector3(Globals.HEX_SIZE * 0.375, Globals.HEX_HEIGHT, Globals.WALL_WIDTH)
		collision_shape.shape.size = Vector3(Globals.HEX_SIZE * 0.5, Globals.HEX_HEIGHT, Globals.WALL_WIDTH)
		position.y = Globals.HEX_HEIGHT * 0.5
		wall_body.layers = 1
		outline.mesh.size = Vector3(Globals.HEX_SIZE * 0.5, 0.1, Globals.WALL_WIDTH)
		outline.position.y = position.y + wall_body.mesh.size.y * 0.5 + 0.125
