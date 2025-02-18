extends StaticBody3D
class_name Corridor

@onready var left_wall : MeshInstance3D = $LeftWall
@onready var left_collision : CollisionShape3D = $LeftCollision
@onready var left_outline : MeshInstance3D = $LeftOutline
@onready var ceiling : MeshInstance3D = $Ceiling
@onready var floor_mesh : MeshInstance3D = $Floor

func _ready() -> void:
	left_wall.mesh.size.z = Globals.CORRIDOR_LENGTH
	left_collision.shape.size.z = Globals.CORRIDOR_LENGTH
	left_outline.mesh.size.z = Globals.CORRIDOR_LENGTH
	ceiling.mesh.size.y = Globals.CORRIDOR_LENGTH
	floor_mesh.mesh.size.y = Globals.CORRIDOR_LENGTH