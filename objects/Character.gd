extends CollisionObject

class_name Character

enum AbilityIndex {
	ABILITY_1 = 0,
	ABILITY_2 = 1,
	ABILITY_3 = 2,
	ABILITY_4 = 3,
	ABILITY_5 = 4,
	ENERGY_ABILITY = 5,
	ULTIMATE_ABILITY = 6
}

enum Team {
	TEAM_1 = 2,
	TEAM_2 = 4
}

const CHARACTER_GROUP = "Character"
const TEAM_1_GROUP = "Team1"
const TEAM_2_GROUP = "Team2"

var _team = Team.TEAM_1
export var max_health: int = 100
var health: int = max_health
export var speed = 14
export (Array, NodePath) var ability_paths := []
var velocity = Vector3.ZERO
var _direction = Vector3.ZERO
var abilities: Array = []
var status_effects: Array = []
var peer_owner_id: int = 1
var _cast_pos = Vector3.ZERO
var _cast_attempt: Array = []

var _last_cast_ability = AbilityIndex.ABILITY_1

var ability_input_name = [
	"ability_1",
	"ability_2",
	"ability_3",
	"ability_4",
	"ability_5",
	"energy_ability",
	"ultimate_ability"
	]

func init(params: Array):
	_team = params[0]
	
func _handle_team_change(team) -> void:
	_team = team
	if team == Team.TEAM_1:
		add_to_group(TEAM_1_GROUP)
	if team == Team.TEAM_2:
		add_to_group(TEAM_2_GROUP)
	collision_layer |= team

func _ready() -> void:
	_handle_team_change(_team)
	
	for ability_path in ability_paths:
		var ability = self.get_node(ability_path) as Ability
		abilities.append(ability)
		if !ability.is_connected("add_status", self, "add_status"):
			ability.connect("add_status", self, "add_status")
			ability.connect("remove_status", self, "remove_status")
			ability.connect("apply_damage", self, "apply_damage")
			ability.connect("apply_heal", self, "apply_heal")
	
func _get_ability(index) -> Ability:
	if index as int >= abilities.size():
		return null
	var ability: Ability = abilities[index as int]
	return ability
	
func _has_command_authority() -> bool:
	return !get_tree().has_network_peer() || peer_owner_id == get_tree().get_network_unique_id()
	
func _get_move_attempt() -> Vector3:
	if _has_command_authority():
		return _get_move_attempt_command()
	else:
		return _get_move_attempt_prediction()
	
func _get_move_attempt_prediction() -> Vector3:
	return _direction
	
func _get_move_attempt_command() -> Vector3:
	return Vector3.ZERO
	
func _get_cast_attempt() -> Array:
	if _has_command_authority():
		return _get_cast_attempt_command()
	else:
		return _get_cast_attempt_prediction()
	
func _get_cast_attempt_prediction() -> Array:
	return _cast_attempt
	
func _get_cast_attempt_command() -> Array:
	return []
	
func _get_cast_position() -> Vector3:
	if _has_command_authority():
		return _get_cast_position_command()
	else:
		return _get_cast_position_prediction()
	
func _get_cast_position_prediction() -> Vector3:
	return _cast_pos
	
func _get_cast_position_command() -> Vector3:
	return self.transform.origin
	
