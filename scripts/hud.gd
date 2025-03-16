extends Control
class_name HUD

@onready var health_bar : ProgressBar = $HealthBar
@onready var stamina_bar : ProgressBar = $StaminaBar
@onready var red_veil : ColorRect = $RedVeil
@onready var weapon_wheel : TextureRect = $WeaponWheel
@onready var weapon_selector: TextureRect = $WeaponWheel/Selector

var weapon_wheel_open : bool = false

var selector_position : float = 0

signal weapon_selected(weapon : int)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			weapon_selector.rotation = PI / 2 * Globals.player.current_weapon
			weapon_wheel.show()
			weapon_wheel_open = true
		elif !event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			weapon_wheel.hide()
			weapon_wheel_open = false
			if floori(selector_position) != Globals.player.current_weapon:
				weapon_selected.emit(floori(selector_position))

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if !weapon_wheel_open:
				return
			selector_position = wrapf(selector_position - 0.5, 0, 5)
			weapon_selector.rotation = PI / 2 * floori(selector_position)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if !weapon_wheel_open:
				return
			selector_position = wrapf(selector_position + 0.5, 0, 5)
			weapon_selector.rotation = PI / 2 * floori(selector_position)


func update_health(value : float):
	health_bar.value = value

func update_stamina(value : float):
	stamina_bar.value = value

func ouch():
	var tw : Tween = create_tween()
	tw.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tw.tween_property(red_veil, "modulate:a", 0.5, 0.1)
	tw.tween_property(red_veil, "modulate:a", 0.0, 0.1)
