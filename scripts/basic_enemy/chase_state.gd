extends State

func _enter_state(_precious_state : State) -> void:
	actor.collision_mask += 16
	actor.SPEED = 2.5
	actor.change_color(Color.RED)
	elapsed_time = 0.0

func physics_update(delta : float) -> void:

	elapsed_time += delta
	if elapsed_time > 0.5:
		elapsed_time -= 0.5
		if actor.position.distance_squared_to(actor.target.position) > 0.25:
			actor.last_target_position = actor.target.position
			actor.target = actor.check_line_sight(actor.target)
			if !actor.target:
				actor.collision_mask -= 16
				transition.emit("CheckLast")

	if is_instance_valid(actor.target) and actor.position.distance_squared_to(actor.target.position) > 0.2:

		var direction : Vector3 = -actor.global_basis.z
		
		if actor.target and actor.tick % 5 == 0:
			direction = actor.position.direction_to(actor.target.position)
			direction = actor.get_context_steering(direction)
		
			direction.y = 0
			direction = direction.normalized()

		actor.handle_movement(direction, delta)