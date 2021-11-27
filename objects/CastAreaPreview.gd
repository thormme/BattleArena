extends CastPreview

export var radius : float = 2 setget set_radius

onready var circle_mesh: MeshInstance = $MeshInstance

func set_radius(_radius: float):
	radius = _radius


func _change_color(color: Color):
	._change_color(color)
	circle_mesh.get_surface_material(0).albedo_color = color


func update_cast_pos(cast_pos: Vector3) -> void:
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
