extends Ability
class_name TeleportAbility

func _update_active(delta, cast_pos):
	self.get_parent().transform.origin.x = cast_pos.x
	self.get_parent().transform.origin.z = cast_pos.z
	_set_active(AbilityState.INACTIVE)

func _handle_activate(_active):
	var haste: HasteStatus = HasteStatus.new(self.get_parent(), 3)
	self.get_parent().add_status(haste)
