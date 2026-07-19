extends CanvasLayer

@onready var _button_resume: Button = $Control/containerMenu/btn_resume
@onready var _button_options: Button = $Control/containerMenu/btn_opcion
@onready var _button_menu: Button = $Control/containerMenu/btn_menu

@onready var _main_panel: VBoxContainer = $Control/containerMenu
@onready var _options_panel: Control = $Control/PanelOptions

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_button_resume.pressed.connect(_on_resume_pressed)
	_button_options.pressed.connect(_on_options_pressed)
	_button_menu.pressed.connect(_on_menu_pressed)
	_options_panel.back_pressed.connect(_on_back_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var is_paused := not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	if is_paused:
		_main_panel.visible = true
		_options_panel.visible = false
		_button_resume.grab_focus()

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_options_pressed() -> void:
	_main_panel.visible = false
	_options_panel.visible = true
	_options_panel.focus_default()

func _on_back_pressed() -> void:
	_options_panel.visible = false
	_main_panel.visible = true
	_button_options.grab_focus()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main/main_menu.tscn")
