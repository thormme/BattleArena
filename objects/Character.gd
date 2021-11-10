extends KinematicBody

class_name Character

enum AbilityIndex {
	ABILITY_1 = 0,
	ABILITY_2 = 1,
	ABILITY_3 = 2,
	ABILITY_4 = 3,
	ABILITY_5 = 4,
	ENERGY_ABILITY = 5,
	ULTIMATE_ABILITY = 6
}

enum Team {
	TEAM_1 = 2,
	TEAM_2 = 4
}

const CHARACTER_GROUP = "Character"
const TEAM_1_GROUP = "Team1"
const TEAM_2_GROUP = "Team2"

var _team = Team.TEAM_1
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

func init(team):
	_team = team

func _ready():
	if _team == Team.TEAM_1:
		add_to_group(TEAM_1_GROUP)
	if _team == Team.TEAM_2:
		add_to_group(TEAM_2_GROUP)
	
	for ability_path in ability_paths:
		var ability = get_node(ability_path) as Ability
		abilities.append(ability)
		ability.connect("add_status", self, "add_status")
		ability.connect("remove_status", self, "remove_status")
		ability.connect("apply_damage", self, "apply_damage")
		ability.connect("apply_heal", self, "apply_heal")
	
func _get_ability(index):
	var ability: Ability = abilities[index as int]
	return ability
	
func _get_move_attempt():
	return Vector3.ZERO
	
func _get_cast_attempt():
	return []
	
func _get_cast_position():
	return self.transform.origin
	
func _physics_process(delta):
	
	var direction = _get_move_attempt()

	velocity = Vector3.ZERO
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	var statuses = status_effects.duplicate()
	for status in statuses:
		velocity = status.handle_move(velocity)
	
	move_and_slide(velocity, Vector3.UP)
	
	var cast_pos = _get_cast_position()
	
	var last_ability: Ability = _get_ability(last_cast_ability)
	var current_priority = last_ability.get_priority()
	
	var requested_abilities = _get_cast_attempt()
	for ability_index in requested_abilities:
		var ability: Ability = _get_ability(ability_index)
		if ability.attempt_cast(current_priority):
			if last_cast_ability as int != ability_index as int:
				last_ability.cancel_cast()
			last_cast_ability = ability_index
	
	for ability_index in AbilityIndex:
		var ability: Ability = _get_ability(ability_index)
		ability.update(delta, cast_pos)
	
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
