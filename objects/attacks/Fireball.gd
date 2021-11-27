extends Attack

const burn_status = preload("res://scripts/status_effects/BurnStatus.tscn")

func _handle_character_hit(body: Character) -> void:
	._handle_character_hit(body)
	body.apply_status(burn_status.resource_path, [])

