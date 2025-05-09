extends CharacterBody3D
class_name Enemy

@export var TOP_SPEED : float = 3.0
@export var STEER_FORCE : float = 0.1
@export var hp : int = 1

var SPEED : float


var a_star : AStar3D

var waypoint : Vector3
var tick : int


var target : CharacterBody3D
var potential_target : CharacterBody3D
var target_in_range : bool = false
var last_target_position : Vector3

var path : PackedVector3Array = []

var is_in_instantiated_room : bool = false

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
	var query = PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.25, to, 5)
	var result : Dictionary = state.intersect_ray(query)

	if result and result.collider is CharacterBody3D:
		return result.collider
	else:
		return null

func take_damage(hurtbox : HurtBox):
	hp -= hurtbox.damage
	prints("Taken damage: " + str(hurtbox.damage))
	if hp <= 0:
		await get_tree().create_timer(0.1).timeout
		queue_free()
		died.emit(self)