extends StaticBody3D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

var is_opened : bool = false



func _on_area_3d_body_entered(body:Node3D) -> void:
	if body is Player and !is_opened:
		is_opened = true
		anim_player.play("Open")

