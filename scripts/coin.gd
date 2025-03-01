extends Area3D
class_name Coin

var idx : int = 0

var is_corridor_coin : bool = false

var rotation_offset : float
var float_offset : float
var base_pos_y : float

signal picked(index : int)

func _ready() -> void:
	rotation_offset = randf_range(0, PI)
	float_offset = randf_range(0, PI)
	base_pos_y = position.y

func _on_body_entered(body:Node3D) -> void:
	if body is Player:
		picked.emit(idx)
		queue_free()

func _process(delta: float) -> void:
	rotation.y += (PI + rotation_offset) * delta * 0.75
	position.y = base_pos_y + 0.1 * sin(rotation.y) * 0.5