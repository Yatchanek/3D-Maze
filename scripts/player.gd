extends CharacterBody3D

@onready var gimbal : Node3D = $CameraGimbal
@onready var camera : Camera3D = $CameraGimbal/Camera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		gimbal.rotation.y -= event.relative.x * 0.0025
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0025, - PI / 2, PI / 2)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "back")
	var direction : Vector3 = gimbal.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	if direction:
		velocity.z = direction.z * SPEED
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)


	move_and_slide()
