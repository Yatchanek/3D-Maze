extends State

func _enter_state(_precious_state : State) -> void:
	actor.SPEED = 2.0
	actor.change_color(Color.RED)
	elapsed_time = 0.0

func physics_update(delta : float) -> void:

	elapsed_time += delta
	if elapsed_time > 0.1:
		elapsed_time -= 0.1
		actor.last_target_position = actor.target.position
		actor.target = actor.check_line_sight(actor.target)
		if !actor.target:
			transition.emit("CheckLast")

	var direction : Vector3 = Vector3.ZERO
	if actor.target:
		direction = actor.position.direction_to(actor.target.position)
		
	else:
		direction = -actor.basis.z
	
	direction.y = 0

	actor.handle_movement(direction, delta)