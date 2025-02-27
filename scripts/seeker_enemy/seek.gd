extends State

var path : PackedVector3Array = []
var waypoint : Vector3

func _enter_state(_previous_state : State) -> void:
	actor.SPEED = 2.25
	actor.anim_player.speed_scale = 1.0
	actor.anim_player.play("Bite")
	get_new_destination()

func physics_update(delta : float) -> void:
	actor.tick += 1
	if actor.position.distance_squared_to(waypoint) < 0.1 * 0.1:
		get_new_destination()

	var direction : Vector3 = actor.position.direction_to(waypoint)

	actor.check_for_floor()

	if actor.is_in_instantiated_room:
		direction.y = 0
		direction = direction.normalized()

		if actor.tick % 3:
			direction = actor.get_context_steering(direction)


		if actor.target_in_range:
			elapsed_time += delta
			if elapsed_time >= 0.075:
				elapsed_time -= 0.075
				actor.target = actor.check_line_sight(actor.potential_target)
				if actor.target:
					transition.emit("Chase")

	actor.handle_movement(direction, delta)


func get_new_destination() -> void:
	var destination : int = actor.a_star.get_closest_point(Globals.player.position)
	if destination == actor.a_star.get_closest_point(actor.position):
		transition.emit("Idle")
	else:
		path = actor.a_star.get_point_path(actor.a_star.get_closest_point(actor.position), destination)

		path.remove_at(0)
		if path.size() > 0:
			waypoint = path[0]
		else:
			transition.emit("Idle")



