extends Area3D
class_name Coin

var idx : int = 0

signal picked(index : int)

func _on_body_entered(body:Node3D) -> void:
	if body is Player:
		picked.emit(idx)
		queue_free()

func _process(delta: float) -> void:
	rotation.y += PI * delta