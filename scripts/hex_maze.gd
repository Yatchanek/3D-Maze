extends Node3D

@export var MAZE_SIZE : int = 3
@export var SMALL_ROOM_RATIO : float = 0.15
@export var CULL_DISTANCE : int = 1
@export_range(0., 1.0) var connectivity_ratio : float = 0.25
@export var hex_room_scene: PackedScene
@export var small_hex_room_scene: PackedScene
@export var basic_enemy_scene : PackedScene
@export var seeker_enemy_scene : PackedScene

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

var room_dict : Dictionary = {}

var a_star : AStar3D = AStar3D.new()

var thread : Thread

var rooms_to_add : Array[HexRoom] = []

var current_room : Vector3i

var enemy_array : Array[Enemy] = []

var max_enemies : int = 10

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _ready() -> void:
	thread = Thread.new()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	create_cells_and_grid()
	create_maze()
	break_walls()
	Globals.maze = maze
	current_room = Vector3i.ZERO
	thread.start(build_maze)

	player.position.y = maze[Vector3i.ZERO].position.y
	player.start()

func create_cells_and_grid():
	for q in range(-MAZE_SIZE, MAZE_SIZE + 1):
		for r in range(-MAZE_SIZE, MAZE_SIZE + 1):
			for s in range(-MAZE_SIZE, MAZE_SIZE + 1):
				if q + r + s == 0:
					var cell_data = CellData.new()
					cell_data.coords = Vector3i(q, r, s)
					cell_data.id = a_star.get_available_point_id()
					cell_data.position = Vector3(q * (1.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * cos (PI / 6)), randf_range(0, -1.5), q * (sqrt(3) * 0.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * 0.5)+ r * (sqrt(3) * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH))
					if randf() < SMALL_ROOM_RATIO:
						pass
						#cell_data.type = cell_data.Type.SMALL
					maze[Vector3i(q, r, s)] = cell_data
					a_star.add_point(cell_data.id, cell_data.position)

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

			var middle_point : Vector3 = (maze[current].position + maze[next].position) * 0.5
			var new_id : int = a_star.get_available_point_id()
			a_star.add_point(new_id, middle_point)
			a_star.connect_points(maze[current].id, new_id)
			a_star.connect_points(new_id, maze[next].id)
			
			

			current = next
			unvisited.erase(current)
		elif stack.size() > 0:
			current = stack.pop_back()
		else:
			break

func get_neighbours(cell: Vector3i, unvisited: Array) -> Array[Vector3i]:
	var neighbours: Array[Vector3i] = []
	for dir in walls.keys():
		var neighbour: Vector3i = cell + dir
		if unvisited.has(neighbour):
			neighbours.append(neighbour)

	return neighbours


func get_cells_in_range(coords: Vector3i, dist : int) -> Array[Vector3i]:
	var cells : Array[Vector3i] = []
	for q : int in range(-dist, dist + 1):
		for r : int in range(max(-dist, -q - dist), min(dist, -q + dist) + 1):
			var s : int = -q - r
			var result : Vector3i = coords + Vector3i(q, r, s)

			if maze.has(result):
				cells.append(coords + Vector3i(q, r, s))

	return cells

func build_maze():
	var neighbours : Array[Vector3i] = get_cells_in_range(Vector3i.ZERO, CULL_DISTANCE)
	for cell in neighbours:
		create_room(cell)

	call_deferred("_on_rooms_created", true)

func create_room(coords : Vector3i):
	var hex_room: HexRoom
	if maze[coords].type == CellData.Type.NORMAL:
		hex_room = hex_room_scene.instantiate()
	else:
		hex_room = small_hex_room_scene.instantiate()
	hex_room.room_data = maze[coords]
	hex_room.entered.connect(_on_room_entered)
	rooms_to_add.append(hex_room)
	room_dict[coords] = hex_room	

func adjust_visibility():
	var neighbours : Array[Vector3i] = get_cells_in_range(current_room, CULL_DISTANCE)
	for neighbour in neighbours:
		if !room_dict.has(neighbour):
			create_room(neighbour)
		elif neighbour != current_room:
			room_dict[neighbour].call_deferred("enable_detector")

	for room in room_dict.keys():
		if !neighbours.has(room):
			room_dict[room].queue_free()
			room_dict.erase(room)

	call_deferred("_on_rooms_created")
	

func hide_distant_rooms():
	var neighbours : Array[Vector3i] = get_cells_in_range(current_room, 1)
	for room in room_dict.keys():
		if neighbours.has(room):
			room_dict[room].make_visible()
		else:
			room_dict[room].make_invisible()

func break_walls():
	var walls_to_break : int = floori(maze.size() * connectivity_ratio)
	var unvisited : Array[Vector3i] = []
	
	for cell in maze.keys():
		unvisited.append(cell)
	var fails : int = 0
	for i in range(walls_to_break):
		if fails == 10:
			break
		var cell: Vector3i = unvisited.pick_random()
		var neighbours : Array[Vector3i] = get_neighbours(cell, unvisited)
		if neighbours.size() == 0:
			fails += 1
			continue
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
			var middle_point : Vector3 = (maze[cell].position + maze[neighbour].position) * 0.5
			var new_id = a_star.get_available_point_id()
			a_star.add_point(new_id, middle_point)
			a_star.connect_points(maze[cell].id, new_id)
			a_star.connect_points(new_id, maze[neighbour].id)

		
		unvisited.erase(cell)

func spawn_enemy():
	if enemy_array.size() >= max_enemies:
		return

	var neighbours : Array[Vector3i]= get_cells_in_range(Vector3i.ZERO, 1)

	var start_tick : int = randi_range(0, 5)
	var pos : Vector3i = maze.keys().pick_random()
	while neighbours.has(pos):
		pos = maze.keys().pick_random()

	var enemy : Enemy
	if randf() < 0.88:
		enemy = basic_enemy_scene.instantiate()
	else:
		enemy = seeker_enemy_scene.instantiate()
	enemy.position = maze[pos].position
	enemy.a_star = a_star
	enemy.tick = start_tick
	enemy.current_room = pos
	enemy.died.connect(_on_enemy_destroyed)
	enemy_array.append(enemy)

	call_deferred("add_child", enemy)


func _on_rooms_created(first_time : bool = false):
	if thread.is_started():
		thread.wait_to_finish()
		for room in rooms_to_add:
			call_deferred("add_child", room)

		rooms_to_add = []
		if first_time:
			await get_tree().process_frame
			room_dict[Vector3i.ZERO].call_deferred("disable_detector")
	else:
		for room in rooms_to_add:
			call_deferred("add_child", room)

		rooms_to_add = []
		if first_time:
			await get_tree().process_frame
			room_dict[Vector3i.ZERO].call_deferred("disable_detector")

func _on_room_entered(coords : Vector3i):
	current_room = coords
	room_dict[current_room].call_deferred("disable_detector")
	thread.start(adjust_visibility)

func _process(_delta: float) -> void:
	orth_camera.position = Vector3(player.position.x, 5, player.position.z)


func _on_player_grenade_thrown(grenade: RigidBody3D, impulse: Vector3) -> void:
	grenade.apply_central_impulse(impulse)
	call_deferred("add_child", grenade)

func _on_enemy_destroyed(enemy : Enemy):
	enemy_array.erase(enemy)

func _on_timer_timeout() -> void:
	spawn_enemy()
