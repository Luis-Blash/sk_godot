class_name JumpAbility
extends Ability

@export var jump_force: float = 15.0

var _entity: CharacterBody3D

func init(entity: CharacterBody3D) -> void:
	_entity = entity

func update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump()

func jump() -> bool:
	if _entity.is_on_floor():
		_entity.velocity.y = jump_force
		return true
	return false
