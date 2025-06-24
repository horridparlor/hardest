extends Node
class_name Network

const PORT: int = 4748
const ADDRESS: String = "127.0.0.1"

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func connect_signals(multiplayer : SceneMultiplayer) -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server);
	multiplayer.connection_failed.connect(_on_connection_failed);
	multiplayer.server_disconnected.connect(_on_server_disconnected);
	multiplayer.peer_connected.connect(_on_peer_connected);
	multiplayer.peer_disconnected.connect(_on_peer_disconnected);

func host(multiplayer : SceneMultiplayer) -> void:
	var result = peer.create_server(PORT);
	if result != OK:
		push_error("Failed to create server: %s" % result);
		return;
	multiplayer.multiplayer_peer = peer;
	print("Hosting on port %d" % PORT);
	print(get_wifi_ip());

func join(multiplayer : SceneMultiplayer) -> void:
	var result = peer.create_client(ADDRESS, PORT);
	if result != OK:
		push_error("Failed to create client: %s" % result);
		return;
	multiplayer.multiplayer_peer = peer;
	print("Attempting to join %s:%d" % [ADDRESS, PORT]);

func _on_connected_to_server() -> void:
	print("Successfully connected to server!");

func _on_connection_failed() -> void:
	print("Failed to connect to server.");

func _on_server_disconnected() -> void:
	print("Disconnected from server.");

func _on_peer_connected(id: int) -> void:
	print("Peer connected with ID: %d" % id);
	
func _on_peer_disconnected(id: int) -> void:
	print("Peer disconnected with ID: %d" % id);

func get_wifi_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") or ip.begins_with("10."):
			return ip;
	return "0.0.0.0";
