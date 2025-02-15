extends CharacterBody3D


const SPEED = 1.25
const JUMP_VELOCITY = 4.5

var a_star : AStar3D
var maze : Dictionary = {}
var path : PackedVector3Array = []

var waypoint : Vector3

enum State {
	PATROL,
	CHASE,
	CHECK_LAST,
	LOOK_AROUND,
	RESUME
}

var current_state : State

var target : CharacterBody3D
var target_in_range : bool = false
var last_target_position : Vector3

var elapsed_time : float = 0.0
var rotation_time : float = 0.0

var num_rays : int = 8

var interest : Array[float] = []
var ray_directions : Array[Vector3] = []

var sight_check_query : PhysicsShapeQueryParameters3D

func _ready() -> void:
	configure_rays()
	sight_check_query = PhysicsShapeQueryParameters3D.new()
	var shape : BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.3, 0.3, Globals.HEX_SIZE * 2)
	sight_check_query.shape = shape
	sight_check_query.collision_mask = 1
	current_state = State.PATROL


func configure_rays():
	interest.resize(num_rays)
	for i in num_rays:
		ray_directions.append(-basis.z.rotated(Vector3.UP, (TAU / num_rays) * i))


func _physics_process(delta: float) -> void:
	if !a_star:
		return
	
	var direction : Vector3
	if current_state == State.PATROL:
		if position.distance_squared_to(waypoint) < 0.05 * 0.05:
			if path.size() > 1:
				path.remove_at(0)
				waypoint = path[0]
			else:
				get_new_destination()
			
			if target_in_range:
				elapsed_time += delta
				if elapsed_time >= 0.5:
					elapsed_time -= 0.5
					if check_line_sight():
						$Body.mesh.albedo_color = Color.RED
						current_state = State.CHASE


		direction = position.direction_to(waypoint)
	
	elif current_state == State.CHASE:
		elapsed_time += delta
		if elapsed_time > 0.1:
			elapsed_time -= 0.1
			if !check_line_sight():
				last_target_position = target.position
				$Body.mesh.material.albedo_color = Color.YELLOW
				current_state = State.CHECK_LAST

		direction = position.direction_to(target.position)		

	elif current_state == State.CHECK_LAST:
		direction = get_context_steering(position.direction_to(last_target_position))
		if position.distance_squared_to(last_target_position) < 0.05 * 0.05:
			current_state = State.LOOK_AROUND

	elif current_state == State.LOOK_AROUND:
		print("Looking around")
		elapsed_time += delta
		rotation_time += delta
		rotation.y += PI / 2 * delta
		if elapsed_time > 0.1:
			elapsed_time -= 0.1
			if target and check_line_sight():
				$Body.mesh.material.albedo_color = Color.RED
				current_state = State.CHASE
		if rotation_time > 2.0:
			rotation_time -= 2.0
			waypoint = a_star.get_point_position(a_star.get_closest_point(position))
			$Body.mesh.material.albedo_color = Color.GREEN
			current_state = State.RESUME
	
	elif current_state == State.RESUME:
		direction = position.direction_to(waypoint)
		if position.distance_squared_to(waypoint) < 0.05 * 0.05:
			get_new_destination()
			current_state = State.PATROL

	if current_state != State.LOOK_AROUND:
		var desired_velocity : Vector3 = direction * SPEED

		velocity = lerp(velocity, desired_velocity, 0.15)
		if velocity != Vector3.ZERO:
			transform = transform.looking_at(position + velocity.normalized())
			basis = basis.orthonormalized()

		move_and_slide()


func get_context_steering(dir : Vector3):
	for i in num_rays:
		interest[i] = max(0, ray_directions[i].rotated(Vector3.UP, rotation.y).dot(dir))

	var state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	for i in num_rays:
		var query : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(position + Vector3.UP * 0.5, position + Vector3.UP * 0.5 + ray_directions[i].rotated(Vector3.UP, rotation.y) * 2, 1)
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


func check_line_sight() -> bool:
	var to : Vector3
	if target:
		to = target.position + Vector3.UP * 0.5
	else:
		to = position + Vector3.UP * 0.5 -basis.z * Globals.HEX_SIZE
	sight_check_query.transform.origin = to
	var state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(position + Vector3.UP * 0.5, to, 1)
	#var result : Array[Dictionary] = state.intersect_shape(sight_check_query)
	var result : Dictionary = state.intersect_ray(query)
	if result:#.size() > 0:
		return false

	return true

func _on_detector_body_entered(body: Node3D) -> void:
	target = body
	if check_line_sight():
		$Body.mesh.material.albedo_color = Color.RED
		current_state = State.CHASE
	else:
		target_in_range = true


func _on_detector_body_exited(_body: Node3D) -> void:
	if current_state == State.CHASE:
		last_target_position = target.position
		target = null
		target_in_range = false
		$Body.mesh.material.albedo_color = Color.YELLOW
		current_state = State.CHECK_LAST
	else:
		target_in_range = false