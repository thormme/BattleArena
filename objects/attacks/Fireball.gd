extends Attack

const burn_status = preload("res://scripts/status_effects/Burn.tscn")

func _handle_character_hit(body: Character) -> void:
	._handle_character_hit(body)
	NetworkManager.create_node_instance(burn_status.resource_path, [], body.get_node("StatusEffects").get_path(), get_path(), "_handle_burn_created", [body.get_path()])

func _handle_burn_created(burn_node_path: String, body_path: String):
	var character = get_node(body_path)
	var burn: DamageOverTimeStatus = get_node(burn_node_path)
	character.add_status(burn)

