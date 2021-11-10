extends Area
class_name Attack

var _direction: Vector3 = Vector3.ZERO
export var speed: float = 1
export var destroy_on_contact = true
export var destroy_on_timeout = true

func init(direction: Vector3, team_collision: int):
	collision_mask |= team_collision
	_direction = direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.translate(_direction.normalized() * speed)

func _handle_character_hit(body):
	print("hit")
	pass

func _on_Attack_body_entered(body):
	if body.is_in_group(Character.CHARACTER_GROUP):
		_handle_character_hit(body)
	if destroy_on_contact:
		_destroy()

func _on_Timer_timeout():
	if destroy_on_timeout:
		_destroy()

func _destroy():
	call_deferred("free")
