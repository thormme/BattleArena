extends GraduatedProgressBar
class_name HealthBar

const HEALTH_SEGMENT_SIZE: int = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var _default_width: float = self.rect_size.x
var _true_max: float

# Called when the node enters the scene tree for the first time.
func _ready():
	set_true_max(self.max_value)


func set_recovery(value: float):
	self.rect_min_size.x = value / _true_max * _default_width
	self.rect_size.x = self.rect_min_size.x
	overlay_viewport.size.x = self.rect_size.x
	set_max(value)
	
func set_true_max(value: float):
	_true_max = value
