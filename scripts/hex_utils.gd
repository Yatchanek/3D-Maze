extends Node
class_name HexUtils

static func get_position(coords : Vector3i) -> Vector3:
	return Vector3(coords.x * (1.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * cos (PI / 6)), randf_range(0, -1.5), coords.x * (sqrt(3) * 0.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * 0.5) + coords.y * (sqrt(3) * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH))


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