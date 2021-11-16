extends Ability
class_name TeleportAbility

const haste_status = preload("res://scripts/status_effects/HasteStatus.tscn")

var teleport = 1

func _update_active(delta, cast_pos) -> void:
	._update_active(delta, cast_pos)
	if teleport == 0:
		self.get_parent().transform.origin.x = cast_pos.x
		self.get_parent().transform.origin.z = cast_pos.z
		_set_active(AbilityState.INACTIVE)
	if teleport == 1:
		self.get_parent().transform.origin.x = cast_pos.x
		self.get_parent().transform.origin.z = cast_pos.z
		teleport = 2

func _handle_activate(_active) -> void:
	._handle_activate(_active)
	teleport = 1
	NetworkManager.create_node_instance(haste_status.resource_path, [3], get_parent().get_node("StatusEffects").get_path(), get_path(), "_handle_haste_created")

func _handle_haste_created(haste_node_path: String):
	var haste: HasteStatus = get_node(haste_node_path)
	haste.connect("status_expired", self, "_handle_haste_expired")
	emit_signal("add_status", haste)

func _handle_haste_expired() -> void:
	teleport = 0
