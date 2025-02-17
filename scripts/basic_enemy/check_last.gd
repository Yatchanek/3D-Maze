extends State

func _enter_state(_previous_state : State) -> void:
	actor.SPEED = 1.25
	actor.change_color(Color.YELLOW)

func physics_update(delta : float) -> void:
	elapsed_time += delta
	actor.tick += 1
	var direction : Vector3 = actor.get_context_steering(actor.position.direction_to(actor.last_target_position))
	if actor.tick % 5 == 0:
		actor.target = actor.check_line_sight()
	if actor.target:
		transition.emit("Chase")
	elif actor.position.distance_squared_to(actor.last_target_position) < 0.15 * 0.15:
		transition.emit("LookAround")

	elif elapsed_time > 7.0:
		transition.emit("Resume")
		elapsed_time = 0.0

	else:
		actor.handle_movement(direction)