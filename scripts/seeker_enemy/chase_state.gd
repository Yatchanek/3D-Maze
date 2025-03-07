extends State

func _enter_state(_precious_state : State) -> void:
	actor.collision_mask += 16
	actor.anim_player.play("Bite")
	actor.anim_player.speed_scale = 1.5
	actor.SPEED = 3.25	
	elapsed_time = 0.0

func physics_update(delta : float) -> void:
	elapsed_time += delta
	actor.tick += 1
	if elapsed_time > 0.5:
		elapsed_time -= 0.5
		if is_instance_valid(actor.target):
			if actor.position.distance_squared_to(actor.target.position) > 0.2:
				actor.target = actor.check_line_sight(actor.target)
				if !actor.target:
					actor.collision_mask -= 16
					transition.emit("Seek")
		else:
			actor.collision_mask -= 16
			transition.emit("Seek")

	if is_instance_valid(actor.target) and actor.position.distance_squared_to(actor.target.position) > 0.2:

		var direction : Vector3 = -actor.global_basis.z

		if actor.target and actor.tick % 5 == 0:
			direction = actor.position.direction_to(actor.target.position)
			direction = actor.get_context_steering(direction)
		
			direction.y = 0
			direction = direction.normalized()

		actor.handle_movement(direction, delta)