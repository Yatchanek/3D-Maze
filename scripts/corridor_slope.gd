extends StaticBody3D
class_name CorridorSlope

@export var coin_scene : PackedScene

@onready var left_wall : MeshInstance3D = $LeftWall
@onready var left_collision : CollisionShape3D = $LeftCollision
@onready var floor_collision : CollisionShape3D = $FloorCollision
@onready var ceiling : MeshInstance3D = $Ceiling
@onready var floor_mesh : MeshInstance3D = $Floor

enum Type {
	NORMAL,
	SEMI_LONG,
	LONG
}


var index : int 

var top : float
var bottom : float
var length : float
var slope_angle : float
var slope_length : float
var offset : float

signal coin_picked(idx : int, corridor_idx : int)

func initialize(_index : int, from: float, to : float, type : Type):
	index = _index

	if type == Type.NORMAL:
		length = Globals.CORRIDOR_LENGTH
	elif type == Type.SEMI_LONG:
		length = Globals.CORRIDOR_SEMI_LONG_LENGTH
	else:
		length = Globals.CORRIDOR_LONG_LENGTH

	var h_diff : float = to - from
	slope_angle = atan2(h_diff, length)
	slope_length = abs(length / cos(slope_angle))
	offset = length * 0.5 * tan(slope_angle)

	top = from + 1.51 + offset
	bottom = from + offset

func _ready() -> void:
	left_wall.mesh.size.z = length
	left_collision.shape.size.z = length

	ceiling.rotation.x += slope_angle
	floor_mesh.rotation.x = slope_angle
	ceiling.position.y = top
	floor_mesh.position.y = bottom
	ceiling.mesh.size.y = slope_length
	floor_mesh.mesh.size.y = slope_length


	floor_collision.shape.size.z = slope_length
	floor_collision.rotation.x = slope_angle
	floor_collision.position.y = floor_mesh.position.y -0.05

	

func place_coins(coins : PackedInt32Array):
	if coins.size() == 0:
		return
	var start_position = Vector3(0, bottom - offset, 0)
	var coin_spacing : float = length / 3.0

	var coin_offset : int = 0
	var side : int  = 1
	for j in coins.size():

		if coins[j] > 0:
			var coin : Coin = coin_scene.instantiate()
			coin.position = start_position + Vector3.FORWARD * side * coin_spacing * coin_offset
			coin.position.y += 0.4 + (length * 0.5 - coin.position.z) * tan(slope_angle)
			coin.picked.connect(_on_coin_picked)
			coin.idx = j

			coin.add_to_group("Toggleables")
			add_child(coin)

			if j == 0:
				coin_offset += 1
			elif j % 2 == 0:
				coin_offset += 1
			side *= -1

func toggle_visibility(visibility : bool):
	for toggleable in get_tree().get_nodes_in_group("Toggleables"):
		toggleable.visible = visibility

func _on_coin_picked(coin_idx : int):
	coin_picked.emit(coin_idx, index)