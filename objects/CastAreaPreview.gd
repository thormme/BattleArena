extends Spatial

export var max_distance = 50
export var min_distance = 20
export var radius : float = 2 setget set_radius

onready var player: Mover = get_parent().get_parent()
onready var circle_mesh: MeshInstance = $MeshInstance

func set_radius(_radius: float):
	radius = _radius

# Called when the node enters the scene tree for the first time.
func _ready():
	_disable()

func _process(delta):
	if visible:
		set_pos(player._cast_pos)


func set_pos(cast_pos: Vector3) -> void:
	circle_mesh.transform.basis = Basis(Vector3(-PI/2, 0, 0))
	circle_mesh.transform = circle_mesh.transform.scaled(Vector3(radius, 1, radius))
	
	var direction = cast_pos - player.transform.origin
	direction.y = 0
	var length = direction.length()
	if length < min_distance:
		length = min_distance
	if length > max_distance:
		length = max_distance
	transform.origin = direction.normalized() * length


func _disable():
	self.visible = false

func _on_Ability_charging(previous_state):
	if (player._has_command_authority()):
		self.visible = true

func _on_Ability_activated(previous_state):
	_disable()

func _on_Ability_inactivated(previous_state):
	_disable()
