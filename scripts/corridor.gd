extends StaticBody3D
class_name Corridor

@export var meshes : Array[Mesh] = []

@onready var left_wall : MeshInstance3D = $LeftWall
@onready var left_collision : CollisionShape3D = $LeftCollision
@onready var left_outline : MeshInstance3D = $LeftOutline
@onready var ceiling : MeshInstance3D = $Ceiling
@onready var floor_mesh : MeshInstance3D = $Floor
@onready var floor_top : MeshInstance3D = $FloorTop

enum Type {
	NORMAL,
	SEMI_LONG,
	LONG
}

var type : Type

func _ready() -> void:
	var length : float
	if type == Type.NORMAL:
		length = Globals.CORRIDOR_LENGTH
	elif type == Type.SEMI_LONG:
		length = Globals.CORRIDOR_SEMI_LONG_LENGTH
	else:
		length = Globals.CORRIDOR_LONG_LENGTH

	left_wall.mesh.size.z = length
	left_collision.shape.size.z = length
	left_outline.mesh.size.y = length
	ceiling.mesh.size.y = length
	floor_mesh.mesh.size.y = length
	floor_top.mesh.size.y = length