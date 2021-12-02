extends Pickup
class_name HealthOrb

export var healing = 15

func _handle_character_hit(body: Character) -> void:
	if healing > 0:
		body.apply_heal(healing)
