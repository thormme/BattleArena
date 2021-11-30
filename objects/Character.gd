extends Mover
class_name Character

const CHARACTER_GROUP = "Character"

signal damaged(new_health, amount, recovery_health)
signal healed(new_health, amount, change)
signal healed_recovery(new_health, amount, change)
signal health_set(new_health, recovery_health)
signal killed()
signal got_focus()
signal lost_focus()

export var max_health: int = 100
export var recovery_health_buffer = 40
var recovery_health: int = max_health
var health: int = max_health

func _ready():
	emit_signal("health_set", health, recovery_health)

func apply_damage(damage: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		damage = status.handle_damage(damage)
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_damage(damage)
		rpc("_send_damage", damage)

remote func _send_damage(damage: int) -> void:
	health -= damage
	if health < recovery_health - recovery_health_buffer:
		recovery_health = health + recovery_health_buffer
	emit_signal("damaged", health, damage, recovery_health)
	if health <= 0:
		self._send_kill()

func apply_heal(heal_amount: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal(heal_amount)
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_heal(heal_amount)
		rpc("_send_heal", heal_amount)
	
remote func _send_heal(heal_amount: int) -> void:
	var starting_health: int = health
	health += heal_amount
	if health > recovery_health:
		health = recovery_health
	var change = health - starting_health
	emit_signal("healed", health, heal_amount, change)


func apply_heal_recovery(heal_amount: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal_recovery(heal_amount)
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_heal_recovery(heal_amount)
		rpc("_send_heal_recovery", heal_amount)
	
remote func _send_heal_recovery(heal_amount: int) -> void:
	var starting_recovery_health: int = recovery_health
	recovery_health += heal_amount
	if recovery_health > max_health:
		recovery_health = max_health
	var change = health - starting_recovery_health
	emit_signal("healed_recovery", recovery_health, heal_amount, change)

func kill() -> void:
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_kill()
		rpc("_send_kill")

remote func _send_kill() -> void:
	emit_signal("killed")
