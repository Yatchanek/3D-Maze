extends Area3D

var velocity : Vector3 = Vector3.ZERO
var elapsed_time : float = 0.0

func _ready() -> void:
    await get_tree().process_frame
    $SpearInHand.show()
    velocity = -basis.z * 15.0

func _physics_process(delta: float) -> void:
    elapsed_time += delta
    if elapsed_time > 10.0:
        queue_free()
    position += velocity * delta

func _on_body_entered(body : Node3D):
    $Hurtbox.disable()
    if body is Enemy:
        call_deferred("reparent", body)
    set_physics_process(false)
    await get_tree().create_timer(10.0).timeout
    if is_inside_tree():
        queue_free()