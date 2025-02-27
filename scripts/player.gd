extends CharacterBody3D
class_name Player

@export var grenade_scene : PackedScene

@onready var gimbal : Node3D = $CameraGimbal
@onready var camera : Camera3D = $CameraGimbal/Camera
@onready var light : SpotLight3D = $CameraGimbal/Camera/Light

const WALK_SPEED :float = 4.0
const RUN_SPEED : float = 6.0
var current_speed : float
var target_speed : float
const JUMP_VELOCITY = 2.5

const MAX_HEALTH : int = 50
const MAX_STAMINA : int = 50
var current_stamina : float :
	set(value):
		if !is_inside_tree():
			return
		current_stamina = clamp(value, 0, MAX_STAMINA)
		stamina_changed.emit(current_stamina)

var current_health : float : 
	set(value):
		if !is_inside_tree():
			return
		current_health = clamp(value, 0, MAX_HEALTH)
		health_changed.emit(current_health)
		if current_health <= 0:
			get_tree().call_deferred("reload_current_scene")

var elapsed_time : float = 0.0
var flicker_threshold : float = 0.2
var flicker_offset : int = 1

var damaging_agents : Array[HurtBox] = []
var damage_time : float = 0.0

var move_offset : float = 0.0

var current_room : Vector3i

signal grenade_thrown(grenade : RigidBody3D, impulse : Vector3)
signal health_changed(value : float)
signal stamina_changed(value : float)
signal ouch

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		gimbal.rotation.y -= event.relative.x * 0.0025
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0025, - PI / 2, PI / 2)



func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	current_speed = 0
	target_speed = WALK_SPEED

	Globals.player = self

func start():
	current_stamina = MAX_STAMINA
	current_health = MAX_HEALTH
	set_physics_process(true)
	flicker()
	$CollisionShape3D.set_deferred("disabled", false)

func _process(delta: float) -> void:
	for agent : HurtBox in damaging_agents:
		current_health -= agent.damage * delta

	damage_time += delta
	if damage_time >= 0.5:
		ouch.emit()
		damage_time -= 0.5

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += -9.8 * delta

	if Input.is_action_just_pressed("action") and is_on_floor():
		throw_grenade()

	if Input.is_action_just_pressed("run") and current_stamina > 0:
		target_speed = RUN_SPEED
	elif Input.is_action_just_released("run"):
		target_speed = WALK_SPEED

	if target_speed > WALK_SPEED:
		current_stamina -= 5 * delta
		if current_stamina <=0 :
			current_stamina = 0
			target_speed = WALK_SPEED

	elif current_stamina < MAX_STAMINA:
		current_stamina = clamp(current_stamina + 2 * delta, 0, MAX_STAMINA)

	var input_dir := Input.get_vector("strafe_left", "strafe_right", "forward", "back")
	var direction : Vector3 = gimbal.basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	if direction:
		current_speed = move_toward(current_speed, target_speed, 0.1 * target_speed)
		velocity.z = direction.z * current_speed
		velocity.x = direction.x * current_speed
		move_offset += 3 * current_speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)

	camera.position.y = 0.1 * sin(move_offset)
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
	tw.parallel().tween_property(light, "light_energy", 2.0 - randf_range(0.25, 0.85), duration)

func take_damage(hurtbox : HurtBox):
	if hurtbox.damage_type == HurtBox.DamageType.INSTANT:
		current_health -= hurtbox.damage
		ouch.emit()
	else:
		damaging_agents.append(hurtbox)
		if !is_processing():
			set_process(true)

func hurtbox_gone(hurtbox : HurtBox):
	damaging_agents.erase(hurtbox)
	if damaging_agents.size() == 0:
		set_process(false)
		damage_time = 0.0