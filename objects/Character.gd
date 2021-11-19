extends Mover
class_name Character

const CHARACTER_GROUP = "Character"

signal damaged(new_health, amount)
signal healed(new_health, amount)
signal killed()
signal got_focus()
signal lost_focus()

export var max_health: int = 100
var health: int = max_health

func apply_damage(damage: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		damage = status.handle_damage(damage)
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_damage(damage)
		rpc("_send_damage", damage)

remote func _send_damage(damage: int):
	health -= damage
	emit_signal("damaged", health, damage)
	if health <= 0:
		self._send_kill()

func apply_heal(heal_amount: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal(heal_amount)
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_heal(heal_amount)
		rpc("_send_heal", heal_amount)
	
remote func _send_heal(heal_amount: int):
	health += heal_amount
	emit_signal("healed", health, heal_amount)

func kill() -> void:
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_kill()
		rpc("_send_kill")

remote func _send_kill() -> void:
	emit_signal("killed")
