extends Node3D

@export var MAZE_SIZE : int = 3
@export var SMALL_ROOM_RATIO : float = 0.2
@export var CULL_DISTANCE : int = 2
@export var VIEW_DISTANCE : int = 4
@export_range(0., 1.0) var connectivity_ratio : float = 0.25
@export var hex_room_scene: PackedScene
@export var small_hex_room_scene: PackedScene
@export var basic_enemy_scene : PackedScene
@export var seeker_enemy_scene : PackedScene
@export var little_enemy_scene : PackedScene
@export var chest_scene : PackedScene

@export var map_hex_scene : PackedScene
@export var small_map_hex_scene : PackedScene

@onready var orth_camera : Camera3D = %OrthCamera
@onready var player = $Player
@onready var rooms_node : Node3D = $Rooms
@onready var chests_node : Node3D = $Chests
@onready var map : Node3D = $Map

var walls: Dictionary = {
	Vector3i(0, -1, 1): Globals.N,
	Vector3i(1, -1, 0): Globals.NE,
	Vector3i(1, 0, -1): Globals.SE,
	Vector3i(0, 1, -1): Globals.S,
	Vector3i(-1, 1, 0): Globals.SW,
	Vector3i(-1, 0, 1): Globals.NW
}

var rotations : Dictionary = {
	Vector3i(0, -1, 1): 0,
	Vector3i(1, -1, 0): -60,
	Vector3i(1, 0, -1): -120,
	Vector3i(0, 1, -1): -180,
	Vector3i(-1, 1, 0): -240,
	Vector3i(-1, 0, 1): -300	
}


var maze: Dictionary[Vector3i, CellData] = {}

var room_dict : Dictionary[Vector3i, HexRoom] = {}
var map_dict : Dictionary[Vector3i, MapHex] = {}

var chests : Array[Vector3i] = []

var a_star : AStar3D = AStar3D.new()

var thread : Thread

var rooms_to_add : Array[HexRoom] = []
var map_hexes_to_add : Array[MapHex] = []

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
	for data : CellData in maze.values():
		HexUtils.define_corridors(data)

	var start_pos : Vector3i = maze.keys().pick_random()
	current_room = start_pos
	player.current_room = start_pos
	chests.append(start_pos)
	thread.start(instantiate_rooms)	
	player.position = maze[current_room].position
	spawn_chests()
	player.start()

func create_cells_and_grid():
	for q in range(-MAZE_SIZE, MAZE_SIZE + 1):
		for r in range(-MAZE_SIZE, MAZE_SIZE + 1):
			for s in range(-MAZE_SIZE, MAZE_SIZE + 1):
				if q + r + s == 0:
					var cell_data = CellData.new()
					cell_data.coords = Vector3i(q, r, s)
					cell_data.id = a_star.get_available_point_id()
					cell_data.position = HexUtils.get_position(cell_data.coords)
					if randf() < SMALL_ROOM_RATIO:
						cell_data.type = cell_data.Type.SMALL
						cell_data.room_size = Globals.SMALL_HEX_SIZE
					maze[Vector3i(q, r, s)] = cell_data
					a_star.add_point(cell_data.id, cell_data.position + Vector3.UP * 0.05)


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

			add_astar_point_in_corridor(current, next)

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


func create_room(coords : Vector3i):
	var hex_room: HexRoom
	if maze[coords].type == CellData.Type.NORMAL:
		hex_room = hex_room_scene.instantiate()
	else:
		hex_room = small_hex_room_scene.instantiate()

	hex_room.initialize(maze[coords])
	hex_room.entered.connect(_on_room_entered)
	rooms_node.call_deferred("add_child", hex_room)
	room_dict[coords] = hex_room	

func redraw_map():
	
	var neighbours : Array[Vector3i] = HexUtils.get_cells_in_range(maze, current_room, CULL_DISTANCE)
	var map_hex : MapHex
	for neighbour in neighbours:
		if map_dict.has(neighbour):
			continue
		if maze[neighbour].type == CellData.Type.NORMAL:
			map_hex = map_hex_scene.instantiate()
		else:
			map_hex = small_map_hex_scene.instantiate()

		map_hex.initialize(maze[neighbour])

		map_hex.position = maze[neighbour].position
		map_hex.position.y = 0
		map_dict[neighbour] = map_hex
		map.call_deferred("add_child", map_hex)
	
	for hex : Vector3i in map_dict.keys():
		if !neighbours.has(hex):
			map_dict[hex].queue_free()
			map_dict.erase(hex)

	call_deferred("redraw_finished")

func redraw_finished():
	if thread.is_started():
		thread.wait_to_finish()


func instantiate_rooms():
	var rooms_to_instantiate : Array[Vector3i] = [current_room]

	for direction : Vector3i in walls.keys():
		if maze[current_room].layout & walls[direction] > 0:
			rooms_to_instantiate.append(current_room + direction)
			var i : int = 1
			while maze[current_room + direction * i].layout & walls[direction] > 0:
				rooms_to_instantiate.append(current_room + direction * (i + 1))
				i += 1
				if i > VIEW_DISTANCE:
					break
	
	for room : Vector3i in rooms_to_instantiate:
		if !room_dict.has(room):
			create_room(room)
	for room : Vector3i in room_dict.keys():
		if !rooms_to_instantiate.has(room):
			room_dict[room].queue_free()
			room_dict.erase(room)

	redraw_map()

	#call_deferred("_on_rooms_created")

