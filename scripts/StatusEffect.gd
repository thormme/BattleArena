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
var _caster = null
export var duration: float = 3
export var priority: int = 50
export (StatusType) var type = StatusType.ABILITY
export var remove_duplicates: bool = true

func init(params: Array): # duration: float, priority: int, type
	_caster = params[0]
	
func handle_added(target) -> void:
	_target = target
	_target.remove_status_with_filter(self, "_on_add_status_filter")
	emit_signal("status_added")

func handle_removed() -> void:
	emit_signal("status_expired")
	NetworkManager.remove_node_instance(self.get_path())

func handle_damage(initial_amount: float, amount: int, caster: Node) -> int: # caster: Mover
	return amount

func handle_heal(initial_amount: float, amount: int, caster: Node) -> int:
	return amount

func handle_damage_given(initial_amount: float, amount: int, target: Node) -> int: # target: Mover
	return amount

func handle_heal_given(initial_amount: float, amount: int, target: Node) -> int:
	return amount

func handle_heal_recovery(initial_amount: float, amount: int, caster: Node) -> int:
	return amount

func handle_energy_spent(initial_amount: float, amount: int, caster: Node) -> int:
	return amount

func handle_energy_gain(initial_amount: float, amount: int, caster: Node) -> int:
	return amount

func handle_move(initial_movement: Vector3, movement: Vector3) -> Vector3:
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
