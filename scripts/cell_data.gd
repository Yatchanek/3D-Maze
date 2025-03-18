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

enum ObjectType {
    HEALTH_POTION,
    STAMINA_POTION,
    GRENADE,
    COIN,
}

var coords : Vector3i = Vector3i(0, 0, 0)
var room_size : float = Globals.HEX_SIZE
var id : int = 0
var layout : int = 0
var position : Vector3 = Vector3(0, 0, 0)
var exits : Array[bool] = []
var corridors : Array[CorridorSlope.Type] = [
    CorridorSlope.Type.NONE, 
    CorridorSlope.Type.NONE, 
    CorridorSlope.Type.NONE, 
    CorridorSlope.Type.NONE, 
    CorridorSlope.Type.NONE, 
    CorridorSlope.Type.NONE]
var map_corridors : Array[CorridorSlope.Type] = []
var guillotines : Dictionary[int, Vector2i] = {}
var type : Type = Type.NORMAL
var subtype : SubType = SubType.NORMAL

var discovered : bool = false
var corridors_created : bool = false

var coins : PackedInt32Array = []
var corridor_coins : Array[PackedInt32Array] = []

var objects : Dictionary[ObjectType, Array] = {
    ObjectType.COIN: [],
    ObjectType.GRENADE: [],
    ObjectType.HEALTH_POTION: [],
    ObjectType.STAMINA_POTION: []
}

var has_been_instantiated : bool = false