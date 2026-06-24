class_name Room
extends Node3D

## Escena del cofre que se instancia en salas de tesoro (chestGodot.tscn).
@export var chest_scene: PackedScene


@onready var _doors: Dictionary = {
	Directions.NORTH: $Doors/DoorN,
	Directions.SOUTH: $Doors/DoorS,
	Directions.EAST:  $Doors/DoorE,
	Directions.WEST:  $Doors/DoorW,
}

@onready var roomArea: Area3D = $roomArea
@onready var _chest_mark: Marker3D = $Spawn/Mark5

var _chest: Node3D = null
# True mientras el player esta dentro del Area3D del cofre (rango de interaccion).
var _player_in_chest: bool = false

# Direcciones cuyas puertas tienen vecino (las que se pueden abrir/cerrar).
# Las puertas sin vecino siempre quedan tapadas con su muro.
var _open_dirs: Array = []

var status: Dictionary = {
	"visited": false,
	"hasChest": false,
	"hasEnemy": false,
	"hasBoss": false,
	"chestOpen": false
}

func _ready() -> void:
	roomArea.body_entered.connect(_on_body_entered_room)

## El DungeonManager llamara esto al cargar la sala, pasandole que lados
## tienen vecino. Las puertas sin vecino quedan tapadas con su muro.
func set_open_doors(directions: Array) -> void:
	_open_dirs = directions.duplicate()
	for dir in _doors:
		_apply_door(dir, directions.has(dir))

## El DungeonManager pasa el tipo de sala (del map) para definir su contenido:
## si lleva cofre o enemigos. Se llama al crear la sala, antes de entrar.
func set_room_type(type: String) -> void:
	match type:
		"tesoro":
			status["hasChest"] = true
			_spawn_chest()
		"jefe":
			status["hasBoss"] = true
		"normal":
			status["hasEnemy"] = randf() < 0.5

## Instancia el cofre en el marcador central (Mark5) y lo deja oculto
## hasta que el player entre a la sala.
func _spawn_chest() -> void:
	if chest_scene == null:
		return
	_chest = chest_scene.instantiate()
	add_child(_chest)
	_chest.position = _chest_mark.position
	_chest.visible = false
	# Rastrea si el player esta en rango para poder abrir el cofre con "interact".
	var chest_area: Area3D = _chest.get_node("Area3D")
	chest_area.body_entered.connect(_on_chest_body_entered)
	chest_area.body_exited.connect(_on_chest_body_exited)

func _apply_door(dir: Vector2i, open: bool) -> void:
	var door: Node3D = _doors[dir]
	var blocker: CSGBox3D = door.get_node("Blocker")
	blocker.visible = not open
	blocker.use_collision = not open

## Cierra (locked=true) o reabre (locked=false) solo las puertas con vecino.
## Las puertas sin vecino siguen tapadas con su muro.
func _lock_doors(locked: bool) -> void:
	for dir in _open_dirs:
		_apply_door(dir, not locked)

func _on_body_entered_room(body: Node3D) -> void:
	if body.is_in_group("player") and status["visited"] == false:
		status["visited"] = true
		print("¡El jugador entró!")
		if _chest != null:
			_chest.visible = true
			_lock_doors(true)

func _on_chest_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_chest = true

func _on_chest_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_in_chest = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in_chest and not status["chestOpen"]:
		_open_chest()

## Abre el cofre (al presionar "interact" en rango) y reabre las puertas.
func _open_chest() -> void:
	status["chestOpen"] = true
	print("¡Cofre abierto!")
	_lock_doors(false)
