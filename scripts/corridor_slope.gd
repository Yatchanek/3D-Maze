extends StaticBody3D
class_name CorridorSlope

@onready var left_wall : MeshInstance3D = $LeftWall
@onready var left_collision : CollisionShape3D = $LeftCollision
@onready var floor_collision : CollisionShape3D = $FloorCollision
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

var from : float
var to : float 


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

	var h_diff : float = to - from
	var angle : float = atan2(h_diff, length)
	var slope_length : float = abs(length / cos(angle))
	ceiling.rotation.x += angle
	floor_mesh.rotation.x = angle
	var offset : float = slope_length * 0.5 * sin(angle)
	ceiling.position.y = from + 1.51 + offset
	floor_mesh.position.y = from + offset
	ceiling.mesh.size.y = slope_length
	floor_mesh.mesh.size.y = slope_length
	floor_top.mesh.size.y = length

	floor_collision.shape.size.z = slope_length
	floor_collision.rotation.x = angle
	floor_collision.position.y = floor_mesh.position.y -0.05