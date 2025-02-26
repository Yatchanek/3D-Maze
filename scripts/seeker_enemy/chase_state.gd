extends State

func _enter_state(_precious_state : State) -> void:
	actor.anim_player.play("Bite")
	actor.anim_player.speed_scale = 1.5
	actor.SPEED = 3.5	
	elapsed_time = 0.0

func physics_update(delta : float) -> void:
	elapsed_time += delta
	if elapsed_time > 0.5:
		elapsed_time -= 0.5
		if actor.position.distance_squared_to(actor.target.position) > 0.2:
			actor.target = actor.check_line_sight(actor.target)
			if !actor.target:
				transition.emit("Seek")

	if is_instance_valid(actor.target) and actor.position.distance_squared_to(actor.target.position) > 0.2:

		var direction : Vector3 = Vector3.ZERO
		if actor.target:
			direction = actor.position.direction_to(actor.target.position)
			direction = actor.get_context_steering(direction)
			
		else:
			direction = -actor.basis.z
		
		direction.y = 0

		actor.handle_movement(direction, delta)