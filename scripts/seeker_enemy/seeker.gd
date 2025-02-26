extends Enemy
class_name Seeker

@onready var context_steering_component : ContextSteeringComponent = $ContextSteeringComponent
@onready var ground_check : RayCast3D = $GroundCheck
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func get_context_steering(dir : Vector3) -> Vector3:
	return context_steering_component.get_context_steering(dir, rotation.y)

func handle_movement(dir : Vector3, delta : float):
	if dir.is_equal_approx(Vector3.ZERO):
		return
	
	var desired_velocity : Vector3 = dir * SPEED
	
	velocity = lerp(velocity, desired_velocity, 0.15)
	
	if is_in_instantiated_room:
		if !is_on_floor():
			velocity.y += -9.8 * delta

		if !position.is_equal_approx(position + dir):
			look_at(position + dir)
			basis = basis.orthonormalized()

	move_and_slide()

func check_for_floor():
	if !ground_check.is_colliding() and is_in_instantiated_room:
		is_in_instantiated_room = false

	elif ground_check.is_colliding() and !is_in_instantiated_room:
		is_in_instantiated_room = true



