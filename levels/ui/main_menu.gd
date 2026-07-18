extends Control

## Escena a cargar al presionar "Iniciar".
@export var scene_to_load: PackedScene

## Resoluciones disponibles en el dropdown de Opciones.
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]

@onready var _button_start: Button = $VBoxContainer/btn_start
@onready var _button_options: Button = $VBoxContainer/btn_opcion
@onready var _button_exit: Button = $VBoxContainer/btn_exit

@onready var _main_panel: VBoxContainer = $VBoxContainer
@onready var _options_panel: Control = $PanelOptions
@onready var _option_resolution: OptionButton = $PanelOptions/VBoxOptions/option_resolution
@onready var _check_fullscreen: CheckBox = $PanelOptions/VBoxOptions/check_fullscreen
@onready var _button_back: Button = $PanelOptions/VBoxOptions/btn_back

func _ready() -> void:
	_button_start.pressed.connect(_on_start_pressed)
	_button_options.pressed.connect(_on_options_pressed)
	_button_exit.pressed.connect(_on_exit_pressed)
	_button_back.pressed.connect(_on_back_pressed)
	_setup_resolution_options()
	_check_fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_check_fullscreen.toggled.connect(_on_fullscreen_toggled)
	_option_resolution.item_selected.connect(_on_resolution_selected)
	_button_start.grab_focus()

func _on_start_pressed() -> void:
	if scene_to_load == null:
		push_warning("MainMenu: 'scene_to_load' no asignada.")
		return
	get_tree().change_scene_to_packed.bind(scene_to_load).call_deferred()

func _on_options_pressed() -> void:
	_main_panel.visible = false
	_options_panel.visible = true
	_option_resolution.grab_focus()

func _on_back_pressed() -> void:
	_options_panel.visible = false
	_main_panel.visible = true
	_button_options.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _setup_resolution_options() -> void:
	for size in RESOLUTIONS:
		_option_resolution.add_item("%d x %d" % [size.x, size.y])
	var current_size := DisplayServer.window_get_size()
	var current_index := RESOLUTIONS.find(current_size)
	if current_index != -1:
		_option_resolution.select(current_index)

func _on_resolution_selected(index: int) -> void:
	DisplayServer.window_set_size(RESOLUTIONS[index])

func _on_fullscreen_toggled(is_fullscreen: bool) -> void:
	var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if is_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
