extends Mover
class_name Attack

export var destroy_on_contact = true
export var destroy_on_timeout = true
export var has_collision = false
export var max_distance = 20
export var damage = 15

var _initial_position: Vector3

func init(params: Array):
	.init([params[2], NetworkManager.HOST_ID])
	self.callv("_init_Attack", params)
	
func _init_Attack(position, direction: Vector3, team: int) -> void:
	_initial_position = position
	transform = transform.translated(position)
	collision_mask |= team ^ (Team.TEAM_1 | Team.TEAM_2)
	_direction = direction
	

func _get_move_attempt_command() -> Vector3:
	return _direction

func _handle_team_change(team) -> void:
	._handle_team_change(team)
	
	if !has_collision:
		collision_layer ^= team


func _handle_character_hit(body: Character) -> void:
	if damage > 0:
		body.apply_damage(damage)

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
