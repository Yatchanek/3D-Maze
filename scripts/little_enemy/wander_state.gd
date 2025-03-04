extends State

var move_elapsed : float = 0.0
var move_tick : int = 0

func _enter_state(_previous_state : State) -> void:
    move_tick = 0
    move_elapsed = 0.0
    get_new_waypoint()

func physics_update(delta : float) -> void:
    move_tick += 1
    move_elapsed += delta
    if move_elapsed > 3.0:
        transition.emit("IdleState")
    
    if actor.global_position.distance_squared_to(actor.waypoint) < 0.05 * 0.05:
        transition.emit("IdleState")

    var direction : Vector3 = actor.global_position.direction_to(actor.waypoint)
    
    if move_tick % 5 == 0:
       # print("Direction: ", direction)
        direction = actor.context_steering_component.get_context_steering(direction, actor.global_rotation.y)
       # print("Steered Direction: ", direction)
    direction.y = 0.0



    actor.handle_movement(direction, delta)

func get_new_waypoint():
    actor.waypoint = actor.pivot_position + Vector3.FORWARD.rotated(Vector3.UP, randf_range(0, TAU)) * randf_range(1, actor.max_radius)
