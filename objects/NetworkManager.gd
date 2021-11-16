extends Node

export var SERVER_PORT = 8082
export var MAX_PLAYERS = 20
export var SERVER_IP = "127.0.0.1"

const HOST_ID = 1

var object_id = 0

var current_scene = null

#onready var client_button = get_tree().get_current_scene().get_node("Interface").get_node("ClientButton")
#onready var server_button = get_tree().get_current_scene().get_node("Interface").get_node("ServerButton")

signal player_created(player, local)

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
var my_info = { name = "Johnson Magenta", team = Character.Team.TEAM_1 }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)
	create_player_instance(id)

# Replace with MultiplayerReplicator.spawn in 4.0
remote func _create_instance(scene_path, init_params, new_name, parent_node_path: String, callback_instance_path: String = "", callback_name: String = "") -> void:
	if get_tree().get_network_unique_id() == HOST_ID:
		return
	_create_node_instance(scene_path, init_params, new_name, parent_node_path, callback_instance_path, callback_name)

func _create_node_instance(scene_path, init_params, new_name, parent_node_path: String, callback_instance_path: String = "", callback_name: String = "") -> Node:
	var instance = load(scene_path).instance() # TODO: Cache with preload
	instance.call("init", init_params)
	if instance.is_class("Character"): # TODO: Is this really needed?
		instance.peer_owner_id = HOST_ID
	var parent_node = get_tree().get_root()
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
		get_node(callback_instance_path).call(callback_name, instance.get_path())
	return instance
	
func create_node_instance(scene_path, init_params, parent_node_path: String = "", callback_instance_path: String = "", callback_name: String = "") -> Node:
	if get_tree().get_network_unique_id() != HOST_ID:
		print("Tried to create object on client!")
		return null
	var instance = _create_node_instance(scene_path, init_params, "", parent_node_path, callback_instance_path, callback_name)
	print("sending rpc create ", instance.get_name())
	rpc("_create_instance", scene_path, init_params, instance.get_name(), parent_node_path, callback_instance_path, callback_name)
	return instance.get_path()

remote func remove_instance(node_path: String) -> void:
	if get_tree().get_network_unique_id() == HOST_ID:
		return
	_remove_node_instance(node_path)

func _remove_node_instance(node_path: String) -> void:
	print(node_path)
	get_node(node_path).call_deferred("free")
	
	print("removed ", node_path)
	
func remove_node_instance(node_path: String) -> void:
	if get_tree().get_network_unique_id() != HOST_ID:
		print("Tried to delete object on client!")
		return
	var instance = _remove_node_instance(node_path)
	rpc("remove_instance", node_path)
	
func create_player_instance(id: int) -> void:
	print(id)
	#if id == 1:
	#	return
	var player_instance
	var local = false
	if id == get_tree().get_network_unique_id():
		player_instance = LocalPlayerScene.instance()
		local = true
	else:
		player_instance = PlayerScene.instance()
	player_instance.init([Character.Team.TEAM_1])
	player_instance.peer_owner_id = id
	player_instance.set_name(str(id))
	get_tree().get_root().add_child(player_instance)
	if local:
		player_instance.get_node("Camera").current = true
	
	print("created!")
	emit_signal("player_created", player_instance, local)

func _player_disconnected(id) -> void:
	if get_tree().get_network_unique_id() == HOST_ID:
		var player_node_path = get_tree().get_root().get_node(str(id)).get_path()
		player_info.erase(id) # Erase player from info.
		remove_node_instance(player_node_path)

const PlayerScene: Resource = preload("res://objects/Player.tscn")
const LocalPlayerScene: Resource = preload("res://objects/LocalPlayer.tscn")

func _connected_ok() -> void:
	create_player_instance(get_tree().get_network_unique_id())
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected() -> void:
	pass # Server kicked us; show error and abort.

func _connected_fail() -> void:
	pass # Could not even connect to server; abort.

remote func register_player(info) -> void:
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	# Call function to update lobby UI here

func connect_server(port: int) -> void:
	var peer = NetworkedMultiplayerENet.new()
	print(peer.create_server(SERVER_PORT, MAX_PLAYERS))
	get_tree().network_peer = peer
	print("Connected server")
	print(get_tree().is_network_server())
	create_player_instance(get_tree().get_network_unique_id())

func connect_client(ip: String, port: int) -> void:
	var peer = NetworkedMultiplayerENet.new()
	print(peer.create_client(ip, port))
	get_tree().network_peer = peer
	print("Connected client")
	print(get_tree().is_network_server())


func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.

	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# Immediately free the current scene,
	# there is no risk here.
	current_scene.free()

	# Load new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
