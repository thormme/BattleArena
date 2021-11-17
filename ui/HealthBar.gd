extends TextureProgress
class_name HealthBar

const HEALTH_SEGMENT_SIZE: int = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var segment_viewport: Viewport = $ViewportContainer/Viewport
onready var overlay_viewport: Viewport = $ViewportContainer2/Viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_texture()
	set_max(self.max_value)
	pass


func set_max(value: float):
	.set_max(value)
	segment_viewport.size.x = self.rect_size.x / (self.max_value / HEALTH_SEGMENT_SIZE)
	
	
func _set_texture():
	self.texture_over = overlay_viewport.get_texture()
