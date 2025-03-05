extends Resource
class_name CellData

enum Type {
    NORMAL,
    SMALL
}

enum SubType {
    NORMAL,
    HOLE,
    DOME,
    HIGH
}

var coords : Vector3i = Vector3i(0, 0, 0)
var room_size : float = Globals.HEX_SIZE
var id : int = 0
var layout : int = 0
var position : Vector3 = Vector3(0, 0, 0)
var exits : Array[bool] = []
var corridors : Array[float] = [0, 0, 0, 0, 0, 0]
var map_corridors : Array[float] = []
var guillotines : Dictionary[int, Vector2i] = {}
var type : Type = Type.NORMAL
var subtype : SubType = SubType.NORMAL

var discovered : bool = false
var corridors_created : bool = false

var coins : PackedInt32Array = []
var corridor_coins : Array[PackedInt32Array] = []

var has_been_instantiated : bool = false