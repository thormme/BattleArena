extends StatusEffect
class_name HasteStatus

func init(params: Array): # caster: Mover, duration: float
	.init([params[0]])
	duration = params[1]
	pass

func handle_move(initial_movement: Vector3, movement: Vector3) -> Vector3:
	.handle_move(initial_movement, movement)
	return Vector3(movement.x * 2, 0, movement.z * 2)
