extends Node3D

@export var hex_room_scene: PackedScene
@onready var orth_camera : Camera3D = %OrthCamera
@onready var player = $Player

var walls: Dictionary = {
	Vector3i(0, -1, 1): Globals.N,
	Vector3i(1, -1, 0): Globals.NE,
	Vector3i(1, 0, -1): Globals.SE,
	Vector3i(0, 1, -1): Globals.S,
	Vector3i(-1, 1, 0): Globals.SW,
	Vector3i(-1, 0, 1): Globals.NW
}

var maze: Dictionary = {}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for q in range(-2, 3):
		for r in range(-2, 3):
			for s in range(-2, 3):
				if q + r + s == 0:
					maze[Vector3i(q, r, s)] = 0

	create_maze()
	break_walls()
	#mini_map.player = player
	#mini_map.maze = maze
	build_maze()


func create_maze():
	var unvisited: Array[Vector3i] = []
	var stack: Array[Vector3i] = []

	for cell in maze.keys():
		unvisited.append(cell)

	var current: Vector3i = unvisited[randi() % unvisited.size()]
	unvisited.erase(current)

	while unvisited.size() > 0:
		var neighbours: Array[Vector3i] = get_neighbours(current, unvisited)
		if neighbours.size() > 0:
			var next: Vector3i = neighbours[randi() % neighbours.size()]
			stack.append(current)
			var dir: Vector3i = next - current
			maze[current] |= walls[dir]
			maze[next] |= walls[-dir]


			current = next
			unvisited.erase(current)
		elif stack.size() > 0:
			current = stack.pop_back()
		else:
			break

func get_neighbours(cell: Vector3i, unvisited: Array[Vector3i]) -> Array[Vector3i]:
	var neighbours: Array[Vector3i] = []
	for dir in walls.keys():
		var neighbour: Vector3i = cell + dir
		if unvisited.has(neighbour):
			neighbours.append(neighbour)

	return neighbours

func build_maze():
	for cell in maze.keys():
		var hex_room: HexRoom = hex_room_scene.instantiate()
		hex_room.position = Vector3(cell.x * 1.5 * Globals.HEX_SIZE, 0, sqrt(3) * Globals.HEX_SIZE * 0.5 * cell.x + cell.y * sqrt(3) * Globals.HEX_SIZE)
		hex_room.layout = maze[cell]
		add_child(hex_room)


func break_walls():
	
	var walls_to_break : int = floori(maze.size() * 0.15)
	prints("Breaking walls", walls_to_break)
	var unvisited : Array[Vector3i] = []
	for cell in maze.keys():
		unvisited.append(cell)

	for i in range(walls_to_break):
		var cell: Vector3i = unvisited.pick_random()
		var neighbours : Array[Vector3i] = get_neighbours(cell, unvisited)
		neighbours.shuffle()
		var neighbour : Vector3i = neighbours.pop_back()
		var dir: Vector3i = neighbour - cell
		var found : bool = true
		while maze[cell] & walls[dir] != 0:
			if neighbours.size() == 0:
				found = false
				break
			neighbour = neighbours.pop_back()
			dir = neighbour - cell
			
		if found:
			maze[cell] |= walls[dir]
			maze[neighbour] |= walls[-dir]
		
		unvisited.erase(cell)


func _process(_delta: float) -> void:
	orth_camera.position = Vector3(player.position.x, 5, player.position.z)
