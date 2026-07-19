class_name NextScene
extends Control

## Escena que sigue una vez cumplido min_duration.
@export var scene: PackedScene
## Tiempo minimo que se muestra este splash antes de poder avanzar.
@export var min_duration: float = 3.0


func _ready() -> void:
	await get_tree().create_timer(min_duration).timeout
	_on_min_duration_reached()


## Las hijas sobreescriben esto: auto-avanzar, mostrar boton, etc.
func _on_min_duration_reached() -> void:
	go_next()


func go_next() -> void:
	if scene:
		get_tree().change_scene_to_packed(scene)
