extends State

func physics_update(delta : float) -> void:
    elapsed_time += delta
    if elapsed_time > 1.0:
        transition.emit("Seek")