extends State

func _enter_state(_previous_state : State) -> void:
	print("Enter Idle")
	actor.anim_player.speed_scale = 1.0
	actor.anim_player.play("Idle")

func physics_update(delta : float) -> void:
	elapsed_time += delta
	if elapsed_time > 1.0:
		transition.emit("Seek")

	if actor.target_in_range:
		elapsed_time += delta
		if elapsed_time >= 0.075:
			elapsed_time -= 0.075
			actor.target = actor.check_line_sight(actor.potential_target)
			if actor.target:
				transition.emit("Chase")