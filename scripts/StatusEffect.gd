class_name StatusEffect

enum StatusType {
	ABILITY,
	BUFF,
	DEBUFF
}

var _target
var _duration: float
var _priority: int
var _type

func _init(target, duration: float, priority: int, type):
	_target = target
	_duration = duration
	_priority = priority
	_type = type
	
func handle_added():
	pass

func handle_removed():
	pass

func handle_damage(damage: int):
	return damage

func handle_move(movement: Vector3):
	return movement

func handle_update(delta: float):
	_duration -= delta
	if _duration <= 0:
		_target.remove_status(self)
