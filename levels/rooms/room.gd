class_name Room
extends Node3D

## Emitida cuando el player cruza una puerta abierta. El DungeonManager (Fase 2)
## escuchará esto para cargar la sala vecina en esa direccion.
signal player_entered_door(direction: Vector2i)

# Direcciones en coordenadas de cuadricula (mismo Vector2i que usa el mapa).
const NORTH := Vector2i(0, -1)
const SOUTH := Vector2i(0, 1)
const EAST := Vector2i(1, 0)
const WEST := Vector2i(-1, 0)

# Para probar en el editor: marca/desmarca y se aplica al correr la escena.
@export var north_open: bool = true
@export var south_open: bool = true
@export var east_open: bool = true
@export var west_open: bool = true

@onready var _doors: Dictionary = {
	NORTH: $Doors/DoorN,
	SOUTH: $Doors/DoorS,
	EAST: $Doors/DoorE,
	WEST: $Doors/DoorW,
}

func _ready() -> void:
	_apply_door(NORTH, north_open)
	_apply_door(SOUTH, south_open)
	_apply_door(EAST, east_open)
	_apply_door(WEST, west_open)
	for dir in _doors:
		var area: Area3D = _doors[dir].get_node("Area3D")
		area.body_entered.connect(_on_door_body_entered.bind(dir))

## El DungeonManager llamara esto al cargar la sala, pasandole que lados
## tienen vecino. Las puertas sin vecino quedan tapadas con su muro.
func set_open_doors(directions: Array) -> void:
	for dir in _doors:
		_apply_door(dir, directions.has(dir))

## Posicion global donde reaparece el player al entrar por ese lado.
func get_entry_point(dir: Vector2i) -> Vector3:
	return _doors[dir].get_node("Entry").global_position

func _apply_door(dir: Vector2i, open: bool) -> void:
	var door: Node3D = _doors[dir]
	var blocker: CSGBox3D = door.get_node("Blocker")
	var area: Area3D = door.get_node("Area3D")
	var shape: CollisionShape3D = area.get_node("CollisionShape3D")
	# Puerta abierta: sin muro tapando + zona de teleport activa.
	blocker.visible = not open
	blocker.use_collision = not open
	area.monitoring = open
	shape.disabled = not open

func _on_door_body_entered(body: Node3D, dir: Vector2i) -> void:
	if body.is_in_group("player"):
		player_entered_door.emit(dir)
