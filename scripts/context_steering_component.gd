extends Node
class_name ContextSteeringComponent

@export var num_rays : int = 8
@export var ray_length : float = 2.0
@export_flags_3d_physics var collision_mask : int = 1
@export var check_height : float = 0.5

var ray_directions : Array[Vector3] = []
var interest : Array[float] = []

var parent : CharacterBody3D


func _ready() -> void:
	parent = get_parent()
	configure_rays()

func configure_rays():
	interest.resize(num_rays)
	for i in num_rays:
		ray_directions.append(-parent.basis.z.rotated(Vector3.UP, (PI / num_rays) * i - PI / 2))

func get_context_steering(dir : Vector3, rotation : float):
	for i in num_rays:
		interest[i] = max(0, ray_directions[i].rotated(Vector3.UP, rotation).dot(dir))

	var state : PhysicsDirectSpaceState3D = parent.get_world_3d().direct_space_state

	for i in num_rays:
		var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(parent.global_position + Vector3.UP * check_height, parent.global_position + Vector3.UP * check_height + ray_directions[i].rotated(Vector3.UP, rotation) * ray_length, collision_mask)
		var result = state.intersect_ray(query)

		if result:
			interest[i] = -1.0

	var chosen_direction : Vector3 = Vector3.ZERO

	for i in num_rays:
		chosen_direction += ray_directions[i] * interest[i]

	chosen_direction = chosen_direction.normalized()
	#prints(dir, chosen_direction)
	return chosen_direction.rotated(Vector3.UP, rotation)