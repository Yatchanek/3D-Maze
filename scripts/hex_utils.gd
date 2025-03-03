extends Node
class_name HexUtils

const SQRT3 : float = sqrt(3)

static func get_position(coords : Vector3i) -> Vector3:
	return Vector3(coords.x * (1.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * cos (PI / 6)), randf_range(0, -1.5), coords.x * (SQRT3 * 0.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * 0.5) + coords.y * (SQRT3 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH))


static func get_cells_in_range(maze: Dictionary, coords: Vector3i, dist : int) -> Array[Vector3i]:
	var cells : Array[Vector3i] = []
	for q : int in range(-dist, dist + 1):
		for r : int in range(max(-dist, -q - dist), min(dist, -q + dist) + 1):
			var s : int = -q - r
			var result : Vector3i = coords + Vector3i(q, r, s)

			if maze.has(result):
				cells.append(coords + Vector3i(q, r, s))

	return cells


static func distance(from: Vector3i, to : Vector3i) -> int:
	var dir : Vector3i = to - from

	return int((abs(dir.x) + abs(dir.y) + abs(dir.z)) * 0.5)

static func define_corridors(room_data : CellData):
	for i in 6:
		if 1 << i & room_data.layout > 0:
			var neighbour : Vector3i = room_data.coords + Globals.directions[i]

			if Globals.maze[neighbour].corridors[wrapi(i + 3, 0, 6)] == 0:	
				if Globals.maze[room_data.coords].type == room_data.Type.NORMAL and Globals.maze[neighbour].type == room_data.Type.NORMAL:
					room_data.corridors[i] = 1.0
				elif Globals.maze[room_data.coords].type == room_data.Type.SMALL and Globals.maze[neighbour].type == room_data.Type.SMALL:
					room_data.corridors[i] = 2.0
				elif Globals.maze[room_data.coords].type == room_data.Type.NORMAL and Globals.maze[neighbour].type == room_data.Type.SMALL:
					room_data.corridors[i] = 1.5
				else:
					room_data.corridors[i] = -1.5