extends PickableObject

@onready var mesh: MeshInstance3D = $MeshInstance3D

var is_corridor_coin : bool = false

var rotation_offset : float
var float_offset : float
var base_pos_y : float
var rotation_speed : float


func _ready() -> void:
	if type == CellData.ObjectType.HEALTH_POTION:
		mesh.set_surface_override_material(0, load("res://materials/health_potion_material.tres"))
	else:
		mesh.set_surface_override_material(0, load("res://materials/stamina_potion_material.tres"))

	rotation_offset = randf_range(0, PI)
	float_offset = randf_range(0, PI)
	rotation_speed = randf_range(PI / 3, PI * 0.75)
	base_pos_y = position.y

func _on_body_entered(body:Node3D) -> void:
	if body is Player:
		picked.emit(idx, type)
		queue_free()

func _process(delta: float) -> void:
	rotation.y += (rotation_speed + rotation_offset) * delta
	position.y = base_pos_y + 0.1 * sin(rotation.y) * 0.5