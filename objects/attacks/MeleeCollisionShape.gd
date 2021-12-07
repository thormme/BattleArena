tool
extends CollisionShape


export var radius: float = 1 setget set_radius
export var start_angle: float = -1
export var end_angle: float = 1

const POINTS_PER_ROTATION = 40


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_point_array()


func set_radius(value):
	radius = value
	_update_point_array()

func set_start_angle(value):
	start_angle = value
	if start_angle > end_angle:
		end_angle = start_angle
	_update_point_array()

func set_end_angle(value):
	end_angle = value
	if start_angle > end_angle:
		start_angle = end_angle
	_update_point_array()
	
func _update_point_array() -> void:
	var convex_shape: ConvexPolygonShape = self.shape
	var angle: float = start_angle
	var points: PoolVector3Array = PoolVector3Array([])
	while angle <= end_angle:
		var adjusted_angle = angle - PI / 2
		points.append(Vector3(radius * cos(adjusted_angle), -1, radius * sin(adjusted_angle)))
		points.append(Vector3(radius * cos(adjusted_angle), 1, radius * sin(adjusted_angle)))
		angle += (2 * PI) / POINTS_PER_ROTATION
	points.append(Vector3(0, -1, 0))
	points.append(Vector3(0, 1, 0))
	
	convex_shape.points = points
