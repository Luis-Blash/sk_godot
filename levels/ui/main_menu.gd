extends Control

## Escena a cargar al presionar "Iniciar".
@export var scene_to_load: PackedScene

@onready var _button_start: Button = $VBoxContainer/btn_start
@onready var _button_options: Button = $VBoxContainer/btn_opcion
@onready var _button_exit: Button = $VBoxContainer/btn_exit

func _ready() -> void:
	_button_start.pressed.connect(_on_start_pressed)
	_button_options.pressed.connect(_on_options_pressed)
	_button_exit.pressed.connect(_on_exit_pressed)

func _on_start_pressed() -> void:
	if scene_to_load == null:
		push_warning("MainMenu: 'scene_to_load' no asignada.")
		return
	get_tree().change_scene_to_packed.bind(scene_to_load).call_deferred()

func _on_options_pressed() -> void:
	pass

func _on_exit_pressed() -> void:
	get_tree().quit()
