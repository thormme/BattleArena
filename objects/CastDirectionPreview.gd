extends CastPreview


onready var arrow_instance: MeshInstance = $MeshInstance
onready var viewport_container: ViewportContainer = $ViewportContainer
onready var viewport: Viewport = $ViewportContainer/Viewport
onready var arrow_bar: NinePatchRect = $ViewportContainer/Viewport/NinePatchRect
onready var arrow_head: NinePatchRect = $ViewportContainer/Viewport/NinePatchRect2


func update_cast_pos(cast_pos: Vector3) -> void:
	var direction = cast_pos - player.transform.origin
	direction.y = 0
	var length = direction.length()
	if length < min_distance:
		length = min_distance
	if length > max_distance:
		length = max_distance
	
	var arrow_mesh: QuadMesh = arrow_instance.get_mesh()
	var pixel_size = arrow_mesh.size.y / viewport.size.y
	arrow_bar.rect_size.x = length / pixel_size - arrow_bar.rect_position.x
	viewport.size.x = length / pixel_size
	viewport_container.rect_size.x = length / pixel_size
	transform = transform.looking_at(transform.origin + direction.normalized(), Vector3.UP)
	transform = transform.rotated(Vector3.UP, -PI/2)
	transform.origin = direction.normalized() * length
	arrow_instance.get_active_material(0).albedo_texture = viewport.get_texture()
	arrow_mesh.size.x = length
	arrow_mesh.center_offset.x = length / 2
	#arrow_instance.transform.basis = Basis.IDENTITY
	#arrow_instance.transform = arrow_instance.transform.scaled(Vector3(length/2, 1, 1))


func _change_color(color: Color):
	._change_color(color)
	arrow_instance.get_active_material(0).albedo_color = color

func _set_radius(radius: float):
	._set_radius(radius)
	if arrow_instance:
		arrow_instance.get_mesh().size.y = radius * 4 # I don't know why it's double
