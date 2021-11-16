extends Node
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

func init(params: Array): # duration: float, priority: int, type
	_duration = params[0]
	_priority = params[1]
	_type = params[2]
	
func handle_added(target) -> void:
	_target = target
	emit_signal("status_added")

func handle_removed() -> void:
	emit_signal("status_expired")
	NetworkManager.remove_node_instance(self.get_path())

func handle_damage(damage: int) -> int:
	return damage

func handle_move(movement: Vector3) -> Vector3:
	return movement

func handle_update(delta: float) -> void:
	_duration -= delta
	if _duration <= 0 && get_tree().get_network_unique_id() == 1:
		emit_signal("status_expired")
		_target.remove_status(self)
