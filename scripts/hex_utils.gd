extends Node
class_name HexUtils

static func get_position(coords : Vector3i):
    return Vector3(coords.x * (1.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * cos (PI / 6)), randf_range(0, -1.5), coords.x * (sqrt(3) * 0.5 * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH * 0.5) + coords.y * (sqrt(3) * Globals.HEX_SIZE + Globals.CORRIDOR_LENGTH))