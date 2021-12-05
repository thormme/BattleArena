extends StatusEffect
class_name JumpStatus

var _landing_pos: Vector3 = Vector3.ZERO
var _landing_set: bool = false
var _starting_pos: Vector3 = Vector3.ZERO
var _starting_duration: float

export var lock_landing_pos: bool = true

func set_landing_pos(landing_pos: Vector3):
	if !_landing_set || !lock_landing_pos:
		_landing_pos = landing_pos
		_landing_set = true

func init(params: Array): # caster: Mover, duration: float
	.init([params[0]])
	duration = params[1]
	_starting_duration = duration
	pass

func handle_added(target: Mover) -> void:
	.handle_added(target)
	_starting_pos = target.transform.origin

func handle_move(initial_movement: Vector3, movement: Vector3) -> Vector3:
	.handle_move(initial_movement, movement)
	var next_pos = (1 - (duration / _starting_duration)) * (_landing_pos - _starting_pos) + _starting_pos
	var change_pos = (next_pos - _target.transform.origin) * Engine.iterations_per_second
	return Vector3(change_pos.x, 0, change_pos.z)
