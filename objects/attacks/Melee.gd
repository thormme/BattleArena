extends AoE
class_name Melee

func init(params: Array):
	.init([Vector3.ZERO, params[0], params[1], params[2]])
	self.facing = params[2]

func _physics_process(delta) -> void:
	transform.origin = _caster.transform.origin
	
func set_facing(direction: Vector3) -> void:
	if direction != Vector3.ZERO:
		direction.y = 0
		facing = direction.normalized()
		transform = transform.looking_at(transform.origin + facing, Vector3.UP)
