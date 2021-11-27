extends Ability
class_name JumpAbility

const immaterial_status = preload("res://scripts/status_effects/ImmaterialStatus.tscn")
const immobile_status = preload("res://scripts/status_effects/ImmobileStatus.tscn")

var immaterial_instance: StatusEffect
var immobile_instance: StatusEffect

func _handle_activate(_active) -> void:
	._handle_activate(_active)
	get_parent().apply_status(immaterial_status.resource_path, [3], self.get_path(), "_handle_immaterial_created")
	get_parent().apply_status(immobile_status.resource_path, [3], self.get_path(), "_handle_immobile_created")

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	

func _handle_inactivate(_active) -> void:
	if is_instance_valid(immaterial_instance):
		get_parent().remove_status(immaterial_instance)
	if is_instance_valid(immobile_instance):
		get_parent().remove_status(immobile_instance)
	._handle_inactivate(_active)

func _handle_immaterial_created(path: String) -> void:
	immaterial_instance = get_node(path)
	immaterial_instance.connect("status_expired", self, "_handle_immaterial_expired")

func _handle_immaterial_expired() -> void:
	immaterial_instance = null
	call_deferred("_set_active", AbilityState.INACTIVE)

func _handle_immobile_created(path: String) -> void:
	immobile_instance = get_node(path)
	immobile_instance.connect("status_expired", self, "_handle_immobile_expired")

func _handle_immobile_expired() -> void:
	immobile_instance = null
