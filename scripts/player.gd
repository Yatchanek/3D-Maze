extends CharacterBody3D

@export var grenade_scene : PackedScene

@onready var gimbal : Node3D = $CameraGimbal
@onready var camera : Camera3D = $CameraGimbal/Camera
@onready var light : SpotLight3D = $CameraGimbal/Camera/Light

const SPEED = 4.0
const JUMP_VELOCITY = 2.5

var elapsed_time : float = 0.0
var flicker_threshold : float = 0.2

var flicker_offset : int = 1

signal grenade_thrown(grenade : RigidBody3D, impulse : Vector3)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		gimbal.rotation.y -= event.relative.x * 0.0025
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0025, - PI / 2, PI / 2)



func _ready() -> void:
	Globals.player = self

func start():
	flicker()
	$CollisionShape3D.set_deferred("disabled", false)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += -9.8 * delta

	if Input.is_action_just_pressed("action") and is_on_floor():
		throw_grenade()


	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "back")
	var direction : Vector3 = gimbal.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	if direction:
		
		velocity.z = direction.z * SPEED
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)


	move_and_slide()

func throw_grenade():
	var grenade : RigidBody3D = grenade_scene.instantiate()
	grenade.position = position -gimbal.global_basis.z * 0.75 + Vector3.UP * 0.75
	var impulse : Vector3 = -camera.global_basis.z * 5.0

	grenade_thrown.emit(grenade, impulse)


func flicker():
	flicker_offset *= -1
	var tw : Tween = create_tween().bind_node(self)
	tw.finished.connect(flicker)
	var duration : float = randf_range(0.075, 0.125)
	tw.tween_property(light, "position:y", flicker_offset * 0.025, duration)
	tw.parallel().tween_property(light, "light_energy", 1.85 - randf_range(0.25, 0.65), duration)
