extends Control

## Emitida al presionar "Regresar", para que el menú padre vuelva a su panel principal.
signal back_pressed

## Resoluciones disponibles en el dropdown de Opciones.
const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]

@onready var _option_resolution: OptionButton = $VBoxOptions/option_resolution
@onready var _check_fullscreen: CheckBox = $VBoxOptions/check_fullscreen
@onready var _button_back: Button = $VBoxOptions/btn_back

func _ready() -> void:
	_setup_resolution_options()
	_check_fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_check_fullscreen.toggled.connect(_on_fullscreen_toggled)
	_option_resolution.item_selected.connect(_on_resolution_selected)
	_button_back.pressed.connect(_on_back_pressed)

func focus_default() -> void:
	_option_resolution.grab_focus()

func _on_back_pressed() -> void:
	back_pressed.emit()

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
