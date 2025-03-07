extends CanvasLayer
class_name BigMap

@export var map_hex_scene : PackedScene
@export var small_map_hex_scene : PackedScene

@onready var map : Node3D = $SubViewportContainer/SubViewport/Map
@onready var camera : Camera3D = $SubViewportContainer/SubViewport/Camera3D


var is_dragging : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size = clamp(camera.size - 5, 10, 100)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size = clamp(camera.size + 5, 10, 100)

		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
		elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		camera.position.x -= event.relative.x * 0.075
		camera.position.z -= event.relative.y * 0.075

func _ready() -> void:
	redraw()
	camera.position = Globals.maze[Globals.player.current_room].position + Vector3.UP * 10



func redraw():
	var map_hex : MapHex
	for hex : Vector3i in Globals.maze:
		if !Globals.maze[hex].discovered or Globals.map_dict.has(hex):
			continue
		if Globals.maze[hex].type == CellData.Type.NORMAL:
			map_hex = map_hex_scene.instantiate()
		else:
			map_hex = small_map_hex_scene.instantiate()

		map_hex.initialize(Globals.maze[hex])

		map_hex.position = Globals.maze[hex].position
		map_hex.position.y = 0
		$SubViewportContainer/SubViewport/Map.call_deferred("add_child", map_hex)