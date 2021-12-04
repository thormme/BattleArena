extends StatusEffect
class_name HasteStatus

func init(params: Array): # caster: Mover, duration: float
	.init([params[0]])
	duration = params[1]
	pass

func handle_move(movement: Vector3) -> Vector3:
	.handle_move(movement)
	return Vector3(movement.x * 2, 0, movement.z * 2)
