extends Node3D
## DungeonManager: guarda el mapa (data persistente) y carga UNA sala a la vez.
## El player y la camara viven aqui siempre; solo la escena de sala entra/sale.

const NORTH := Vector2i(0, -1)
const SOUTH := Vector2i(0, 1)
const EAST := Vector2i(1, 0)
const WEST := Vector2i(-1, 0)
const DIRECTIONS := [NORTH, SOUTH, EAST, WEST]

@export var room_scene: PackedScene
@export var start_coord := Vector2i(0, 0)

@onready var player: CharacterBody3D = $Player
@onready var room_container: Node3D = $RoomContainer

# Mapa hecho a mano que replica tu dibujo:
#   (0,0)Inicio - (1,0)middle - (2,0)Tesoro
#                     |
#                 (1,1)sala  - (2,1)JEFE
var map := {
	Vector2i(0, 0): "inicio",
	Vector2i(1, 0): "normal",
	Vector2i(2, 0): "tesoro",
	Vector2i(1, 1): "normal",
	Vector2i(2, 1): "jefe",
}

var current_coord: Vector2i
var current_room: Room
var _teleport_locked: bool = false

# Lleva registro de las casillas que ya pisaste al menos una vez.
var visited: Array[Vector2i] = []

func _ready() -> void:
	_load_room(start_coord, Vector2i.ZERO)

## Devuelve las direcciones donde hay sala vecina (esas puertas se abren).
func _open_dirs(coord: Vector2i) -> Array:
	var dirs: Array = []
	for d in DIRECTIONS:
		if map.has(coord + d):
			dirs.append(d)
	return dirs

## came_from = direccion en la que viajo el player (Vector2i.ZERO = inicio, al centro).
func _load_room(coord: Vector2i, came_from: Vector2i) -> void:
	if current_room:
		current_room.queue_free()

	current_room = room_scene.instantiate()
	room_container.add_child(current_room)
	var dirs: Array = _open_dirs(coord)
	current_room.set_open_doors(dirs)
	current_room.player_entered_door.connect(_on_player_entered_door)
	current_coord = coord

	_log_room(coord, dirs)

	# Colocar al player.
	player.velocity = Vector3.ZERO
	if came_from == Vector2i.ZERO:
		player.global_position = Vector3(0, 2, 0)
	else:
		# Si viajo al ESTE, llega por la puerta OESTE de la nueva sala (-came_from).
		player.global_position = current_room.get_entry_point(-came_from)

	# Bloqueo breve para no re-disparar la puerta por la que acaba de llegar.
	_teleport_locked = true
	await get_tree().create_timer(0.25).timeout
	_teleport_locked = false

func _on_player_entered_door(direction: Vector2i) -> void:
	if _teleport_locked:
		return
	var target: Vector2i = current_coord + direction
	if map.has(target):
		_load_room(target, direction)

# --- Debug: imprime en consola que decidio la sala ---
func _log_room(coord: Vector2i, dirs: Array) -> void:
	var first_time: bool = not visited.has(coord)
	if first_time:
		visited.append(coord)
	var estado: String = "PRIMERA VEZ" if first_time else "YA VISITADA"
	print("=== Entre a ", coord, "  tipo=", map.get(coord, "?"), "  [", estado, "]")
	for d in DIRECTIONS:
		var vecino: Vector2i = coord + d
		var existe: bool = map.has(vecino)
		var puerta: String = "ABIERTA" if existe else "cerrada"
		print("   ", _dir_name(d), " -> ", vecino, "  vecino existe: ", existe, "  puerta: ", puerta)
	print("   visitadas hasta ahora: ", visited)

func _dir_name(d: Vector2i) -> String:
	match d:
		NORTH: return "NORTE"
		SOUTH: return "SUR  "
		EAST: return "ESTE "
		WEST: return "OESTE"
	return "?"
