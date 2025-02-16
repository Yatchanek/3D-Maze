extends State

func _enter_state(_previous_state : State) -> void:
	actor.SPEED = 1.25
	actor.change_color(Color.YELLOW)

func physics_update(_delta : float) -> void:
	var direction : Vector3 = actor.get_context_steering(actor.position.direction_to(actor.last_target_position))
	actor.target = actor.check_line_sight()
	if actor.target:
		transition.emit("Chase")
	if actor.position.distance_squared_to(actor.last_target_position) < 0.2 * 0.2:
		transition.emit("LookAround")

	actor.handle_movement(direction)