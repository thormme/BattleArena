extends Character
class_name Player


func _get_mouse_pos() -> Vector3:
	var mouse = get_viewport().get_mouse_position()

	var camera = get_viewport().get_camera()
	if camera == null:
		return Vector3.ZERO
	var from = camera.project_ray_origin(mouse)
	var to = camera.project_ray_normal(mouse)
	
	# Intersect mouse ray with plane at origin
	var cursorPos = Plane(Vector3.UP, 0).intersects_ray(from, to)
	return cursorPos

func _get_move_attempt_command() -> Vector3:
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
	
	var forward: Vector3 = get_viewport().get_camera().get_global_transform().basis.z
	forward.y = 0 #remove pitch
	forward = forward.normalized()
	
	direction = direction.rotated(Vector3.UP, forward.angle_to(Vector3.FORWARD) + PI)
	return direction

func _physics_process(delta: float):
	#._physics_process(delta) # Called automatically by the engine...
	
	# Rotate facing direction
	if _direction != Vector3.ZERO:
		var state_machine = $Pivot.get_node("Model").get_node("AnimationTree")["parameters/StateMachine/playback"]
		state_machine.travel("Run")
	else:
		var state_machine = $Pivot.get_node("Model").get_node("AnimationTree")["parameters/StateMachine/playback"]
		state_machine.travel("Idle")

func _get_cast_attempt_command():
	var ability_values = []
	for ability_index in AbilityIndex:
		if Input.is_action_pressed(ability_input_name[ability_index]):
			ability_values.append(ability_index)
	
	return ability_values

func _get_cast_position_command() -> Vector3:
	return self._get_mouse_pos()
