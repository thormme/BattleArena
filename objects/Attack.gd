extends Mover
class_name Attack

export var destroy_on_contact = true
export var destroy_on_timeout = true
export var has_collision = false

func init(params: Array):
	.init([params[2]])
	self.callv("_init_Attack", params)
	
func _init_Attack(position, direction: Vector3, team: int) -> void:
	transform = transform.translated(position)
	collision_mask |= team ^ (Team.TEAM_1 | Team.TEAM_2)
	_direction = direction
	

func _get_move_attempt_command() -> Vector3:
	return _direction

func _handle_team_change(team) -> void:
	._handle_team_change(team)
	
	if !has_collision:
		collision_layer ^= team


func _handle_character_hit(body) -> void:
	print("hit")
	pass

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
