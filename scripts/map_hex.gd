extends Node3D
class_name MapHex

var coords : Vector3i

func initialize(room_data : CellData):
    coords = room_data.coords
    for i in 6:
        var corridor : MapCorridor = $Corridors.get_child(i)
        var offset : int = 0
        prints("Room corridors:", room_data.map_corridors)
        if room_data.map_corridors[i] == 0:
            var neighbour : Vector3i = room_data.coords + Globals.directions[i]
            if Globals.maze.has(neighbour) and !Globals.maze[neighbour].discovered:
                prints("Neighbour:", neighbour, "Corridor data:", Globals.maze[neighbour].map_corridors)
                var neighbour_corridor_data : float = Globals.maze[neighbour].map_corridors[wrapi(i + 3, 0, 6)]
                if neighbour_corridor_data == 0:
                    corridor.hide()
                elif neighbour_corridor_data == 1.5 or neighbour_corridor_data == -1.5:
                    neighbour_corridor_data *= -1

                room_data.map_corridors[i] = neighbour_corridor_data
    
                Globals.maze[neighbour].map_corridors[wrapi(i + 3, 0, 6)] = 0
            else:
                corridor.hide()

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