func hide_distant_rooms():
	for room in room_dict.keys():
		if room != current_room:
			room_dict[room].toggle_visibility(false)

	for dir : Vector3i in walls.keys():
		if !maze.has(current_room + dir):
			continue
		if maze[current_room].layout & walls[dir] > 0:
			room_dict[current_room + dir].toggle_visibility(true)

			

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

			add_astar_point_in_corridor(cell, neighbour)

		
		unvisited.erase(cell)

func add_astar_point_in_corridor(from : Vector3i, to : Vector3i):
	var dir : Vector3i = to - from

	var current_room_size : float = Globals.HEX_SIZE if maze[from].type == CellData.Type.NORMAL else Globals.SMALL_HEX_SIZE
	var next_room_size : float = Globals.HEX_SIZE if maze[to].type == CellData.Type.NORMAL else Globals.SMALL_HEX_SIZE

	var cor_start = maze[from].position + Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(rotations[dir])) * sqrt(3) * current_room_size * 0.5
	var cor_end = maze[to].position + Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(rotations[-dir])) * sqrt(3) * next_room_size * 0.5

	var middle_point : Vector3 = (cor_start + cor_end) * 0.5 + Vector3.UP * 0.05
	var new_id = a_star.get_available_point_id()
	a_star.add_point(new_id, middle_point)
	a_star.connect_points(maze[from].id, new_id)
	a_star.connect_points(new_id, maze[to].id)

	# var m : MeshInstance3D = MeshInstance3D.new()
	# m.mesh = SphereMesh.new()
	# m.mesh.radius = 0.25
	# m.position = middle_point
	# add_child(m)


func spawn_chests(attempts : int = 0):
	if attempts > 50:
		chests.remove_at(0)
		return

	var chest_pos = maze.keys().pick_random()
	var valid : bool = true
	for chest : Vector3i in chests:
		if chest == chest_pos or HexUtils.distance(chest, chest_pos) < 2:
			valid = false
			break
	if valid:
		var chest : StaticBody3D = chest_scene.instantiate()
		chest.position = maze[chest_pos].position
		chests.append(chest_pos)
		maze[chest_pos].subtype = CellData.SubType.HOLE

		var possible_rotations : Array[int] = []

		var i : int = 0
		for dir : Vector3i in walls.keys():
			if maze[chest_pos].layout & walls[dir] > 0:
				possible_rotations.append(i)
			i += 1

		chest.rotation_degrees.y = possible_rotations.pick_random() * -60
		
		chests_node.call_deferred("add_child", chest)
		spawn_chests()
	else:
		attempts += 1
		spawn_chests(attempts)

func spawn_enemy():
	if enemy_array.size() >= max_enemies:
		return

	var neighbours : Array[Vector3i]= HexUtils.get_cells_in_range(maze, player.current_room, 1)

	var start_tick : int = randi_range(0, 5)
	var pos : Vector3i = maze.keys().pick_random()
	while neighbours.has(pos):
		pos = maze.keys().pick_random()

	for i in 1:
		var enemy : Enemy
		if randf() > 1.88:
			enemy = basic_enemy_scene.instantiate()
		else:
			enemy = little_enemy_scene.instantiate()
		enemy.position = maze[pos].position + Vector3.UP * 0.01 + Vector3.FORWARD.rotated(Vector3.UP, randf_range(0, TAU)) * randf_range(1, maze[pos].room_size * 0.75)
		enemy.pivot_position = maze[pos].position
		enemy.max_radius = maze[pos].room_size * 0.75 * sqrt(3)
		enemy.a_star = a_star
		enemy.tick = start_tick
		enemy.current_room = pos
		enemy.died.connect(_on_enemy_destroyed)
		enemy_array.append(enemy)
		if room_dict.has(pos):
			enemy.is_in_instantiated_room = true
		call_deferred("add_child", enemy)


func _on_rooms_created():
	if thread.is_started():
		thread.wait_to_finish()
		for room in rooms_to_add:
			rooms_node.call_deferred("add_child", room)

		# for map_hex in map_hexes_to_add:
		# 	map.add_child(map_hex)

		rooms_to_add = []		
		map_hexes_to_add = []

	else:
		for room in rooms_to_add:
			rooms_node.call_deferred("add_child", room)

		# for map_hex in map_hexes_to_add:
		# 	map.add_child(map_hex)

		rooms_to_add = []
		map_hexes_to_add = []

func _on_room_entered(coords : Vector3i):
	if player.current_room == coords:
		return
	current_room = coords
	player.current_room = coords
	if !thread.is_started():
		thread.start(instantiate_rooms)

	

func _process(_delta: float) -> void:
	orth_camera.position = Vector3(player.position.x, 5, player.position.z)


func _on_player_grenade_thrown(grenade: RigidBody3D, impulse: Vector3) -> void:
	grenade.apply_central_impulse(impulse)
	call_deferred("add_child", grenade)

func _on_enemy_destroyed(enemy : Enemy):
	enemy_array.erase(enemy)

func _on_timer_timeout() -> void:
	spawn_enemy()

func _exit_tree() -> void:
	thread.wait_to_finish()