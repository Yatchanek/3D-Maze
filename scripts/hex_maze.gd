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

var a_star : AStar3D = AStar3D.new()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for q in range(-2, 3):
		for r in range(-2, 3):
			for s in range(-2, 3):
				if q + r + s == 0:
					var cell_data = CellData.new()
					cell_data.coords = Vector3i(q, r, s)
					cell_data.id = a_star.get_available_point_id()
					cell_data.position = Vector3(q * 1.5 * Globals.HEX_SIZE, 0, sqrt(3) * Globals.HEX_SIZE * 0.5 * q + r * sqrt(3) * Globals.HEX_SIZE)
					maze[Vector3i(q, r, s)] = cell_data
					a_star.add_point(cell_data.id, cell_data.position)

	create_maze()
	break_walls()
	build_maze()
	$Enemy.position = maze[Vector3i(-1, 0, 1)].position
	$Enemy.a_star = a_star
	$Enemy.get_new_destination()
	player.start()



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
			maze[current].layout |= walls[dir]
			maze[next].layout |= walls[-dir]
			a_star.connect_points(maze[current].id, maze[next].id)

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
		hex_room.position = maze[cell].position
		#print(hex_room.position)
		hex_room.layout = maze[cell].layout
		add_child(hex_room)


func break_walls():
	
	var walls_to_break : int = floori(maze.size() * 0.25)
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
		while maze[cell].layout & walls[dir] != 0:
			if neighbours.size() == 0:
				found = false
				break
			neighbour = neighbours.pop_back()
			dir = neighbour - cell
			
		if found:
			maze[cell].layout |= walls[dir]
			maze[neighbour].layout |= walls[-dir]
			a_star.connect_points(maze[cell].id, maze[neighbour].id)

		
		unvisited.erase(cell)


func _process(_delta: float) -> void:
	orth_camera.position = Vector3(player.position.x, 5, player.position.z)
