extends Area3D
class_name PickableObject

var type : ObjectData.ObjectType
var idx : int

signal picked(index : int, _type : ObjectData.ObjectType)