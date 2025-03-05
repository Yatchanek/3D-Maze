extends Node3D


func _on_animation_player_animation_finished(_anim_name:StringName) -> void:
	await get_tree().create_timer(randf_range(1.5, 2.0)).timeout
	if is_inside_tree():
		$AnimationPlayer.play("Slash")
