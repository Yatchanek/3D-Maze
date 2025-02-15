extends StaticBody3D

@onready var collision_shape : CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape.shape.size = Vector3(Globals.HEX_SIZE, Globals.HEX_HEIGHT, Globals.WALL_WIDTH)
