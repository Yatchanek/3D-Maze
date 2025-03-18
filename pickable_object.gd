extends Area3D
class_name PickableObject

var type : CellData.ObjectType
var idx : int

signal picked(index : int, _type : CellData.ObjectType)