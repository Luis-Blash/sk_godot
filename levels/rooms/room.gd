class_name Room
extends Node3D

# Para probar en el editor: marca/desmarca y se aplica al correr la escena.
@export var north_open: bool = true
@export var south_open: bool = true
@export var east_open: bool = true
@export var west_open: bool = true


@onready var _doors: Dictionary = {
	Directions.NORTH: $Doors/DoorN,
	Directions.SOUTH: $Doors/DoorS,
	Directions.EAST:  $Doors/DoorE,
	Directions.WEST:  $Doors/DoorW,
}

func _ready() -> void:
	_apply_door(Directions.NORTH, north_open)
	_apply_door(Directions.SOUTH, south_open)
	_apply_door(Directions.EAST, east_open)
	_apply_door(Directions.WEST, west_open)

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
