extends State

var path : PackedVector3Array = []
var waypoint : Vector3

func _enter_state(_previous_state : State) -> void:
	actor.SPEED = 2.25
	get_new_destination()

func physics_update(delta : float) -> void:
	actor.tick += 1
	if actor.position.distance_squared_to(waypoint) < 0.1 * 0.1:
		get_new_destination()

	var direction : Vector3 = actor.position.direction_to(waypoint)
	if actor.tick % 3:
		direction = actor.get_context_steering(direction)
	var desired_velocity : Vector3 = direction * actor.SPEED

	actor.velocity = lerp(actor.velocity, desired_velocity, 0.15)

	if actor.velocity != Vector3.ZERO:
		actor.look_at(actor.position + actor.velocity.normalized())
		actor.basis = actor.basis.orthonormalized()

	actor.body.rotation.x -= TAU * delta

	actor.move_and_slide()


func get_new_destination() -> void:
	var destination : int = actor.a_star.get_closest_point(Globals.player.position)

	path = actor.a_star.get_point_path(actor.a_star.get_closest_point(actor.position), destination)
	path.remove_at(0)
	if path.size() > 0:
		waypoint = path[0]
	else:
		transition.emit("Idle")