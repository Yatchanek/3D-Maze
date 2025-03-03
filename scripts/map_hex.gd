extends Node3D
class_name MapHex

func initialize(room_data : CellData):
    for i in 6:
        var corridor : MapCorridor = $Corridors.get_child(i)
        var offset : int = 0
        if room_data.corridors[i] == 0:
            corridor.hide()
        elif room_data.corridors[i] == 1:
            corridor.initialize(Globals.CORRIDOR_LENGTH + 0.2)
        elif room_data.corridors[i] == 2:
            corridor.initialize(Globals.CORRIDOR_LONG_LENGTH + 0.2)
        elif room_data.corridors[i] == 1.5:
            corridor.initialize(Globals.CORRIDOR_SEMI_LONG_LENGTH + 0.2)
            offset = 1
        else:
            corridor.initialize(Globals.CORRIDOR_SEMI_LONG_LENGTH + 0.2)
            offset = -1
        corridor.rotation_degrees.y = i * -60
        var direction : Vector3 = Vector3.FORWARD.rotated(Vector3.UP, corridor.rotation.y)

        corridor.position = direction * (sqrt(3) * Globals.HEX_SIZE * 0.5 + Globals.CORRIDOR_LENGTH * 0.5) + offset * direction * sqrt(3) * (Globals.HEX_SIZE - Globals.SMALL_HEX_SIZE) * 0.25
