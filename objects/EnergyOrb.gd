extends Pickup
class_name EnergyOrb

export var energy_gain = 15

func _handle_character_hit(body: Character) -> void:
	if energy_gain > 0:
		body.gain_energy(energy_gain, null)
