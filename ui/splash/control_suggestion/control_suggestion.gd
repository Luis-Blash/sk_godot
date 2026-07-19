extends NextScene

@onready var btn_accept:Button = $VBoxContainer/btn_accept


func _ready() -> void:
	super._ready()
	btn_accept.pressed.connect(go_next)


func _on_min_duration_reached() -> void:
	btn_accept.visible = true
	btn_accept.grab_focus()
