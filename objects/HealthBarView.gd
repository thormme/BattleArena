extends Sprite3D


onready var interface = get_node("/root/Main/Interface")
const HoverUI: Resource = preload("res://ui/CharacterHoverUI.tscn")
var _hover_ui: CharacterHoverUI
var _health_bar: HealthBar
var _energy_bar: GraduatedProgressBar


# Called when the node enters the scene tree for the first time.
func _ready(): # TODO: Use _enter_tree
	_hover_ui = HoverUI.instance()
	interface.add_child(_hover_ui)
	_health_bar = _hover_ui.health_bar
	_energy_bar = _hover_ui.energy_bar
	
func _process(delta):
	_hover_ui.visible = not get_viewport().get_camera().is_position_behind(global_transform.origin)
	_hover_ui.rect_position = get_viewport().get_camera().unproject_position(global_transform.origin) - _hover_ui.rect_size / 2


func _on_Character_damaged(new_health, amount, recovery_health, caster):
	_update_recovery(recovery_health)
	_update_health(new_health)


func _on_Character_healed(new_health, amount, change, caster):
	_update_health(new_health)

func _update_health(new_health):
	_health_bar.value = new_health

func _update_recovery(new_recovery_health):
	_health_bar.set_recovery(new_recovery_health)

func _update_max_health(new_recovery_health):
	_health_bar.set_true_max(new_recovery_health)


func _exit_tree() -> void:
	interface.remove_child(_hover_ui)
	_hover_ui.call_deferred("free")

func _on_Character_killed():
	pass


func _on_Character_healed_recovery(new_health, amount, change, caster):
	_update_recovery(new_health)


func _on_Character_health_set(new_health, recovery_health, max_health):
	_update_max_health(max_health)
	_update_recovery(recovery_health)
	_update_health(new_health)



func _update_max_energy(new_energy: int) -> void:
	_energy_bar.set_max(new_energy)

func _update_energy(new_energy):
	_energy_bar.value = new_energy
	
func _on_Character_energy_set(new_energy, max_energy):
	_update_max_energy(max_energy)
	_update_energy(new_energy)

func _on_Character_gained_energy(new_energy, amount, change, caster):
	_update_energy(new_energy)

func _on_Character_spent_energy(new_energy, amount, change, caster):
	_update_energy(new_energy)
