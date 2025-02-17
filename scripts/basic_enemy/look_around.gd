extends State

var rotation_time : float = 0.0

func _enter_state(_previous_state : State) -> void:
	rotation_time = 0.0

func physics_update(delta : float) -> void:
	elapsed_time += delta
	rotation_time += delta
	actor.rotation.y += TAU / 2 * delta
	actor.target = actor.check_line_sight()
	if actor.target:
		transition.emit("Chase")
	if rotation_time > 2.0:
		rotation_time = 0.0
		transition.emit("Resume")
