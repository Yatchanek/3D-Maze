extends StateEntity
class_name BasicEnemy

var SPEED = 1.25
const JUMP_VELOCITY = 4.5

var a_star : AStar3D
var maze : Dictionary = {}
var path : PackedVector3Array = []

var waypoint : Vector3

var target : CharacterBody3D
var potential_target : CharacterBody3D
var target_in_range : bool = false
var last_target_position : Vector3

var elapsed_time : float = 0.0
var rotation_time : float = 0.0

var num_rays : int = 12

var interest : Array[float] = []
var ray_directions : Array[Vector3] = []

var sight_check_query : PhysicsShapeQueryParameters3D
var tick : int = 0

func _ready() -> void:
	configure_rays()
	sight_check_query = PhysicsShapeQueryParameters3D.new()
	var shape : BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.3, 0.3, Globals.HEX_SIZE * 2)
	sight_check_query.shape = shape
	sight_check_query.collision_mask = 1

func configure_rays():
	interest.resize(num_rays)
	for i in num_rays:
		ray_directions.append(-basis.z.rotated(Vector3.UP, (TAU / num_rays) * i))


func handle_movement(dir : Vector3):
	var desired_velocity : Vector3 = dir * SPEED

	velocity = lerp(velocity, desired_velocity, 0.15)

	if velocity != Vector3.ZERO:
		look_at(position + velocity.normalized())
		basis = basis.orthonormalized()

	move_and_slide()


func get_context_steering(dir : Vector3):
	for i in num_rays:
		interest[i] = max(0, ray_directions[i].rotated(Vector3.UP, rotation.y).dot(dir))

	var state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	for i in num_rays:
		var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(position + Vector3.UP * 0.5, position + Vector3.UP * 0.5 + ray_directions[i].rotated(Vector3.UP, rotation.y) * 2, 3)
		var result = state.intersect_ray(query)

		if result:
			interest[i] = 0

	var chosen_direction : Vector3 = Vector3.ZERO

	for i in num_rays:
		chosen_direction += ray_directions[i] * interest[i]

	chosen_direction = chosen_direction.normalized()

	return chosen_direction.rotated(Vector3.UP, rotation.y)

func get_new_destination():
	var from : int = a_star.get_closest_point(position)
	var ids : PackedInt64Array = a_star.get_point_ids()
	var to : int = ids[randi() % ids.size()]
	while from == to:
		to = ids[randi() % ids.size()]
	path = a_star.get_point_path(from, to)
	path.remove_at(0)
	waypoint = path[0]


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

func change_color(color : Color):
	$Body.mesh.material.albedo_color = color