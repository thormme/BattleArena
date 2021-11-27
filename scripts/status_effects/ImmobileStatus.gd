extends StatusEffect
class_name ImmobileStatus

func init(params: Array): # duration: float
	.init([])
	duration = params[0]
	pass

func handle_move(movement: Vector3) -> Vector3:
	.handle_move(movement)
	return Vector3.ZERO
