extends Enemy
class_name LittleEnemy

@onready var context_steering_component : ContextSteeringComponent = $ContextSteeringComponent
@onready var ground_check : Area3D = $GroundCheck

var pivot_position : Vector3
var max_radius : float

func _ready() -> void:
	velocity = basis.z * - TOP_SPEED
	SPEED = TOP_SPEED

func handle_movement(direction : Vector3, delta : float):
	if direction.is_equal_approx(Vector3.ZERO):
		return
	
	var desired_velocity : Vector3 = direction * SPEED
	var steering : Vector3 = desired_velocity - velocity
	steering = steering.normalized() * STEER_FORCE
	velocity += steering * delta

	if !position.is_equal_approx(position + velocity.normalized()):
		look_at(position + velocity.normalized())
		basis = basis.orthonormalized()

	if is_in_instantiated_room:
		if !is_on_floor():
			velocity.y += -9.8 * delta

		move_and_slide()


func _on_ground_check_body_exited(_body:Node3D) -> void:
	await get_tree().process_frame
	if ground_check.get_overlapping_bodies().size() == 0:
		$CollisionShape3D.set_deferred("disabled", true)
		is_in_instantiated_room = false
		hide()

func _on_ground_check_body_entered(_body:Node3D) -> void:
	if !is_in_instantiated_room:
		$CollisionShape3D.set_deferred("disabled", false)
		is_in_instantiated_room = true
		show()
