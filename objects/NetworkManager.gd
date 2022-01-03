extends Node

export var SERVER_PORT = 8082
export var MAX_PLAYERS = 20
export var SERVER_IP = "127.0.0.1"

const HOST_ID = 1

var object_id = 0

var current_scene = null
var added_node_container = null

var _changing_scene = false
var _resource_cache: Dictionary = {}

signal player_created(player, local)
signal player_connected(player_id)

signal player_changed_team(player_id, old_team) # player_id: int, old_team: Mover.Team 
signal player_changed_ready(player_id, ready) # player_id: int, ready: bool 
signal player_changed_instance(player_id, instance) # player_id: int, instance: String 
signal player_changed_name(player_id, name) # player_id: int, name: String 
signal player_changed_slot(player_id, slot) # player_id: int, slot: int

func _ready() -> void:
	#client_button.connect("button_up", self, "connect_server")
	#server_button.connect("button_up", self, "connect_client")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", team = Mover.Team.SPECTATOR, ready = false, instance = null, slot = -1 }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	print("connected ", id)
	var info = my_info
	if player_info.has(get_tree().get_network_unique_id()):
		info = player_info[get_tree().get_network_unique_id()]
	rpc_id(id, "register_player", info)
	#create_player_instance(id)

# Replace with MultiplayerReplicator.spawn in 4.0
remote func _create_instance(scene_path, init_params, new_name, parent_node_path: String, callback_instance_path: String = "", callback_name: String = "", callback_params: Array = []) -> void:
	if _changing_scene:
		print("Skipping creating ", scene_path)
		return
	if get_tree().get_network_unique_id() == HOST_ID:
		return
	_create_node_instance(scene_path, init_params, new_name, parent_node_path, callback_instance_path, callback_name, callback_params)

func _create_node_instance(scene_path, init_params, new_name, parent_node_path: String = "", callback_instance_path: String = "", callback_name: String = "", callback_params: Array = []) -> Node:
	var scene
	if _resource_cache.has(scene_path):
		scene = _resource_cache[scene_path]
	else:
		scene = load(scene_path)
		# Cache loaded scenes
		# TODO: Consider unloading them eventually
		_resource_cache[scene_path] = scene
	var instance = scene.instance()
	instance.call("init", init_params)
	var parent_node = get_tree().get_root()
	if added_node_container != null:
		parent_node = added_node_container
	if parent_node_path != "":
		parent_node = get_node(parent_node_path)
	parent_node.add_child(instance)
	if new_name == "":
		if instance.get_script():
			new_name = instance.get_script().resource_path.get_file().trim_suffix(".gd")
		else:
			new_name = instance.get_class()
		new_name += str(object_id)
		object_id = object_id + 1
	instance.set_name(new_name)
	instance.set_name(instance.get_name().replace("@", "__"))
	print("tried ", new_name)
	print("created ", instance.get_path())
	if callback_instance_path != "":
		get_node(callback_instance_path).callv(callback_name, [instance.get_path()] + callback_params)
	return instance
	
func create_node_instance(scene_path, init_params, parent_node_path: String = "", callback_instance_path: String = "", callback_name: String = "", callback_params: Array = []) -> Node:
	if get_tree().get_network_unique_id() != HOST_ID:
		print("Tried to create object on client!")
		return null
	var instance = _create_node_instance(scene_path, init_params, "", parent_node_path, callback_instance_path, callback_name, callback_params)
	print("sending rpc create ", instance.get_name())
	rpc("_create_instance", scene_path, init_params, instance.get_name(), parent_node_path, callback_instance_path, callback_name, callback_params)
	return instance.get_path()

remote func remove_instance(node_path: String) -> void:
	if _changing_scene:
		print("Skipping removing ", node_path)
		return
	if get_tree().get_network_unique_id() == HOST_ID:
		return
	_remove_node_instance(node_path)

func _remove_node_instance(node_path: String) -> void:
	print(node_path)
	var node = get_node_or_null(node_path)
	if !node:
		return
	get_node(node_path).call_deferred("free")
	
	print("removed ", node_path)
	
func remove_node_instance(node_path: String) -> void:
	if get_tree().get_network_unique_id() != HOST_ID:
		print("Tried to delete object on client!")
		return
	var instance = _remove_node_instance(node_path)
	rpc("remove_instance", node_path)
	
func create_player_instance(id: int) -> void:
	
	_create_node_instance(PlayerScene.resource_path, [Mover.Team.TEAM_1, id], str(id))
	print("created!")

