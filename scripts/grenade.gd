extends RigidBody3D

@onready var explosion : GPUParticles3D = $Explosion
@onready var explosion_fragments : GPUParticles3D = $ExplosionFragments
@onready var body : MeshInstance3D = $Body
@onready var hurtbox : HurtBox = $Hurtbox
@onready var flash : OmniLight3D = $Flash

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
	basis = Basis.IDENTITY
	explosion.emitting = true
	hurtbox.enable()
	var tw : Tween = create_tween().bind_node(self)
	var shape : SphereShape3D = hurtbox.collision.shape
	tw.tween_property(shape, "radius", 1.75, 0.3)
	tw.parallel().tween_property(flash, "light_energy", 8.0, 0.3)
	tw.tween_property(flash, "light_energy", 0.0, 0.1)
	await explosion.finished
	queue_free()