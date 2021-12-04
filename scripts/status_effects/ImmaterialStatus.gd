extends StatusEffect
class_name ImmaterialStatus

const world_layer: int = 1

export var detectable: bool = false
export var has_world_collision: bool = false

var _original_layers: int = 0
var _original_mask: int = 0

func init(params: Array): # caster: Mover, duration: float
	.init([params[0]])
	duration = params[1]
	pass

func handle_added(target: Mover) -> void:
	.handle_added(target)
	_original_layers = target.collision_layer & 0xffff # High 16 bits for area detection
	_original_mask = target.collision_mask & 0xffffffff
	target.collision_layer ^= _original_layers
	target.collision_mask ^= _original_mask
	if has_world_collision:
		target.collision_mask ^= world_layer
	if detectable:
		target.collision_layer ^= _original_layers << 16

func handle_removed() -> void:
	_target.collision_layer = _original_layers
	_target.collision_mask = _original_mask
	.handle_removed()
