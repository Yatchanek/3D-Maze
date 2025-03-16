
extends Node3D
class_name MapHex

var coords : Vector3i

func initialize(room_data : CellData):
    coords = room_data.coords
    for i in 6:
        var corridor : MapCorridor = $Corridors.get_child(i)
        var offset : int = 0
        if room_data.map_corridors[i] == CorridorSlope.Type.NONE:
            var neighbour : Vector3i = room_data.coords + Globals.directions[i]
            if Globals.maze.has(neighbour) and !Globals.maze[neighbour].discovered:
                var neighbour_corridor_data : CorridorSlope.Type = Globals.maze[neighbour].map_corridors[wrapi(i + 3, 0, 6)]
                if neighbour_corridor_data == CorridorSlope.Type.NONE:
                    corridor.queue_free()
                elif neighbour_corridor_data == CorridorSlope.Type.SEMI_LONG_MINUS:
                    neighbour_corridor_data = CorridorSlope.Type.SEMI_LONG_PLUS
                elif neighbour_corridor_data == CorridorSlope.Type.SEMI_LONG_PLUS:
                    neighbour_corridor_data = CorridorSlope.Type.SEMI_LONG_MINUS

                room_data.map_corridors[i] = neighbour_corridor_data
    
                Globals.maze[neighbour].map_corridors[wrapi(i + 3, 0, 6)] = CorridorSlope.Type.NONE
            else:
                corridor.queue_free()

        if room_data.map_corridors[i] == 1:
            corridor.initialize(Globals.CORRIDOR_LENGTH + 0.2)
        elif room_data.map_corridors[i] == 2:
            corridor.initialize(Globals.CORRIDOR_LONG_LENGTH + 0.2)
        elif room_data.map_corridors[i] == 1.5:
            corridor.initialize(Globals.CORRIDOR_SEMI_LONG_LENGTH + 0.2)
            offset = 1
        else:
            corridor.initialize(Globals.CORRIDOR_SEMI_LONG_LENGTH + 0.2)
            offset = -1
        corridor.rotation_degrees.y = i * -60
        var direction : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, corridor.rotation.y)

        corridor.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.5) + offset * direction * sqrt(3) * (Globals.HEX_SIZE - Globals.SMALL_HEX_SIZE) * 0.25

func _ready() -> void:
    await get_tree().create_timer(0.075).timeout
    show()
