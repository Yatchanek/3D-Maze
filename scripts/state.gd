extends Node
class_name State

var actor : StateEntity
var elapsed_time : float = 0.0

@onready var state_machine : FiniteStateMachine = get_parent()

signal transition(new_state : String)


func _enter_state(_previous_state : State) -> void:
    pass

func _exit_state() -> void:
    pass

func update(_delta : float) -> void:
    pass

func physics_update(_delta : float) -> void:
    pass