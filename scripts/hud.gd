extends Control
class_name HUD

@onready var health_bar : ProgressBar = $HealthBar
@onready var red_veil : ColorRect = $RedVeil

func update_health(value : float):
    health_bar.value = value

func ouch():
    var tw : Tween = create_tween()
    tw.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
    tw.tween_property(red_veil, "modulate:a", 0.5, 0.1)
    tw.tween_property(red_veil, "modulate:a", 0.0, 0.1)