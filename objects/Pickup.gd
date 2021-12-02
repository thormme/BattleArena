extends Mover
class_name Pickup

export var destroy_on_use = true

func init(params: Array):
	.init([Team.WORLD, NetworkManager.HOST_ID])
	self.call("_init_Pickup", params[0])
	
func _init_Pickup(position: Vector3) -> void:
	transform = transform.translated(position)
	collision_mask |= collision_mask << 16 # Duplicate lower 16 layers for immaterial sensing

func _handle_team_change(team) -> void:
	._handle_team_change(team)
	collision_layer ^= team


func _handle_character_hit(body: Character) -> void:
	pass

func _on_HealthOrb_body_entered(body):
	if body.is_in_group(Character.CHARACTER_GROUP):
		_handle_character_hit(body)
		if destroy_on_use:
			_destroy()

func _destroy() -> void:
	NetworkManager.remove_node_instance(self.get_path())
