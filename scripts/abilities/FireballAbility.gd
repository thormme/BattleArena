extends Ability
class_name FireballAbility

const FireballScene = preload("res://objects/attacks/Fireball.tscn")

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	
	var dir = cast_pos - _owner.transform.origin
	dir.y = 0
	var team = _owner._team
	var position = _owner.transform.origin
	
	NetworkManager.create_node_instance(FireballScene.resource_path, [position, dir, team, _owner.get_path()])
	
	_set_active(AbilityState.INACTIVE)
