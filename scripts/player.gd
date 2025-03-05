extends CharacterBody3D
class_name Player

@export var grenade_scene : PackedScene
@export var spear_scene : PackedScene

@onready var gimbal : Node3D = $CameraGimbal
@onready var camera : Camera3D = $CameraGimbal/Camera
@onready var light : SpotLight3D = $CameraGimbal/Camera/Light
@onready var weapon_slot : Node3D = $CameraGimbal/Camera/WeaponSlot
@onready var grenade_in_hand : MeshInstance3D = $CameraGimbal/Camera/WeaponSlot/GrenadeInHand
@onready var spear_in_hand : MeshInstance3D = $CameraGimbal/Camera/WeaponSlot/SpearInHand
#@onready var marker : MeshInstance3D = $Marker

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

var can_use_weapon : bool = false
var current_room : Vector3i

var current_weapon : int = 0

var rotation_input : float
var tilt_input : float

var _mouse_rotation : Vector3 = Vector3.ZERO
var _camera_rotation : Vector3 = Vector3.ZERO
var _player_rotation : Vector3 = Vector3.ZERO

signal grenade_thrown(grenade : RigidBody3D, impulse : Vector3)
signal spear_thrown(spear : Area3D, pos : Vector3)
signal health_changed(value : float)
signal stamina_changed(value : float)
signal ouch



func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_input = -event.relative.x * 0.25
		tilt_input = -event.relative.y * 0.25
		# camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0025, - PI / 2, PI / 2)
		# weapon_slot.rotation = camera.rotation

func update_camera(delta : float):
	_mouse_rotation.x = clampf(_mouse_rotation.x + tilt_input * delta, -PI / 2, PI / 2)
	_mouse_rotation.y += rotation_input * delta

	_camera_rotation = Vector3(_mouse_rotation.x, 0, 0)
	_player_rotation = Vector3(0, _mouse_rotation.y, 0)

	gimbal.basis = Basis.from_euler(_camera_rotation)
	gimbal.rotation.z = 0

	global_basis = Basis.from_euler(_player_rotation)

	#marker.global_basis = Basis.IDENTITY

	rotation_input = 0
	tilt_input = 0

func _ready() -> void:
	#set_process(false)
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

	update_camera(delta)

	if Input.is_action_just_pressed("action") and is_on_floor():
		use_weapon()

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
	var direction : Vector3 = basis * Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	if direction:
		current_speed = move_toward(current_speed, target_speed, 0.1 * target_speed)
		velocity.z = direction.z * current_speed
		velocity.x = direction.x * current_speed

		move_offset += 3 * current_speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)

	gimbal.position.y = 0.6 + 0.1 * sin(move_offset)
	if velocity.z != 0:
		weapon_slot.position.y = 0.0005 * sin(move_offset)
	move_and_slide()

func use_weapon():
	if !can_use_weapon:
		return
	if current_weapon == 0:
		throw_grenade()
	elif current_weapon == 1:
		throw_spear()

func throw_spear():
	var tw : Tween = create_tween()
	tw.tween_property(spear_in_hand, "position:z", 0.2, 0.2)
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(spear_in_hand, "position:z", 0.1, 0.1)
	await tw.finished
	var spear : Area3D = spear_scene.instantiate()
	var spear_position : Vector3 = spear_in_hand.global_position
	spear.basis = spear_in_hand.global_basis
	spear_thrown.emit(spear, spear_position)
	spear_in_hand.hide()
	hide_weapon()
	

func throw_grenade():
	var tw : Tween = create_tween()
	tw.tween_property(grenade_in_hand, "position:z", -0.6, 0.2)
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(grenade_in_hand, "position:z", -0.5, 0.1)
	await tw.finished
	var grenade : RigidBody3D = grenade_scene.instantiate()
	var grenade_position : Vector3 = grenade_in_hand.global_position
	var from : Vector3 = camera.project_ray_origin(Vector2(1920, 1080) * 0.5)
	var to : Vector3 = from + camera.project_ray_normal(Vector2(1920, 1080) * 0.5) * 100.0

	var throw_direction : Vector3 = grenade_position.direction_to(to)
	grenade_in_hand.global_basis.z = -throw_direction
	grenade_in_hand.global_basis = grenade_in_hand.global_basis.orthonormalized() * 0.15
	grenade.basis = grenade_in_hand.global_basis
	grenade.rotate_x(PI / 8)
	var impulse : Vector3 = throw_direction * 10.0

	grenade_thrown.emit(grenade, grenade_position, impulse)
	grenade_in_hand.hide()
	hide_weapon()

func flicker():
	flicker_offset *= -1
	var tw : Tween = create_tween().bind_node(self)
	tw.finished.connect(flicker)
	var duration : float = randf_range(0.075, 0.125)
	tw.tween_property(light, "light_energy", 2.0 - randf_range(0.25, 0.85), duration)

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

func change_weapon():
	hide_weapon()

func hide_weapon():
	can_use_weapon = false
	var offset : float = -0.2 if current_weapon == 1 else -0.5
	var tw: Tween = create_tween()
	tw.tween_property(weapon_slot, "position:y", offset, 0.5)
	await tw.finished
	for weapon : MeshInstance3D in weapon_slot.get_children():
		weapon.hide()	
	if current_weapon < 2:
		show_weapon()

func show_weapon():
	if current_weapon == 1:
		var origin : Vector3 = weapon_slot.to_global(spear_in_hand.position + Vector3.UP * 0.2)
		var from : Vector3 = camera.project_ray_origin(Vector2(1920, 1080) * 0.5)
		var to : Vector3 = from + camera.project_ray_normal(Vector2(1920, 1080) * 0.5) * 100.0
		spear_in_hand.global_basis.z = -origin.direction_to(to).normalized()
	
	weapon_slot.get_child(current_weapon).show()
	var tw: Tween = create_tween()
	tw.tween_property(weapon_slot, "position:y", 0.0, 0.5)
	await tw.finished
	can_use_weapon = true

func _on_weapon_changed(weapon :int):
	current_weapon = weapon
	change_weapon()