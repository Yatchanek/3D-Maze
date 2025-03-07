extends Polygon2D
class_name MapHex2D

enum Type {
    NORMAL,
    SMALL
}

var type = Type.NORMAL
var radius : float = 80.0
var width : float

func _ready() -> void:
    if type == Type.SMALL:
        radius = 50.0

    width = Globals.SQRT3 * radius * 0.5

    var points : PackedVector2Array = []
    for i in 6:
        points.push_back(Vector2(cos(i * PI / 3), sin(i * PI / 3)) * radius)
    
    polygon = points
    $Line2D.points = points