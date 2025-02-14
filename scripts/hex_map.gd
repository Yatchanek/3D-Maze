extends ColorRect
class_name MiniMapHex

var maze : Dictionary = {}
var player_polygon : PackedVector2Array = []
var player : CharacterBody3D

const hex_size : int = 40
const hex_half_height : float = hex_size * sqrt(3) * 0.5

func _draw() -> void:
	if maze.size() == 0:
		return

	for cell in maze.keys():
		var layout : int = maze[cell]
		var x : int = cell.x
		var y : int = cell.y
		var center : Vector2 = Vector2(96, 96) -Vector2(player.position.x, player.position.z) * 10 + Vector2(x * 40 * 1.5, x * 40 * sqrt(3) * 0.5 + y * 40 * sqrt(3))
		draw_hex(center, layout)
	draw_player()

func draw_hex(center: Vector2, layout : int):
	draw_set_transform(center, 0)
	var points : PackedVector2Array = []
	for i in range(6):
		var angle : float = PI / 3 * i
		points.append(Vector2(hex_size * cos(angle), hex_size * sin(angle)))
	points.append(points[0])
	draw_polyline(points, Color(1, 1, 1), 4)
	for i in Globals.exits.size():
		if layout & Globals.exits[i] != 0:
			draw_exit(center, i)


func draw_exit(center : Vector2, idx : int):
	var angle : float = PI / 3 * idx
	draw_set_transform(center, angle)
	var points : PackedVector2Array = []
	points.append(Vector2(0, -hex_half_height) + Vector2(-10, -5))
	points.append(Vector2(0, -hex_half_height) + Vector2(10, -5))
	points.append(Vector2(0, -hex_half_height) + Vector2(10, 5))
	points.append(Vector2(0, -hex_half_height) + Vector2(-10, 5))

	draw_rect(Rect2(Vector2(0, -hex_half_height) + Vector2(-10, -5), Vector2(20, 10)), Color(0.07, 0.07, 0.07))


func draw_player():
	draw_set_transform(Vector2(96, 96), -player.rotation.y - PI / 2)
	draw_polygon(player_polygon, [Color(1, 0, 0)])

func _ready() -> void:
	player_polygon.push_back(Vector2(-10, -5))
	player_polygon.push_back(Vector2(10, -0))
	player_polygon.push_back(Vector2(-10, 5))

func _process(_delta: float) -> void:
	queue_redraw()
