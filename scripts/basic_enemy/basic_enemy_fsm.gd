extends FiniteStateMachine




func _on_detector_body_entered(body:Node3D) -> void:
	actor.target = actor.check_line_sight(body)
	if actor.target:
		_on_state_transition("Chase")
	else:
		actor.target_in_range = true
		actor.potential_target = body


func _on_detector_body_exited(_body:Node3D) -> void:
	if current_state == states["Chase"]:
		actor.target_in_range = false
	else:
		actor.target = null
		actor.potential_target = null
		actor.target_in_range = false
