extends Mover
class_name HealthOrb

export var healing = 15

var _initial_position: Vector3

func init(params: Array):
	.init([Team.WORLD, NetworkManager.HOST_ID])
	self.call("_init_HealthOrb", params[0])
	
func _init_HealthOrb(position: Vector3) -> void:
	_initial_position = position
	transform = transform.translated(position)
	collision_mask |= collision_mask << 16 # Duplicate lower 16 layers for immaterial sensing
	

func _get_move_attempt_command() -> Vector3:
	return _direction

func _handle_team_change(team) -> void:
	._handle_team_change(team)

	collision_layer ^= team


func _handle_character_hit(body: Character) -> void:
	if healing > 0:
		body.apply_heal(healing)

func _on_HealthOrb_body_entered(body):
	if body.is_in_group(Character.CHARACTER_GROUP):
		_handle_character_hit(body)
	_destroy()

func _destroy() -> void:
	NetworkManager.remove_node_instance(self.get_path())
