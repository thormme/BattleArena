extends Ability
class_name ShootAbility

const AttackAbilityScene = preload("res://objects/Attack.tscn")

func _update_active(delta, cast_pos):
	._update_active(delta, cast_pos)
	
	var attack_instance = AttackAbilityScene.instance()
	var dir = cast_pos - get_parent().transform.origin
	attack_instance.init(dir, get_parent()._team ^ (Character.Team.TEAM_1 | Character.Team.TEAM_2))
	#attack_instance.transform.origin = get_parent().transform.origin
	attack_instance.transform = attack_instance.transform.translated(get_parent().transform.origin)
	#attack_instance.transform = attack_instance.transform.translated(Vector3.UP)
	get_tree().get_root().add_child(attack_instance)
	_set_active(AbilityState.INACTIVE)

