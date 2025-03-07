extends Node
class_name Globals

static var N : int = 1
static var NE : int = 2
static var SE : int = 4
static var S : int = 8
static var SW : int = 16
static var NW : int = 32

static var exits : Array[int] = [N, NE, SE, S, SW, NW]
static var directions : Array[Vector3i] = [
    Vector3i(0, -1, 1),
	Vector3i(1, -1, 0),
	Vector3i(1, 0, -1),
	Vector3i(0, 1, -1),
	Vector3i(-1, 1, 0),
	Vector3i(-1, 0, 1)
]

static var HEX_SIZE : float = 4
static var SMALL_HEX_SIZE : float = 2.5
static var HEX_HEIGHT : int = 2
static var WALL_WIDTH : float = 0.25
static var OUTLINE_WIDTH : float = 0.5
static var CORRIDOR_LENGTH : float = 3.0
static var CORRIDOR_SEMI_LONG_LENGTH : float = CORRIDOR_LENGTH + sqrt(3) * (HEX_SIZE - SMALL_HEX_SIZE) * 0.5
static var CORRIDOR_LONG_LENGTH : float = CORRIDOR_LENGTH + sqrt(3) * (HEX_SIZE - SMALL_HEX_SIZE)
static var player : Player

static var maze : Dictionary = {}

static var map_dict : Dictionary = {}

static var SQRT3 : float = sqrt(3)
