extends StaticBody3D

@onready var collision_left : CollisionShape3D = $CollisionLeft
@onready var collision_right : CollisionShape3D = $CollisionRight

func _ready() -> void:
	collision_left.shape.size = Vector3((Globals.SMALL_HEX_SIZE - 1.5) * 0.5, Globals.HEX_HEIGHT, Globals.WALL_WIDTH)
	collision_left.position.x = (-Globals.SMALL_HEX_SIZE + collision_left.shape.size.x) * 0.5
	collision_right.position.x = (Globals.SMALL_HEX_SIZE - collision_right.shape.size.x) * 0.5
