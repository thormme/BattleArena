extends Ability
class_name JumpAbility

const immaterial_status = preload("res://scripts/status_effects/ImmaterialStatus.tscn")
const immobile_status = preload("res://scripts/status_effects/ImmobileStatus.tscn")
const jump_status = preload("res://scripts/status_effects/JumpStatus.tscn")


func _handle_activate(_active) -> void:
	._handle_activate(_active)
	apply_status(jump_status, "jump", [.5], "_handle_jump_created")
	apply_status(immobile_status, "immobile", [3])
	apply_status(immaterial_status, "immaterial", [3])

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	_statuses.jump.set_landing_pos(cast_pos)
	var state_machine = get_parent().get_node("Pivot").get_node("Model").get_node("AnimationTree")["parameters/StateMachine/playback"]
	state_machine.travel("Jump")

func _handle_inactivate(_active) -> void:
	for status in _statuses.values():
		if is_instance_valid(status):
			get_parent().remove_status(status)
	._handle_inactivate(_active)

func _handle_jump_created(path: String, key: String) -> void:
	var instance = get_node(path)
	instance.connect("status_expired", self, "_handle_jump_expired")

func _handle_jump_expired() -> void:
	call_deferred("_set_active", AbilityState.INACTIVE)



