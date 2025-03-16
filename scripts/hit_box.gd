extends Area3D
class_name HitBox

@export var target : CharacterBody3D



func _on_area_entered(area:Area3D) -> void:
	print("HitBox entered")
	if area is HurtBox:
		if target.has_method("take_damage"):
			target.take_damage(area)


func _on_area_exited(area:Area3D) -> void:
	if area is HurtBox:
		if target.has_method("hurtbox_gone"):
			target.hurtbox_gone(area)
