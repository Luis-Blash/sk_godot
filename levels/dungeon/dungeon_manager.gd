extends Node

@export var room_scene: PackedScene
@export var start_coord := Vector2i(0, 0)
## Distancia entre centros de salas vecinas. Coincide con el tamaño del Floor
## (16 x 16) para que los muros y huecos de puerta de salas contiguas encajen.
@export var room_size: float = 32.0

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

# Todas las salas instanciadas, indexadas por su coordenada de cuadricula.
var rooms: Dictionary = {}

func _ready() -> void:
	_build_dungeon()
	_place_player_at(start_coord)

## Instancia TODAS las salas del mapa de golpe y las coloca en el mundo.
func _build_dungeon() -> void:
	for coord in map:
		var room: Room = room_scene.instantiate()
		room_container.add_child(room)
		room.global_position = _coord_to_world(coord)
		# Solo se abren las puertas que dan a una sala vecina existente.
		room.set_open_doors(_open_dirs(coord))
		rooms[coord] = room

## Convierte una coordenada de cuadricula a posicion de mundo.
## coord.x -> eje X, coord.y -> eje Z (igual que Directions: NORTH = -Z).
func _coord_to_world(coord: Vector2i) -> Vector3:
	return Vector3(coord.x * room_size, 0.0, coord.y * room_size)

## Devuelve las direcciones donde hay sala vecina (esas puertas se abren).
func _open_dirs(coord: Vector2i) -> Array:
	var dirs: Array = []
	for d in Directions.ALL:
		if map.has(coord + d):
			dirs.append(d)
	return dirs

## Coloca al player en el centro de la sala indicada.
func _place_player_at(coord: Vector2i) -> void:
	player.velocity = Vector3.ZERO
	player.global_position = _coord_to_world(coord) + Vector3(0, 2, 0)
