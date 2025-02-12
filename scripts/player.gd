extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	# if not is_on_floor():
	# 	velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_axis("ui_up", "ui_down")
	velocity = basis.z * input_dir * SPEED

	if Input.is_action_pressed("ui_left"):
		rotation.y += PI * 0.5 * delta
	elif Input.is_action_pressed("ui_right"):
		rotation.y -= PI * 0.5 * delta
	move_and_slide()
