class_name NextScene
extends Control

## Escena que sigue una vez cumplido min_duration.
@export var scene: PackedScene
## Tiempo minimo que se muestra este splash antes de poder avanzar.
@export var min_duration: float = 3.0
## Duracion del fundido de entrada/salida.
@export var fade_duration: float = 0.4

var _fade_rect: ColorRect


func _ready() -> void:
	_setup_fade()
	await _fade_in()
	await get_tree().create_timer(min_duration).timeout
	_on_min_duration_reached()


## Las hijas sobreescriben esto: auto-avanzar, mostrar boton, etc.
func _on_min_duration_reached() -> void:
	go_next()


func go_next() -> void:
	if scene:
		await _fade_out()
		get_tree().change_scene_to_packed(scene)


func _setup_fade() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.BLACK
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)


func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, fade_duration)
	await tween.finished


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 1.0, fade_duration)
	await tween.finished
