extends Character
class_name Player

func _get_move_attempt():
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	
	if Input.is_action_pressed("move_up"):
		direction.z -= 1
	if Input.is_action_pressed("move_down"):
		direction.z += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	var forward: Vector3 = camera.get_global_transform().basis.z
	forward.y = 0 #remove pitch
	forward = forward.normalized()
	
	direction = direction.rotated(Vector3.UP, forward.angle_to(Vector3.FORWARD) + PI)
	return direction

func _get_cast_attempt():
	var ability_indicies = []
	for ability_index in AbilityIndex:
		if Input.is_action_pressed(ability_input_name[ability_index as int]):
			ability_indicies.append(ability_index)
	
	return ability_indicies

func _get_cast_position():
	return self._get_mouse_pos()
