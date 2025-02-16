extends Enemy
class_name BasicEnemy

@onready var context_steering_component : ContextSteeringComponent = $ContextSteeringComponent

var maze : Dictionary = {}

var target : CharacterBody3D
var potential_target : CharacterBody3D
var target_in_range : bool = false
var last_target_position : Vector3

var rotation_time : float = 0.0


func get_context_steering(dir : Vector3) -> Vector3:
	return context_steering_component.get_context_steering(dir, rotation.y)

func handle_movement(dir : Vector3):
	var desired_velocity : Vector3 = dir * SPEED

	velocity = lerp(velocity, desired_velocity, 0.15)

	if velocity != Vector3.ZERO:
		look_at(position + velocity.normalized())
		basis = basis.orthonormalized()

	move_and_slide()

func change_color(color : Color):
	$Body.mesh.material.albedo_color = color