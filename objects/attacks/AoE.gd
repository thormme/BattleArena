extends Attack
class_name AoE

var _overlapping_bodies: Dictionary = {}

func init(params: Array):
	.init([params[0], Vector3.ZERO, params[1], params[2]])

func _get_overlapping_bodies() -> Dictionary:
	var invalid_objects = []

	for body in _overlapping_bodies:
		if !is_instance_valid(body):
			invalid_objects.append(body)

	for body in invalid_objects:
		_overlapping_bodies.erase(body)
		
	return _overlapping_bodies

func _on_Timer_timeout() -> void:
	._on_Timer_timeout()
	for body in _get_overlapping_bodies():
		if body.is_in_group(Character.CHARACTER_GROUP):
			body.apply_damage(damage, _caster)

func _handle_character_hit(body) -> void:
	# prevent handling immediately
	# track objects
	_overlapping_bodies[body] = true
	pass
