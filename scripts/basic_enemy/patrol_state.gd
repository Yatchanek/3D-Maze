extends State

func _enter_state(_previous_state : State) -> void:
	actor.SPEED = 1.25
	actor.change_color(Color.GREEN)
	elapsed_time = 0.0

func physics_update(delta : float) -> void:
	if !actor.a_star:
		return
	actor.tick += 1
	if actor.position.distance_squared_to(actor.waypoint) < 0.05 * 0.05:
		if actor.path.size() > 1:
			actor.path.remove_at(0)
			actor.waypoint = actor.path[0]
		else:
			actor.get_new_destination()

	if actor.target_in_range:
		elapsed_time += delta
		if elapsed_time >= 0.075:
			elapsed_time -= 0.075
			actor.target = actor.check_line_sight(actor.potential_target)
			if actor.target:
				transition.emit("Chase")

	var direction : Vector3 = actor.position.direction_to(actor.waypoint)
	if actor.tick % 5 == 0:
		direction = actor.get_context_steering(direction)

	actor.handle_movement(direction)