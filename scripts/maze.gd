extends Node3D

@onready var multi_mesh: MultiMeshInstance3D = $MultiMesh
@onready var wall_body : StaticBody3D = $Walls
@onready var ceiling : MeshInstance3D = $Ceiling
@onready var ground : MeshInstance3D = $Floor
@onready var map : ColorRect = $CanvasLayer/Control/ColorRect/Map
@onready var player : CharacterBody3D = $Player

const N: int = 1
const E: int = 2
const S: int = 4
const W: int = 8

const walls: Dictionary = {
	Vector2i(0, -2): N,
	Vector2i(2, 0): E,
	Vector2i(0, 2): S,
	Vector2i(-2, 0): W
}

const ROWS: int = 25
const COLS: int = 25

var maze: Array[int] = []

var cull_ratio: float = 0.15

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			get_tree().reload_current_scene()

func _ready() -> void:
	generate_maze()
	break_walls()
	build_maze()
	
	generate_collision_shapes()
	ceiling.mesh.size = Vector3(COLS, 1, ROWS)
	ceiling.position = Vector3(COLS * 0.5 - 0.5, 1, ROWS * 0.5 - 0.5)
	ground.position = Vector3(COLS * 0.5 - 0.5, -1, ROWS * 0.5 - 0.5)

	map.maze = maze
	map.player = player

func generate_maze():
	maze.resize(ROWS * COLS)
	maze.fill(0)

	var unvisited: Array[Vector2i] = []
	var stack: Array[Vector2i] = []

	for x in range(1, COLS, 2):
		for y in range(1, ROWS, 2):
			unvisited.append(Vector2i(x, y))
		
	var current = Vector2i(1, 1)

	while unvisited.size() > 0:
		var neighbours: Array[Vector2i] = get_neighbours(current, unvisited)
		if neighbours.size() > 0:
			var next: Vector2i = neighbours.pick_random()
			stack.append(current)
			var dir: Vector2i = next - current
			maze[current.y * COLS + current.x] |= walls[dir]
			maze[next.y * COLS + next.x] |= walls[-dir]
			if dir.x != 0:
				maze[current.y * COLS + current.x + dir.x * 0.5] = 5
			elif dir.y != 0:
				maze[(current.y + dir.y * 0.5) * COLS + current.x] = 1

			current = next
			unvisited.erase(current)
		elif stack.size() > 0:
			current = stack.pop_back()
		else:
			break

func build_maze():
	var instance_count: int = maze.filter(func(x): return x == 0).size()
	multi_mesh.multimesh.instance_count = instance_count
	var instance_num: int = 0
	for i in maze.size():
		var cell: int = maze[i]
		if cell == 0:
			var x: int = i % COLS
			var y: int = i / COLS
			
			multi_mesh.multimesh.set_instance_transform(instance_num, Transform3D(Basis(), Vector3(x, 0, y)))
			instance_num += 1


func break_walls():
	var walls_to_break : int = floori(cull_ratio * (multi_mesh.multimesh.instance_count - 2 * ROWS - 2 * COLS + 2))

	for i in walls_to_break:
		var x : int = randi_range(1, COLS - 2)
		var y : int = randi_range(1, ROWS - 2)
		var attempts : int = 0
		var found : bool = true
		while !can_cull(Vector2i(x, y)):
			x = randi_range(1, COLS - 2)
			y = randi_range(1, ROWS - 2)
			attempts += 1
			if attempts > 10:
				found = false
				break
		if found:
			maze[y * COLS + x] = 15


func can_cull(coords : Vector2i) -> bool:
	var cell : int = maze[coords.y * COLS + coords.x]
	if cell == 0:
		if maze[coords.y * COLS + coords.x + 1] == 0 and maze[coords.y * COLS + coords.x - 1] == 0 and maze[(coords.y + 1) * COLS + coords.x] != 0 and maze[(coords.y - 1) * COLS + coords.x] != 0:
			return true
		elif maze[(coords.y + 1) * COLS + coords.x] == 0 and maze[(coords.y - 1) * COLS + coords.x] == 0 and maze[coords.y * COLS + coords.x + 1] != 0 and maze[coords.y * COLS + coords.x - 1] != 0:
			return true

		else:
			return false

	else:
		return false

func is_single_cell(coords : Vector2i) -> bool:
	return maze[coords.y * COLS + coords.x + 1] != 0 and maze[coords.y * COLS + coords.x - 1] != 0 and maze[(coords.y + 1) * COLS + coords.x] != 0 and maze[(coords.y - 1) * COLS + coords.x] != 0

func get_neighbours(coords: Vector2i, unvisited: Array[Vector2i]) -> Array[Vector2i]:
	var neighbours: Array[Vector2i] = []
	for dir in walls.keys():
		var neighbour: Vector2i = coords + dir
		if unvisited.has(neighbour):
			neighbours.append(neighbour)
			
	return neighbours

func generate_collision_shapes():
	for y in ROWS:
		var mesh_start : Vector2i = Vector2i(0, 0)
		var mesh_started : bool = false
		var mesh_end : Vector2i = Vector2i(0, 0)
		for x in COLS:
			var cell : int = maze[y * COLS + x]
			if cell == 0:
				if !mesh_started:
					mesh_start = Vector2i(x, y)
					mesh_started = true
				elif x == COLS - 1:
					mesh_end = Vector2i(x + 1, y)
					if mesh_end.x - mesh_start.x == 1:
						continue
					else:
						create_collision_shape(mesh_start, mesh_end)
			elif mesh_started:
				mesh_end = Vector2i(x, y)

				mesh_started = false
				if mesh_end.x - mesh_start.x == 1:
					continue
				else:
					create_collision_shape(mesh_start, mesh_end)

	for x in COLS:
		var mesh_start : Vector2i = Vector2i(0, 0)
		var mesh_started : bool = false
		var mesh_end : Vector2i = Vector2i(0, 0)
		for y in ROWS:
			var cell : int = maze[y * COLS + x]
			if cell == 0:
				if !mesh_started:
					mesh_start = Vector2i(x, y)
					mesh_started = true
				elif y == ROWS - 1:
					mesh_end = Vector2i(x + 1, y)
					if mesh_end.y - mesh_start.y == 1:
						continue
					else:
						create_collision_shape(mesh_start, mesh_end)
			elif mesh_started:
				mesh_end = Vector2i(x, y)

				mesh_started = false
				if mesh_end.y - mesh_start.y == 1:
					if is_single_cell(mesh_start):
						create_collision_shape(mesh_start, mesh_end)
					else:
						continue
				else:
					create_collision_shape(mesh_start, mesh_end)

func create_collision_shape(mesh_start : Vector2i, mesh_end : Vector2i):
	var collision_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(max(mesh_end.x - mesh_start.x, 1), 1, max(mesh_end.y - mesh_start.y, 1))
	collision_shape.shape = shape
	collision_shape.position = Vector3(mesh_start.x + shape.size.x * 0.5 - 0.5, 0, mesh_start.y + shape.size.z * 0.5 - 0.5)
	wall_body.call_deferred("add_child", collision_shape)
			
	# var mesh : MeshInstance3D = MeshInstance3D.new()
	# mesh.mesh = BoxMesh.new()
	# mesh.mesh.size = shape.size
	# mesh.position = collision_shape.position
	# add_child(mesh)
				
