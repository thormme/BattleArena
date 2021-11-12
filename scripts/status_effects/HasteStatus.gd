extends StatusEffect
class_name HasteStatus

func _init(target, duration: float).(target, duration, 50, StatusEffect.StatusType.BUFF):
	pass

func handle_move(movement: Vector3) -> Vector3:
	.handle_move(movement)
	return Vector3(movement.x * 2, 0, movement.z * 2)
