extends RigidBody3D

@onready var explosion : GPUParticles3D = $Explosion
@onready var body : MeshInstance3D = $Body
@onready var hurtbox : HurtBox = $Hurtbox

var exploded : bool = false

var elapsed_time : float = 0

func _ready() -> void:
	hurtbox.disable()
	await get_tree().create_timer(3.0).timeout
	if !exploded:
		explode()


func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time > 1.0 and linear_velocity.length_squared() < 0.1 * 0.1:
		explode()
		set_process(false)

func explode():
	exploded = true
	sleeping = true
	body.hide()
	explosion.basis = Basis.IDENTITY
	explosion.emitting = true
	hurtbox.enable()
	var tw : Tween = create_tween().bind_node(self)
	var shape : SphereShape3D = hurtbox.collision.shape
	tw.tween_property(shape, "radius", 1.75, 0.4)
	await explosion.finished
	queue_free()