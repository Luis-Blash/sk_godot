extends Node3D

@export var mouse_sensitivity: float = 0.003
@export var min_pitch: float = -40.0
@export var max_pitch: float = 60.0

var _pitch: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return
	
	# rotación horizontal — gira el pivot en Y
	rotation.y -= event.relative.x * mouse_sensitivity
	
	# rotación vertical — pitch limitado
	_pitch -= event.relative.y * mouse_sensitivity
	_pitch = clamp(_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	rotation.x = _pitch
