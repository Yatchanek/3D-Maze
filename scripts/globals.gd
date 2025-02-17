extends Node
class_name Globals

static var N : int = 1
static var NE : int = 2
static var SE : int = 4
static var S : int = 8
static var SW : int = 16
static var NW : int = 32

static var exits : Array[int] = [N, NE, SE, S, SW, NW]

static var HEX_SIZE : int = 4
static var HEX_HEIGHT : int = 2
static var WALL_WIDTH : float = 0.25
static var OUTLINE_WIDTH : float = 0.5
static var CORRIDOR_LENGTH : float = 4.0
static var player : CharacterBody3D