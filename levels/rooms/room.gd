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

@onready var roomArea: Area3D = $roomArea

var status: Dictionary = {
	"visited": false,
	"hasCofre": false,
	"hasEnemy": false,
	"hasBoss": false
}

func _ready() -> void:
	_apply_door(Directions.NORTH, north_open)
	_apply_door(Directions.SOUTH, south_open)
	_apply_door(Directions.EAST, east_open)
	_apply_door(Directions.WEST, west_open)
	roomArea.body_entered.connect(_on_body_entered_room)

## El DungeonManager llamara esto al cargar la sala, pasandole que lados
## tienen vecino. Las puertas sin vecino quedan tapadas con su muro.
func set_open_doors(directions: Array) -> void:
	for dir in _doors:
		_apply_door(dir, directions.has(dir))

## El DungeonManager pasa el tipo de sala (del map) para definir su contenido:
## si lleva cofre o enemigos. Se llama al crear la sala, antes de entrar.
func set_room_type(type: String) -> void:
	match type:
		"tesoro":
			status["hasCofre"] = true
		"jefe":
			status["hasBoss"] = true
		"normal":
			status["hasEnemy"] = randf() < 0.5

func _apply_door(dir: Vector2i, open: bool) -> void:
	var door: Node3D = _doors[dir]
	var blocker: CSGBox3D = door.get_node("Blocker")
	blocker.visible = not open
	blocker.use_collision = not open
	
func _on_body_entered_room(body: Node3D) -> void:
	if body.is_in_group("player") and status["visited"] == false:
		status["visited"] = true
		print("¡El jugador entró!")
