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
export var duration: float = 3
export var priority: int = 50
export (StatusType) var type = StatusType.ABILITY
export var remove_duplicates: bool = true

func init(params: Array): # duration: float, priority: int, type
	pass
	
func handle_added(target) -> void:
	_target = target
	_target.remove_status_with_filter(self, "_on_add_status_filter")
	emit_signal("status_added")

func handle_removed() -> void:
	emit_signal("status_expired")
	NetworkManager.remove_node_instance(self.get_path())

func handle_damage(damage: int) -> int:
	return damage

func handle_heal(amount: int) -> int:
	return amount

func handle_move(movement: Vector3) -> Vector3:
	return movement

func handle_update(delta: float) -> void:
	duration -= delta
	if duration <= 0 && get_tree().get_network_unique_id() == 1:
		emit_signal("status_expired")
		_target.remove_status(self)

func _on_add_status_filter(status: StatusEffect) -> bool:
	if remove_duplicates:
		return status != self && status.get_script().resource_path == self.get_script().resource_path
	return false
