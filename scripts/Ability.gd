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
signal started_cooldown(duration)
signal finished_cooldown()

export var cooldown_default = 0.5
var cooldown_timer = 0
export var cast_delay = 0.5
var cast_timer = 0
var active = AbilityState.INACTIVE

export var charge_priority = 50
export var active_priority = 50


func is_ready() -> bool:
	return cooldown_timer <= 0 && active == AbilityState.INACTIVE
	
func get_priority() -> int:
	if active == AbilityState.CHARGING:
		return charge_priority
	if active == AbilityState.ACTIVE:
		return active_priority
		
	return 0
	
func attempt_cast(current_priority) -> bool:
	if !is_ready() || current_priority >= charge_priority:
		return false
	_set_active(AbilityState.CHARGING)
	return true
	
func cancel_cast() -> void:
	_set_active(AbilityState.INACTIVE)

func _handle_inactivate(_active) -> void:
	cast_timer = 0
	if _active == AbilityState.ACTIVE:
		cooldown_timer = cooldown_default
		emit_signal("started_cooldown", cooldown_timer)
	emit_signal("inactivated", _active)

func _handle_charge(_active) -> void:
	cast_timer = cast_delay
	emit_signal("charging", _active)

func _handle_activate(_active) -> void:
	emit_signal("activated", _active)

func _set_active(_active) -> void:
	if _active == AbilityState.INACTIVE && active != AbilityState.INACTIVE:
		_handle_inactivate(active)
	if _active == AbilityState.CHARGING && active != AbilityState.CHARGING:
		_handle_charge(active)
	if _active == AbilityState.ACTIVE && active != AbilityState.ACTIVE:
		_handle_activate(active)
	active = _active

func update(delta, cast_pos) -> void:
	if active == AbilityState.INACTIVE:
		_update_inactive(delta, cast_pos)
	if active == AbilityState.CHARGING:
		_update_charging(delta, cast_pos)
	if active == AbilityState.ACTIVE:
		_update_active(delta, cast_pos)
	
func _update_inactive(delta, cast_pos) -> void:
	cooldown_timer -= delta
	if cooldown_timer <= 0 && cooldown_timer + delta >= 0:
		emit_signal("finished_cooldown")
	
func _update_charging(delta, cast_pos) -> void:
	cast_timer -= delta
	if cast_timer <= 0:
		_set_active(AbilityState.ACTIVE)
	
func _update_active(delta, cast_pos) -> void:
	pass
	
