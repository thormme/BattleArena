extends AoE
class_name Melee

func init(params: Array):
	.init([Vector3.ZERO, params[0], params[1]])

func _physics_process(delta) -> void:
	transform.origin = _caster.transform.origin
	
