extends CharacterBody3D
class_name Enemy

var TOP_SPEED : float = 3.0
var SPEED : float

var a_star : AStar3D

var waypoint : Vector3
var tick : int

var interest : Array[float] = []
var ray_directions : Array[Vector3] = []

var path : PackedVector3Array = []

var current_room : Vector3i

signal died(enemy : Enemy)

func check_line_sight(body : PhysicsBody3D = null) -> PhysicsBody3D:
	var to : Vector3
	if is_instance_valid(body):
		if -basis.z.dot(global_position.direction_to(body.global_position)) < 0.3:
			return null
		to = body.global_position + Vector3.UP * 0.25
	else:
		to = global_position + Vector3.UP * 0.25 -basis.z * Globals.HEX_SIZE * 2
	var state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.25, to, 17)
	var result : Dictionary = state.intersect_ray(query)

	if result and result.collider is CharacterBody3D:
		return result.collider
	else:
		return null

func take_damage(_hurtbox : HurtBox):
	queue_free()
	died.emit(self)