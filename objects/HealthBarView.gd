extends Sprite3D


onready var interface = get_node("/root/Main/Interface")
const HealthBar: Resource = preload("res://ui/HealthBar.tscn")
var _health_bar: HealthBar


# Called when the node enters the scene tree for the first time.
func _ready():
	_health_bar = HealthBar.instance()
	interface.add_child(_health_bar)
	
func _process(delta):
	_health_bar.visible = not get_viewport().get_camera().is_position_behind(global_transform.origin)
	_health_bar.rect_position = get_viewport().get_camera().unproject_position(global_transform.origin) - _health_bar.rect_size / 2
