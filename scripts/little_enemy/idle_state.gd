extends State

func _enter_state(_previous_state : State) -> void:
    await get_tree().create_timer(randf_range(0.5, 1.0)).timeout
    transition.emit("WanderState")