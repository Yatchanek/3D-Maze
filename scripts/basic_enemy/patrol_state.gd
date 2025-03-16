extends State

func _enter_state(_previous_state : State) -> void:
	actor.SPEED = 1.25
	actor.change_color(Color.GREEN)
	elapsed_time = 0.0
	get_new_destination()

func physics_update(delta : float) -> void:
	if !actor.a_star:
		return
	actor.tick += 1
	if actor.position.distance_squared_to(actor.waypoint) < 0.05 * 0.05:
		if actor.path.size() > 1:
			actor.path.remove_at(0)
			actor.waypoint = actor.path[0]
		else:
			get_new_destination()

	if actor.target_in_range:
		elapsed_time += delta
		if elapsed_time >= 0.075:
			elapsed_time -= 0.075
			actor.target = actor.check_line_sight(actor.potential_target)
			if actor.target:
				transition.emit("Chase")

	var direction : Vector3
	
	
	if actor.is_in_instantiated_room:
		direction = -actor.global_basis.z

		if actor.tick % 5 == 0:
			direction = actor.global_position.direction_to(actor.waypoint)
			direction = actor.get_context_steering(direction)

		direction.y = 0
		direction = direction.normalized()

	else:
		direction = actor.global_position.direction_to(actor.waypoint)
		
	actor.handle_movement(direction, delta)


func get_new_destination():
	var from : int = actor.a_star.get_closest_point(actor.position)
	var ids : PackedInt64Array = actor.a_star.get_point_ids()
	var to : int = ids[randi() % ids.size()]
	actor.path = actor.a_star.get_point_path(from, to)
	while actor.path.size() < 4:
		to = ids[randi() % ids.size()]
		actor.path = actor.a_star.get_point_path(from, to)
	
	actor.path.remove_at(0)
	actor.waypoint = actor.path[0]
