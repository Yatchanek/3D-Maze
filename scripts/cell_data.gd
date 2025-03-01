extends Resource
class_name CellData

enum Type {
    NORMAL,
    SMALL
}


var coords : Vector3i = Vector3i(0, 0, 0)
var id : int = 0
var layout : int = 0
var position : Vector3 = Vector3(0, 0, 0)
var exits : Array[bool] = []
var corridors : Array[bool] = [false, false, false, false, false, false]
var guillotines : Array[bool] = []
var type : Type = Type.NORMAL
var has_hole : bool = false

var coins : PackedInt32Array = []
var corridor_coins : Array[PackedInt32Array] = []
