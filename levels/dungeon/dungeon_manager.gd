extends Node

@export var room_scene: PackedScene
## Distancia entre centros de salas vecinas. Coincide con el tamaño del Floor
## (16 x 16) para que los muros y huecos de puerta de salas contiguas encajen.
@export var room_size: float = 32.0

@export_group("Generacion")
## Total de salas, incluye inicio y jefe.
@export var total_rooms: int = 15
## Cuantas salas de tesoro repartir entre las normales.
@export var treasure_count: int = 3
## Pega aqui el seed que aparece en el log para reproducir un mapa concreto.
## Dejalo en 0 para que cada partida sea aleatoria.
@export var replay_seed: int = 0

@onready var player: CharacterBody3D = $Player
@onready var room_container: Node3D = $RoomContainer

# El mapa { Vector2i: String } lo genera MapGenerator en _ready.
var map: Dictionary = {}

# Todas las salas instanciadas, indexadas por su coordenada de cuadricula.
var rooms: Dictionary = {}

func _ready() -> void:
	map = _generate_map()
	_build_dungeon()
	_place_player_at(MapGenerator.START)

## Crea el rng y pide el mapa al generador. Si `replay_seed` != 0 usa ese seed
## para reproducir un mapa; si es 0 elige uno aleatorio. En ambos casos
## imprime el seed usado y el mapa generado para poder depurar/replicar.
func _generate_map() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	if replay_seed != 0:
		rng.seed = replay_seed
	else:
		rng.randomize()
	var used_seed: int = rng.seed
	var generated_map: Dictionary = MapGenerator.generate(total_rooms, treasure_count, rng)
	print("[Dungeon] seed=%d" % used_seed)
	print("[Dungeon] map=%s" % generated_map)
	return generated_map

## Instancia TODAS las salas del mapa de golpe y las coloca en el mundo.
func _build_dungeon() -> void:
	for coord in map:
		var room: Room = room_scene.instantiate()
		room_container.add_child(room)
		room.global_position = _coord_to_world(coord)
		# Solo se abren las puertas que dan a una sala vecina existente.
		room.set_open_doors(_open_dirs(coord))
		# El tipo del map define si la sala lleva cofre o enemigos.
		room.set_room_type(map[coord])
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
