extends Spatial
class_name CastPreview

export var max_distance = 50
export var min_distance = 20
export var ability_radius: float = 2 setget _set_radius
export var visible_during_cast = false
export var preview_color: Color = Color(0x00b1ffff)
export var active_color: Color = Color(0x02d100ff)
var _color: Color

onready var player: Mover = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_disable()
	self.call_deferred("_set_radius", ability_radius)

func _process(delta):
	if visible:
		update_cast_pos(player._cast_pos)


func update_cast_pos(cast_pos: Vector3) -> void:
	pass


func _disable():
	self.visible = false

func _change_color(color: Color):
	_color = color
	
func _set_radius(radius: float):
	ability_radius = radius

func _on_Ability_charging(previous_state):
	if (player._has_command_authority()):
		_change_color(preview_color)
		self.visible = true

func _on_Ability_activated(previous_state):
	if !visible_during_cast:
		_disable()
	else:
		_change_color(active_color)

func _on_Ability_inactivated(previous_state):
	_disable()
