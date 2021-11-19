extends Ability
class_name ShootAbility

const AttackAbilityScene = preload("res://objects/attacks/Fireball.tscn")

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	
	var dir = cast_pos - get_parent().transform.origin
	dir.y = 0
	var team = get_parent()._team
	var position = get_parent().transform.origin
	
	NetworkManager.create_node_instance(AttackAbilityScene.resource_path, [position, dir, team])
	
	_set_active(AbilityState.INACTIVE)
