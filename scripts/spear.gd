extends Area3D

var velocity : Vector3 = Vector3.ZERO

func _ready() -> void:

    velocity = -basis.z * 15.0

func _physics_process(delta: float) -> void:
    position += velocity * delta

func _on_body_entered(_body : Node3D):
    set_physics_process(false)
    await get_tree().create_timer(10.0).timeout
    queue_free()