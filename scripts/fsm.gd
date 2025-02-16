extends Node
class_name FiniteStateMachine

@export var actor : StateEntity
@export var default_state : String

var current_state : State = null
var previous_state : State = null



var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(_on_state_transition)
			child.actor = actor
	call_deferred("_on_state_transition", default_state)

func change_state(new_state : State):
	if new_state is State:
		if current_state:
			current_state._exit_state()
		current_state = new_state
		new_state._enter_state(previous_state)


func _on_state_transition(new_state : String):
	if current_state:
		previous_state = current_state
	change_state(states[new_state])


func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta) -> void:
	if current_state:
		current_state.physics_update(delta)
