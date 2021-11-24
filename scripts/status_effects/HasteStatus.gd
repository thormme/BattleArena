extends StatusEffect
class_name HasteStatus

func init(params: Array): # duration: float
	.init([])
	duration = params[0]
	pass

func handle_move(movement: Vector3) -> Vector3:
	.handle_move(movement)
	return Vector3(movement.x * 2, 0, movement.z * 2)