func _player_disconnected(id) -> void:
	if get_tree().get_network_unique_id() == HOST_ID:
		var player_node_path = player_info[id].instance
		if player_node_path != null:
			remove_node_instance(player_node_path)
		player_info.erase(id) # Erase player from info.

const PlayerScene: Resource = preload("res://objects/Player.tscn")
const LocalPlayerScene: Resource = preload("res://objects/LocalPlayer.tscn")

func _connected_ok() -> void:
	register_player_local(get_tree().get_network_unique_id(), my_info)
	#create_player_instance(get_tree().get_network_unique_id())
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected() -> void:
	pass # Server kicked us; show error and abort.

func _connected_fail() -> void:
	pass # Could not even connect to server; abort.

remote func register_player(info) -> void:
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	register_player_local(id, info)
	# Call function to update lobby UI here
	
func register_player_local(id: int, info) -> void:
	print("register", id)
	player_info[id] = info
	
	emit_signal("player_connected", id)

func connect_server(port: int) -> void:
	var peer = NetworkedMultiplayerENet.new()
	print(peer.create_server(SERVER_PORT, MAX_PLAYERS))
	get_tree().network_peer = peer
	print("Connected server")
	print(my_info)
	register_player_local(get_tree().get_network_unique_id(), my_info)
	#create_player_instance(get_tree().get_network_unique_id())

func connect_client(ip: String, port: int) -> void:
	var peer = NetworkedMultiplayerENet.new()
	print(peer.create_client(ip, port))
	get_tree().network_peer = peer
	print("Connected client")
	print(get_tree().is_network_server())


func goto_scene(path: String):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.

	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	
	var is_connected = get_tree().has_network_peer()
	
	if !is_connected:
		_changing_scene = true
		call_deferred("_deferred_goto_scene", path)
		
	if is_connected && get_tree().get_network_unique_id() == HOST_ID:
		_changing_scene = true
		call_deferred("_deferred_goto_scene", path)
		rpc("_remote_goto_scene", path)


remote func _remote_goto_scene(path: String):
	var from_host = get_tree().get_rpc_sender_id() == 1
	
	if from_host:
		_changing_scene = true
		call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	# Immediately free the current scene,
	# there is no risk here.
	current_scene.free()

	# Load new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()
	
	# Add runtime created object container
	added_node_container = Node.new()
	added_node_container.name = "Added"
	current_scene.add_child(added_node_container)

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
	_changing_scene = false

func _update_player_info(player_id: int, info: Dictionary):
		var player_info = NetworkManager.player_info[player_id]
		if player_info.ready != info.ready:
			var old_ready = player_info.ready
			player_info.ready = info.ready
			emit_signal("player_changed_ready", player_id, old_ready)
		if player_info.team != info.team:
			var old_team = player_info.team
			player_info.team = info.team
			emit_signal("player_changed_team", player_id, old_team)
		if player_info.instance != info.instance:
			var old_instance = player_info.instance
			player_info.instance = info.instance
			emit_signal("player_changed_instance", player_id, old_instance)
		if player_info.name != info.name:
			var old_name = player_info.name
			player_info.name = info.name
			emit_signal("player_changed_name", player_id, old_name)
		if player_info.slot != info.slot:
			var old_slot = player_info.slot
			player_info.slot = info.slot
			emit_signal("player_changed_slot", player_id, old_slot)

remote func _remote_update_player_info(player_id: int, info: Dictionary):
	var from_host = get_tree().get_rpc_sender_id() == 1
	var owned = get_tree().get_network_unique_id() == player_id
	var from_owner = get_tree().get_rpc_sender_id() == player_id
	var is_host = get_tree().get_network_unique_id() == HOST_ID
	
	if is_host && from_owner:
		_update_player_info(player_id, info)
		rpc("_remote_update_player_info", player_id, info)
	if from_host:
		_update_player_info(player_id, info)
		
func update_player_info(player_id: int, info: Dictionary):
	var owned = get_tree().get_network_unique_id() == player_id
	var is_host = get_tree().get_network_unique_id() == HOST_ID
	
	if is_host:
		_update_player_info(player_id, info)
	if is_host || owned:
		rpc("_remote_update_player_info", player_id, info)

func get_player_info_copy(player_id):
	var new_info = {}
	for key in player_info[player_id].keys():
		new_info[key] = player_info[player_id][key]
	return new_info

func get_player_info_read_only(player_id):
	return player_info[player_id]
	
# Get read only copy of player info
func get_current_player_info():
	return player_info[get_tree().get_network_unique_id()]
