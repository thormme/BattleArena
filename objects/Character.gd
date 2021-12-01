extends Mover
class_name Character

const CHARACTER_GROUP = "Character"

signal damaged(new_health, amount, recovery_health)
signal healed(new_health, amount, change)
signal healed_recovery(new_health, amount, change)
signal health_set(new_health, recovery_health, max_health)
signal killed()
signal got_focus()
signal lost_focus()

signal spent_energy(new_energy, amount, change)
signal gained_energy(new_energy, amount, change)
signal energy_set(new_energy, max_energy)

export var max_health: int = 100
export var recovery_health_buffer = 40
var recovery_health: int = max_health
var health: int = max_health

func _ready():
	for ability in abilities:
		ability.connect("charging", self, "_handle_Ability_charging", [ability])
		ability.connect("inactivated", self, "_handle_Ability_inactivated", [ability])
	
	emit_signal("health_set", health, recovery_health, max_health)
	emit_signal("energy_set", energy, max_energy)

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


func spend_energy(amount: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		amount = status.handle_energy_spent(amount)
	if _get_network_id() == NetworkManager.HOST_ID:
		_spend_energy(amount)
		rpc("_spend_energy", amount)

remote func _spend_energy(amount: int) -> void:
	var starting_energy: int = energy
	energy -= amount
	if energy < 0:
		energy = 0
	var change = energy - starting_energy
	emit_signal("spent_energy", energy, amount, change)

func gain_energy(amount: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		amount = status.handle_energy_gain(amount)
	if _get_network_id() == NetworkManager.HOST_ID:
		_gain_energy(amount)
		rpc("_gain_energy", amount)
	
remote func _gain_energy(amount: int) -> void:
	var starting_energy: int = energy
	energy += amount
	if energy > max_energy:
		energy = max_energy
	var change = energy - starting_energy
	emit_signal("gained_energy", energy, amount, change)


func change_max_energy(new_max_energy: int) -> void:
	if _get_network_id() == NetworkManager.HOST_ID:
		_send_change_max_energy(new_max_energy)
		rpc("_send_change_max_energy", new_max_energy)
	
remote func _send_change_max_energy(new_max_energy: int) -> void:
	var starting_max_energy: int = max_energy
	max_energy = new_max_energy
	var change = max_energy - starting_max_energy
	emit_signal("energy_set", energy, max_energy)

# TODO: Move to ability or some better place
# Spend cast energy
func _handle_Ability_charging(_prev_state, ability): # Ability.AbilityState
	if _prev_state == Ability.AbilityState.INACTIVE:
		spend_energy(ability.energy_cost)
		
# TODO: Move to ability or some better place
# Refund cast energy on cancel
func _handle_Ability_inactivated(_prev_state, ability): # Ability.AbilityState
	if _prev_state == Ability.AbilityState.CHARGING:
		gain_energy(ability.energy_cost)
