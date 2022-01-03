extends Ability
class_name MeleeAbility

const MeleeAbilityScene = preload("res://objects/attacks/Melee.tscn")

export var update_direction: bool = true

var _attack_instance: Node = null

func _handle_activate(_active) -> void:
	._handle_activate(_active)
	
	var team = _owner._team
	
	NetworkManager.create_node_instance(MeleeAbilityScene.resource_path, [team, _owner.get_path(), _owner.facing], "", get_path(), "_handle_attack_instance_created")

func _handle_attack_instance_created(node_path) -> void:
	_attack_instance = get_node(node_path)
	_attack_instance.connect("tree_exited", self, "_handle_attack_finished")
	
	_attack_instance.transform.origin = _owner.transform.origin
	
	#var dir: Vector3 = _owner.facing # TODO: Pass this as a parameter
	#if dir.length() > 0:
	#	_attack_instance.transform = _attack_instance.transform.looking_at(_attack_instance.transform.origin + dir, Vector3.UP)

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	
	if update_direction && _attack_instance != null:
		var dir: Vector3 = cast_pos - _attack_instance.transform.origin
		dir.y = 0
		_attack_instance.facing = dir
	
	

func _handle_attack_finished() -> void:
	_set_active(AbilityState.INACTIVE)
