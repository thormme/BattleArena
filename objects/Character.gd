extends Mover
class_name Character

const CHARACTER_GROUP = "Character"

signal damaged(new_health, amount, recovery_health, caster)
signal healed(new_health, amount, change, caster)
signal healed_recovery(new_health, amount, change, caster)
signal health_set(new_health, recovery_health, max_health)
signal killed(caster)
signal got_focus()
signal lost_focus()

signal spent_energy(new_energy, amount, change, caster)
signal gained_energy(new_energy, amount, change, caster)
signal energy_set(new_energy, max_energy, caster)

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

# Damage the character by damage hitpoints
# Modified by any applies status effects
# caster: The Mover that cast the damage, can be null
func apply_damage(damage: int, caster: Mover) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		damage = status.handle_damage(damage, caster)
	
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = ""
		if caster != null:
			caster_path = caster.get_path()
		
		_send_damage(damage, caster_path)
		rpc("_send_damage", damage, caster_path)

remote func _send_damage(damage: int, caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	health -= damage
	if health < recovery_health - recovery_health_buffer:
		recovery_health = health + recovery_health_buffer
	emit_signal("damaged", health, damage, recovery_health, caster)
	if health <= 0:
		self.kill(caster)

func apply_heal(heal_amount: int, caster: Mover) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal(heal_amount, caster)
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = _caster_to_path(caster)
		
		_send_heal(heal_amount, caster_path)
		rpc("_send_heal", heal_amount, caster_path)
	
remote func _send_heal(heal_amount: int, caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	var starting_health: int = health
	health += heal_amount
	if health > recovery_health:
		health = recovery_health
	var change = health - starting_health
	emit_signal("healed", health, heal_amount, change, caster)


func apply_heal_recovery(heal_amount: int, caster: Mover) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal_recovery(heal_amount, caster)
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = _caster_to_path(caster)
		
		_send_heal_recovery(heal_amount, caster_path)
		rpc("_send_heal_recovery", heal_amount, caster_path)
	
remote func _send_heal_recovery(heal_amount: int, caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	var starting_recovery_health: int = recovery_health
	recovery_health += heal_amount
	if recovery_health > max_health:
		recovery_health = max_health
	var change = health - starting_recovery_health
	emit_signal("healed_recovery", recovery_health, heal_amount, change, caster)

func kill(caster: Mover) -> void:
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = _caster_to_path(caster)
		_send_kill(caster_path)
		rpc("_send_kill")

remote func _send_kill(caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	emit_signal("killed", caster)


func spend_energy(amount: int, caster: Mover) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		amount = status.handle_energy_spent(amount, caster)
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = _caster_to_path(caster)
		
		_spend_energy(amount, caster_path)
		rpc("_spend_energy", amount, caster_path)

remote func _spend_energy(amount: int, caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	var starting_energy: int = energy
	energy -= amount
	if energy < 0:
		energy = 0
	var change = energy - starting_energy
	emit_signal("spent_energy", energy, amount, change, caster)

func gain_energy(amount: int, caster: Mover) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		amount = status.handle_energy_gain(amount, caster)
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = _caster_to_path(caster)
		
		_gain_energy(amount, caster_path)
		rpc("_gain_energy", amount, caster_path)
	
remote func _gain_energy(amount: int, caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	var starting_energy: int = energy
	energy += amount
	if energy > max_energy:
		energy = max_energy
	var change = energy - starting_energy
	emit_signal("gained_energy", energy, amount, change, caster)


func change_max_energy(new_max_energy: int, caster: Mover) -> void:
	if _get_network_id() == NetworkManager.HOST_ID:
		var caster_path = _caster_to_path(caster)
		
		_send_change_max_energy(new_max_energy, caster_path)
		rpc("_send_change_max_energy", new_max_energy, caster_path)
	
remote func _send_change_max_energy(new_max_energy: int, caster_path: String) -> void:
	var caster: Mover = _path_to_caster(caster_path)
	var starting_max_energy: int = max_energy
	max_energy = new_max_energy
	var change = max_energy - starting_max_energy
	emit_signal("energy_set", energy, max_energy, caster)

# TODO: Move to ability or some better place
# Spend cast energy
func _handle_Ability_charging(_prev_state, ability): # Ability.AbilityState
	if _prev_state == Ability.AbilityState.INACTIVE:
		spend_energy(ability.energy_cost, self)
		
# TODO: Move to ability or some better place
# Refund cast energy on cancel
func _handle_Ability_inactivated(_prev_state, ability): # Ability.AbilityState
	if _prev_state == Ability.AbilityState.CHARGING:
		gain_energy(ability.energy_cost, self)


func _caster_to_path(caster: Mover) -> String:
		var caster_path = ""
		if caster != null:
			caster_path = caster.get_path()
		return caster_path

func _path_to_caster(caster_path: String) -> Mover:
	var caster: Mover = null
	if caster_path != "":
		caster = get_node(caster_path)
	return caster
