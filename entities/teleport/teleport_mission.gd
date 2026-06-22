extends Node3D

## Escena a la que se teletransporta el player al entrar en el area.
@export var move_to_scene: PackedScene

@onready var _area: Area3D = $Area3D

func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	if move_to_scene == null:
		push_warning("TeleportMission: 'move_to_scene' no asignada en %s" % name)
		return
	get_tree().change_scene_to_packed.bind(move_to_scene).call_deferred()
