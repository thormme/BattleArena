extends Ability
class_name TeleportAbility

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
	var haste: HasteStatus = HasteStatus.new(self.get_parent(), 3)
	haste.connect("status_expired", self, "_handle_haste_expired")
	emit_signal("add_status", haste)

func _handle_haste_expired() -> void:
	teleport = 0
