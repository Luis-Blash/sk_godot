class_name AttackAbility
extends Ability

@export var damage: float = 10.0
@export var attack_duration: float = 0.2

var _entity: CharacterBody3D
var _area: Area3D

func init(entity: CharacterBody3D) -> void:
	_entity = entity

func setup_area() -> void:
	_area.monitoring = false
	_area.body_entered.connect(_on_body_entered)

func onAttack() -> void:
	if not _area:
		return
	_area.monitoring = true
	await _entity.get_tree().create_timer(attack_duration).timeout
	_area.monitoring = false

func _on_body_entered(body: Node3D) -> void:
	if body == _entity:
		return
	print("hit: ", body.name)
	# aquí va el daño cuando tengas sistema de salud
