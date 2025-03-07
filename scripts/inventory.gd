extends PanelContainer
class_name Inventory

@export var normal_style : StyleBoxFlat
@export var border_style : StyleBoxFlat

@onready var inventory_bar : HBoxContainer = $MarginContainer/InventoryBar

var slots : Array[PanelContainer] = []

var current_slot : int = 0

var current_slot_float : float = 0

var moving_bar : bool = false

signal slot_changed(slot : int)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			show_bar()
			current_slot_float = clampf(current_slot_float - 0.6, 0, 5.0)
			var previous_slot : int = current_slot
			current_slot = floori(current_slot_float)
			if previous_slot != current_slot:
				update()

			$Timer.start()

		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			show_bar()
			current_slot_float = clampf(current_slot_float + 0.6, 0, 5.0)
			var previous_slot : int = current_slot
			current_slot = floori(current_slot_float)
			if previous_slot != current_slot:
				update()

			$Timer.start()

func _ready() -> void:
	position.y += get_rect().size.y
	for slot in inventory_bar.get_children():
		slots.append(slot)

	update()

func update():
	for slot in slots:
		slot.add_theme_stylebox_override("panel", normal_style)
	
	slots[current_slot].add_theme_stylebox_override("panel", border_style)

func show_bar():
	if moving_bar or position.y < get_viewport_rect().size.y:
		return
	moving_bar = true
	var tw : Tween = create_tween()
	tw.finished.connect(_on_bar_move_ended)
	tw.tween_property(self, "position:y", -get_rect().size.y, 0.15).as_relative()


func hide_bar():
	if moving_bar:
		return

	moving_bar = true
	var tw : Tween = create_tween()
	tw.finished.connect(_on_bar_move_ended)
	tw.tween_property(self, "position:y", get_rect().size.y, 0.15).as_relative()

func _on_bar_move_ended():
	moving_bar = false

func _on_timer_timeout() -> void:
	slot_changed.emit(current_slot)
	hide_bar()
