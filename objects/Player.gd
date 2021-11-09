extends KinematicBody

class_name Player

enum AbilityIndex {
	ABILITY_1 = 0,
	ABILITY_2 = 1,
	ABILITY_3 = 2,
	ABILITY_4 = 3,
	ABILITY_5 = 4,
	ENERGY_ABILITY = 5,
	ULTIMATE_ABILITY = 6
}

export var max_health: int = 100
var health: int = max_health
export var speed = 14
export (Array, NodePath) var ability_paths := []
export var camera_path: NodePath
var velocity = Vector3.ZERO
var abilities: Array = []
var status_effects: Array = []
onready var camera: Camera = get_node(camera_path)

var last_cast_ability = AbilityIndex.ABILITY_1

var ability_input_name = [
	"ability_1",
	"ability_2",
	"ability_3",
	"ability_4",
	"ability_5",
	"energy_ability",
	"ultimate_ability"
	]
	
func _get_mouse_pos():
	var mouse = get_viewport().get_mouse_position()

	#var camera = get_tree().get_root().find_node("Camera", true, false)
	var from = camera.project_ray_origin(mouse)
	var to = camera.project_ray_normal(mouse)
	
	# Intersect mouse ray with plane at origin
	var cursorPos = Plane(Vector3.UP, 0).intersects_ray(from, to)
	return cursorPos

func _ready():
	for ability in ability_paths:
		abilities.append(get_node(ability) as Ability)
	
func _get_ability(index):
	var ability: Ability = abilities[index as int]
	return ability
	
func _physics_process(delta):
	
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

	velocity = Vector3.ZERO
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	var statuses = status_effects.duplicate()
	for status in statuses:
		velocity = status.handle_move(velocity)
	
	move_and_slide(velocity, Vector3.UP)
	
	var mouse_pos = _get_mouse_pos()
	
	var last_ability: Ability = _get_ability(last_cast_ability)
	var current_priority = last_ability.get_priority()
	
	for ability_index in AbilityIndex:
		var ability: Ability = _get_ability(ability_index)
		if Input.is_action_pressed(ability_input_name[ability_index as int]):
			if ability.attempt_cast(current_priority):
				if last_cast_ability as int != ability_index as int:
					last_ability.cancel_cast()
				last_cast_ability = ability_index
		
		ability.update(delta, mouse_pos)
	
	for status in statuses:
		velocity = status.handle_update(delta)

func add_status(status: StatusEffect):
	status_effects.append(status)
	status_effects.sort_custom(StatusSorter, "sort_status_priority")
	status.handle_added()
	
func remove_status(status: StatusEffect):
	status_effects.remove(status_effects.find(status))
	status.handle_removed()

func apply_damage(damage: int):
	var statuses = status_effects.duplicate()
	for status in statuses:
		damage = status.handle_damage(damage)
	health -= damage
	if health <= 0:
		self.kill()

func apply_heal(heal_amount: int):
	var statuses = status_effects.duplicate()
	for status in statuses:
		heal_amount = status.handle_heal(heal_amount)
	health += heal_amount
	
func kill():
	pass

class StatusSorter:
	static func sort_status_priority(a: StatusEffect, b: StatusEffect):
		if a._priority < b._priority:
			return true
		return false
