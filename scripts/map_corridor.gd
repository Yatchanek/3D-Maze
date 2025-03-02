extends Node3D
class_name MapCorridor

func initialize(length : float):
    $Floor.mesh.size.y = length
