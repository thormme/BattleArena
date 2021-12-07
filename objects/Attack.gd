extends Mover
class_name Attack

signal hit_character(body) # body: Character

export var destroy_on_contact = true
export var destroy_on_timeout = true
export var has_collision = false
export var detect_immaterial = false
export var max_distance = 20
export var damage = 15

var _initial_position: Vector3
var _caster_path: String = ""
var _caster: Mover = null

func init(params: Array):
	.init([params[2], NetworkManager.HOST_ID])
	self.callv("_init_Attack", params)
	
func _init_Attack(position, direction: Vector3, team: int, caster_path: String) -> void:
	_caster_path = caster_path
	_initial_position = position
	transform = transform.translated(position)
	collision_mask |= team ^ (Team.TEAM_1 | Team.TEAM_2)
	if detect_immaterial:
		collision_mask |= collision_mask << 16 # Duplicate lower 16 layers for immaterial sensing
	_direction = direction

func _enter_tree() -> void:
	_caster = get_node(_caster_path)

func _get_move_attempt_command() -> Vector3:
	return _direction

func _handle_team_change(team) -> void:
	._handle_team_change(team)
	
	if !has_collision:
		collision_layer ^= team


func _handle_character_hit(body: Character) -> void:
	if damage > 0:
		body.apply_damage(damage, _caster)
	emit_signal("hit_character", body)

func _on_Attack_body_entered(body) -> void:
	if body.is_in_group(Character.CHARACTER_GROUP):
		_handle_character_hit(body)
	if destroy_on_contact:
		_destroy()

func _on_Timer_timeout() -> void:
	if destroy_on_timeout:
		_destroy()

func _destroy() -> void:
	NetworkManager.remove_node_instance(self.get_path())

func _physics_process(delta) -> void:
	if max_distance > 0:
		var to_origin: Vector3 = transform.origin - _initial_position
		if to_origin.length() >= max_distance:
			_destroy()
