extends Ability
class_name ExplosionAbility

const AoEAbilityScene = preload("res://objects/attacks/AoE.tscn")

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	
	var team = _owner._team
	
	NetworkManager.create_node_instance(AoEAbilityScene.resource_path, [cast_pos, team, _owner])
	
	_set_active(AbilityState.INACTIVE)