func _physics_process(delta) -> void:
	
	_direction = _get_move_attempt()

	velocity = Vector3.ZERO
	velocity.x = _direction.x * speed
	velocity.z = _direction.z * speed
	
	var statuses = status_effects.duplicate()
	for status in statuses:
		velocity = status.handle_move(velocity)
	
	
	if self.has_method("move_and_slide"):
		var me: Object = self
		me.move_and_slide(velocity, Vector3.UP)
	else:
		self.translate(_direction.normalized() * speed)
	
	# Rotate facing direction
	if _direction != Vector3.ZERO:
		$Pivot.transform = $Pivot.transform.looking_at($Pivot.transform.origin + _direction.normalized(), Vector3.UP)
	
	_cast_pos = _get_cast_position()
	if _cast_pos == null:
		_cast_pos = Vector3.ZERO
	
	var last_ability: Ability = _get_ability(_last_cast_ability)
	var current_priority = 0
	if last_ability:
		current_priority = last_ability.get_priority()
	
	var is_host = _get_network_id() == 1
	
	var requested_abilities = _get_cast_attempt()
	if is_host:
		for ability_index in requested_abilities:
			if _attempt_cast(ability_index, _last_cast_ability):
				rpc("send_cast_to_client", ability_index, _last_cast_ability)
	
	for ability_index in AbilityIndex:
		var ability: Ability = _get_ability(ability_index)
		if ability:
			ability.update(delta, _cast_pos)
	
	for status in statuses:
		status.handle_update(delta)
	
	
	var is_owner = _get_network_id() == peer_owner_id
	if _get_network_id() && (is_host || is_owner):
		rpc_unreliable("send_update", _direction, transform, requested_abilities, _cast_pos)
		var different_cast = false
		if requested_abilities.size() != _cast_attempt.size():
			different_cast = true
		else:
			for cast_index in range(requested_abilities.size()):
				if requested_abilities[cast_index] != _cast_attempt[cast_index]:
					different_cast = true
		if different_cast:
			_cast_attempt = requested_abilities
			rpc("send_cast_update", _direction, transform, requested_abilities, _cast_pos)

func should_correct_position(trans) -> bool:
	var position_change = transform.origin - trans.origin
	var distance_change = position_change.abs()
	return distance_change > velocity.abs() * 2

remote func send_update(dir, trans, requested_abilities, cast_pos) -> void:
	var from_host = get_tree().get_rpc_sender_id() == 1
	var owned = _get_network_id() == peer_owner_id
	var from_owner = get_tree().get_rpc_sender_id() == peer_owner_id
	if (from_host && !owned) || from_owner:
		_direction = dir
		if should_correct_position(trans) && get_tree().get_network_unique_id() != 1:
			transform = trans
		_cast_pos = cast_pos
		# TODO: reqab
		
	if from_host && owned && should_correct_position(trans):
		transform = trans
		
remote func send_cast_update(dir, trans, requested_abilities, cast_pos) -> void:
	var from_host = get_tree().get_rpc_sender_id() == 1
	var owned = _get_network_id() == peer_owner_id
	var from_owner = get_tree().get_rpc_sender_id() == peer_owner_id
	if (from_host && !owned) || from_owner:
		_cast_attempt = requested_abilities

func _attempt_cast(ability_index, last_cast_ability) -> bool:
	var was_cast: bool = false
	var last_ability: Ability = _get_ability(last_cast_ability)
	var current_priority = 0
	if last_ability:
		current_priority = last_ability.get_priority()
	
	var ability: Ability = _get_ability(ability_index)
	if ability && ability.attempt_cast(current_priority):
		was_cast = true
		if last_cast_ability as int != ability_index as int:
			last_ability.cancel_cast()
		_last_cast_ability = ability_index
	return was_cast

remote func send_cast_to_client(ability_index, last_cast_ability) -> void:
	_attempt_cast(ability_index, last_cast_ability)

func add_status(status: StatusEffect) -> void:
	status_effects.append(status)
	status_effects.sort_custom(StatusSorter, "sort_status_priority")
	status.handle_added(self)
	
func remove_status(status: StatusEffect) -> void:
	status_effects.remove(status_effects.find(status))
	status.handle_removed()

func apply_damage(damage: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		damage = status.handle_damage(damage)
	health -= damage
	if health <= 0:
		self.kill()

func apply_heal(heal_amount: int) -> void:
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal(heal_amount)
	health += heal_amount
	
func kill() -> void:
	pass
	
func _get_network_id() -> int:
	if get_tree().has_network_peer():
		return get_tree().get_network_unique_id()
	else:
		return -1

class StatusSorter:
	static func sort_status_priority(a: StatusEffect, b: StatusEffect):
		if a._priority < b._priority:
			return true
		return false
