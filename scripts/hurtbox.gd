extends Area3D
class_name HurtBox

@onready var collision : CollisionShape3D = $CollisionShape3D

@export var damage : float = 0

func disable():
	collision.set_deferred("disabled", true)

func enable():
	collision.set_deferred("disabled", false)
