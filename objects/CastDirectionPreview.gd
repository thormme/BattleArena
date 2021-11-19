extends Spatial

export var max_distance = 50
export var min_distance = 20

onready var player: Node = get_parent().get_parent()
onready var sprite_3d: Sprite3D = $Sprite3D
onready var viewport_container: ViewportContainer = $ViewportContainer
onready var viewport: Viewport = $ViewportContainer/Viewport
onready var arrow_bar: NinePatchRect = $ViewportContainer/Viewport/NinePatchRect
onready var arrow_head: NinePatchRect = $ViewportContainer/Viewport/NinePatchRect2

# Called when the node enters the scene tree for the first time.
func _ready():
	_disable()

func _process(delta):
	if visible:
		set_length(player._cast_pos)


func set_length(cast_pos: Vector3) -> void:
	var direction = cast_pos - player.transform.origin
	direction.y = 0
	var length = direction.length()
	if length < min_distance:
		length = min_distance
	if length > max_distance:
		length = max_distance
	arrow_bar.rect_size.x = length / sprite_3d.pixel_size - arrow_bar.rect_position.x
	viewport.size.x = length / sprite_3d.pixel_size
	viewport_container.rect_size.x = length / sprite_3d.pixel_size
	transform = transform.looking_at(transform.origin + direction.normalized(), Vector3.UP)
	transform = transform.rotated(Vector3.UP, -PI/2)
	transform.origin = direction.normalized() * length
	sprite_3d.transform.basis = Basis.IDENTITY
	sprite_3d.transform = sprite_3d.transform.scaled(Vector3(length/2, 1, 1))


func _disable():
	self.visible = false

func _on_Ability_charging(previous_state):
	self.visible = true

func _on_Ability_activated(previous_state):
	_disable()

func _on_Ability_inactivated(previous_state):
	_disable()
