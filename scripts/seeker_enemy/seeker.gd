extends Enemy
class_name Seeker

@onready var context_steering_component : ContextSteeringComponent = $ContextSteeringComponent

func get_context_steering(dir : Vector3) -> Vector3:
	return context_steering_component.get_context_steering(dir, rotation.y)