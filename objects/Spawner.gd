extends Spatial
class_name PlayerSpawner

export(PackedScene) onready var object_path
export var respawn_delay: float = 25
export var init_parmeters: Array = []
export var position_index: int = -1

onready var _timer: Timer = $Timer

var _instance: Node

func _ready():
	hide()
	transform.origin.y = 0 # Consider projecting down
	spawn_node()

func spawn_node():
	var id = get_tree().get_network_unique_id()
	if id == NetworkManager.HOST_ID:
		var params = init_parmeters.duplicate()
		if position_index >= 0:
			params[position_index] = transform.origin
		NetworkManager.create_node_instance(object_path.resource_path, params, get_tree().get_root().get_path(), self.get_path(), "_handle_node_created")

# Update player_info with new instance
func _handle_node_created(node_path: String):
	_instance = get_node(node_path)
	_instance.connect("tree_exited", self, "_handle_instance_removed")

func _handle_instance_removed():
	_timer.start(respawn_delay)

func _on_Timer_timeout():
	spawn_node()
