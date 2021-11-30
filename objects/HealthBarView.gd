extends Sprite3D


onready var interface = get_node("/root/Main/Interface")
const HealthBar: Resource = preload("res://ui/HealthBar.tscn")
var _health_bar: HealthBar


# Called when the node enters the scene tree for the first time.
func _ready(): # TODO: Use _enter_tree
	_health_bar = HealthBar.instance()
	interface.add_child(_health_bar)
	
func _process(delta):
	_health_bar.visible = not get_viewport().get_camera().is_position_behind(global_transform.origin)
	_health_bar.rect_position = get_viewport().get_camera().unproject_position(global_transform.origin) - _health_bar.rect_size / 2


func _on_Character_damaged(new_health, amount, recovery_health):
	_update_health(new_health)


func _on_Character_healed(new_health, amount):
	_update_health(new_health)

func _update_health(new_health):
	_health_bar.value = new_health


func _exit_tree() -> void:
	interface.remove_child(_health_bar)
	_health_bar.call_deferred("free")

func _on_Character_killed():
	pass


func _on_Character_healed_recovery(new_health, amount, change):
	pass # Replace with function body.


func _on_Character_health_set(new_health, recovery_health):
	_update_health(new_health)
