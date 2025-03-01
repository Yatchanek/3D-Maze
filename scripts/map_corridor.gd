extends Node3D
class_name MapCorridor

func initialize(length : float):
    $Left.mesh.size.y = length
    $Floor.mesh.size.y = length
