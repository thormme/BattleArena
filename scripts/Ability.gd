extends Node
class_name Ability

enum AbilityState {
	INACTIVE,
	CHARGING,
	ACTIVE
}

export var cooldown_default = 0.5
var cooldown_timer = 0
export var cast_delay = 0.5
var cast_timer = 0
var active = AbilityState.INACTIVE

export var charge_priority = 50
export var active_priority = 50


func is_ready():
	return cooldown_timer <= 0 && active == AbilityState.INACTIVE
	
func get_priority():
	if active == AbilityState.CHARGING:
		return charge_priority
	if active == AbilityState.ACTIVE:
		return active_priority
		
	return 0
	
func attempt_cast(current_priority):
	if !is_ready() || current_priority >= charge_priority:
		return false
	_set_active(AbilityState.CHARGING)
	return true
	
func cancel_cast():
	_set_active(AbilityState.INACTIVE)

func _handle_inactivate(_active):
	cast_timer = 0
	if _active == AbilityState.ACTIVE:
		cooldown_timer = cooldown_default

func _handle_charge(_active):
	cast_timer = cast_delay

func _handle_activate(_active):
	pass

func _set_active(_active):
	if _active == AbilityState.INACTIVE && active != AbilityState.INACTIVE:
		_handle_inactivate(active)
	if _active == AbilityState.CHARGING && active != AbilityState.CHARGING:
		_handle_charge(active)
	if _active == AbilityState.ACTIVE && active != AbilityState.ACTIVE:
		_handle_activate(active)
	active = _active

func update(delta, cast_pos):
	if active == AbilityState.INACTIVE:
		_update_inactive(delta, cast_pos)
	if active == AbilityState.CHARGING:
		_update_charging(delta, cast_pos)
	if active == AbilityState.ACTIVE:
		_update_active(delta, cast_pos)
	
func _update_inactive(delta, cast_pos):
	cooldown_timer -= delta
	
func _update_charging(delta, cast_pos):
	cast_timer -= delta
	if cast_timer <= 0:
		_set_active(AbilityState.ACTIVE)
	
func _update_active(delta, cast_pos):
	pass
	
