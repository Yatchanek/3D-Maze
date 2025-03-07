extends FiniteStateMachine
class_name LittleEnemyFSM

func _process(delta):
	if actor.is_in_instantiated_room and current_state:
		current_state.update(delta)

func _physics_process(delta) -> void:
	if actor.is_in_instantiated_room and current_state:
		current_state.physics_update(delta)