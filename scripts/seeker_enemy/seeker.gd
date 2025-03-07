extends Enemy
class_name Seeker

@onready var context_steering_component : ContextSteeringComponent = $ContextSteeringComponent
@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var upper_jaw : MeshInstance3D = $UpperJaw
@onready var bottom_jaw : MeshInstance3D = $BottomJaw
@onready var ground_check : Area3D = $GroundCheck

func _ready() -> void:
	var body_scale_x : float = pow(-1, randi() % 2)
	upper_jaw.scale.x *= body_scale_x
	bottom_jaw.scale.x *= body_scale_x

func get_context_steering(dir : Vector3) -> Vector3:
	return context_steering_component.get_context_steering(dir, rotation.y)

func handle_movement(direction : Vector3, delta : float):
	if direction.is_equal_approx(Vector3.ZERO):
		direction = -global_basis.z
	
	var desired_velocity : Vector3 = direction * SPEED
	var steering : Vector3 = desired_velocity - velocity
	
	steering = steering.normalized() * STEER_FORCE
	velocity += steering * delta

	if !position.is_equal_approx(position + direction):
		look_at(position + direction)
		basis = basis.orthonormalized()

	if is_in_instantiated_room:
		if !is_on_floor():
			velocity.y += -9.8 * delta

		move_and_slide()

	else:
		position += velocity * delta



func _on_ground_check_body_exited(_body:Node3D) -> void:
	await get_tree().process_frame
	if ground_check.get_overlapping_bodies().size() == 0:
		$CollisionShape3D.set_deferred("disabled", true)
		is_in_instantiated_room = false

func _on_ground_check_body_entered(_body:Node3D) -> void:
	if !is_in_instantiated_room:
		$CollisionShape3D.set_deferred("disabled", false)
		is_in_instantiated_room = true
