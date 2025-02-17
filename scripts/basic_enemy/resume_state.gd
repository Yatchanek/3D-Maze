extends State

func _enter_state(_previous_state : State) -> void:
    actor.waypoint = actor.a_star.get_point_position(actor.a_star.get_closest_point(actor.position))


func physics_update(_delta : float) -> void:
    var direction : Vector3 = actor.position.direction_to(actor.waypoint)
    if actor.position.distance_squared_to(actor.waypoint) < 0.15 * 0.15:
        transition.emit("Patrol")

    actor.handle_movement(direction)