extends Enemy
class_name BasicEnemy

@onready var context_steering_component : ContextSteeringComponent = $ContextSteeringComponent
@onready var body : MeshInstance3D = $Body

var maze : Dictionary = {}

var target : CharacterBody3D
var potential_target : CharacterBody3D
var target_in_range : bool = false
var last_target_position : Vector3

var rotation_time : float = 0.0


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
			look_at(position + dir * 5.0)
			basis = basis.orthonormalized()

	move_and_slide()
	if position.y < -5:
		print("Fell down")
		queue_free()



func change_color(color : Color):
	$Body.mesh.material.albedo_color = color

