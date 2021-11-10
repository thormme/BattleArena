extends PanelContainer


var cooldown = false
export var ability_node_name = "Ability1"

onready var label = get_node("Label")

onready var ability = get_tree().get_current_scene().get_node("Player").get_node(ability_node_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	ability.connect("charging", self, "_handle_Ability1_charging")
	ability.connect("finished_cooldown", self, "_handle_Ability1_finished_cooldown")
	ability.connect("started_cooldown", self, "_handle_Ability1_started_cooldown")


func _handle_Ability1_charging(_prev_state):
	label.text = "Casting"
	
func _handle_Ability1_started_cooldown(duration):
	cooldown = true
	
func _handle_Ability1_finished_cooldown():
	label.text = "Ready"
	cooldown = false
	
func _physics_process(delta):
	if cooldown == true:
		label.text = str(ability.cooldown_timer).pad_decimals(1)
