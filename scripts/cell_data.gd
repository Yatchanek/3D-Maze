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
var corridors : Array[bool] = [false, false, false, false, false, false]
var type : Type = Type.NORMAL