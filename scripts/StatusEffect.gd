extends Reference
class_name StatusEffect

enum StatusType {
	ABILITY,
	BUFF,
	DEBUFF
}

signal status_removed()
signal status_added()
signal status_expired()

var _target
var _duration: float
var _priority: int
var _type

func _init(target, duration: float, priority: int, type):
	_target = target
	_duration = duration
	_priority = priority
	_type = type
	
func handle_added() -> void:
	emit_signal("status_added")

func handle_removed() -> void:
	emit_signal("status_expired")

func handle_damage(damage: int) -> int:
	return damage

func handle_move(movement: Vector3) -> Vector3:
	return movement

func handle_update(delta: float) -> void:
	_duration -= delta
	if _duration <= 0:
		emit_signal("status_expired")
		_target.remove_status(self)
