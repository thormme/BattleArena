extends StatusEffect
class_name DamageOverTimeStatus

export var damage_increment: int = 10
export var damage_on_hit: bool = true


func handle_added(target) -> void:
	.handle_added(target)
	if damage_on_hit:
		_target.apply_damage(damage_increment)

func _on_Timer_timeout():
	_target.apply_damage(damage_increment)
