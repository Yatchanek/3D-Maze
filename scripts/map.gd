extends ColorRect
class_name MiniMap

var maze : Array[int] = []
var player : CharacterBody3D

var player_polygon : PackedVector2Array = []

func _ready() -> void:
	player_polygon.push_back(Vector2(-10, -5))
	player_polygon.push_back(Vector2(10, -0))
	player_polygon.push_back(Vector2(-10, 5))


func _draw() -> void:
	if maze.size() == 0:
		return

	for i in maze.size():
		var cell: int = maze[i]
		if cell == 0:
			var x: int = i % 25
			var y: int = i / 25
			draw_rect(Rect2((x - player.position.x) * 20  + 96, (y - player.position.z) * 20 + 96, 20, 20), Color(1, 1, 1))
			var x_form: Transform2D = Transform2D(-player.rotation.y - PI / 2, Vector2(106, 106))
			draw_polygon(x_form * player_polygon, [Color(1, 0, 0)])
			#draw_circle(Vector2(106, 106), 10, Color(1, 0, 0))

func _process(_delta: float) -> void:
	queue_redraw()
