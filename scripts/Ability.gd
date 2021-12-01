extends Node
class_name Ability

enum AbilityState {
	INACTIVE,
	CHARGING,
	ACTIVE
}

signal add_status(status)
signal remove_status(status)
signal apply_damage(damage)
signal apply_heal(heal_amount)

signal inactivated(previous_state)
signal charging(previous_state)
signal activated(previous_state)
signal started_cooldown(timer)
signal finished_cooldown()

onready var cooldown_timer = $CooldownTimer
onready var cast_timer = $CastTimer
var active = AbilityState.INACTIVE
var _statuses: Dictionary = {}

# Priority when charging the ability
# Higher priority abilities are able to cancel lower prority abilities
export var charge_priority = 50
# Priority while the ability to active
# Higher priority abilities are able to cancel lower prority abilities
export var active_priority = 50

# Maximum cast distance
export var max_cast_distance = 50
# Minimum cast distance
export var min_cast_distance = 20

# Cast energy cost
export var energy_cost: int = 0


func is_ready() -> bool:
	return cooldown_timer.is_stopped() && active == AbilityState.INACTIVE
	
func get_priority() -> int:
	if active == AbilityState.CHARGING:
		return charge_priority
	if active == AbilityState.ACTIVE:
		return active_priority
		
	return 0
	
func attempt_cast(current_priority, remaining_energy: int) -> bool:
	if !is_ready() || current_priority >= charge_priority || remaining_energy < energy_cost:
		return false
	_set_active(AbilityState.CHARGING)
	return true
	
func cancel_cast() -> void:
	_set_active(AbilityState.INACTIVE)

func _handle_inactivate(_active) -> void:
	cast_timer.stop()
	if _active == AbilityState.CHARGING:
		cooldown_timer.start_cancelled()
		emit_signal("started_cooldown", cooldown_timer)
	emit_signal("inactivated", _active)

func _handle_charge(_active) -> void:
	cast_timer.start()
	emit_signal("charging", _active)

# Handle a change in ability status
# Note: Do not change activation status within this handler!
func _handle_activate(_active) -> void:
	cooldown_timer.start_default()
	emit_signal("started_cooldown", cooldown_timer)
	emit_signal("activated", _active)

func _set_active(_active) -> void:
	if _active == AbilityState.INACTIVE && active != AbilityState.INACTIVE:
		_handle_inactivate(active)
	if _active == AbilityState.CHARGING && active != AbilityState.CHARGING:
		_handle_charge(active)
	if _active == AbilityState.ACTIVE && active != AbilityState.ACTIVE:
		_handle_activate(active)
	active = _active

# Restrain cast position to min and max range
func _restrain_cast_position(cast_pos: Vector3) -> Vector3:
	var player_position: Vector3 = get_parent().transform.origin
	player_position.y = cast_pos.y
	var direction = cast_pos - player_position
	var length = direction.length()
	if length < min_cast_distance:
		length = min_cast_distance
	if length > max_cast_distance:
		length = max_cast_distance
	return direction.normalized() * length + player_position

func update(delta, cast_pos) -> void:
	var fixed_cast_pos = _restrain_cast_position(cast_pos)

	if active == AbilityState.INACTIVE:
		_update_inactive(delta, fixed_cast_pos)
	if active == AbilityState.CHARGING:
		_update_charging(delta, fixed_cast_pos)
	if active == AbilityState.ACTIVE:
		_update_active(delta, fixed_cast_pos)
	
func _update_inactive(delta, cast_pos) -> void:
	pass
	
func _update_charging(delta, cast_pos) -> void:
	pass
	
func _update_active(delta, cast_pos) -> void:
	pass

func _on_CooldownTimer_timeout() -> void:
	emit_signal("finished_cooldown")

func _on_CastTimer_timeout() -> void:
	_set_active(AbilityState.ACTIVE)
	
func apply_status(status_type: Resource, key: String, init_params: Array = [], callback_name: String = "", callback_params: Array = []):
	#var parent: Mover = get_parent()
	get_parent().apply_status(status_type.resource_path, init_params, self.get_path(), "_handle_status_created", [key] + [callback_name, callback_params])


func _handle_status_created(path: String, key: String, callback_name: String = "", callback_params: Array = []) -> void:
	var instance = get_node(path)
	_statuses[key] = instance
	instance.connect("status_expired", self, "_handle_status_expired", [key])
	if callback_name != "":
		self.callv(callback_name, [path, key] + callback_params)

func _handle_status_expired(key: String) -> void:
	_statuses.erase(key)
