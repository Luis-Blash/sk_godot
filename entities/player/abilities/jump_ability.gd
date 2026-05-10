class_name JumpAbility
extends Ability

@export var jump_force: float = 15.0
@export var coyote_time: float = 0.12

var _coyote_timer: float = 0.0
var _coyote_used: bool = false

var _entity: CharacterBody3D
func init(entity: CharacterBody3D) -> void:
	_entity = entity

func update(delta: float) -> void:
	_update_coyote(delta)

func jump() -> bool:
	if _can_jump():
		_entity.velocity.y = jump_force
		_consume_coyote()
		return true
	return false

func _update_coyote(delta: float) -> void:
	if _entity.is_on_floor():
		_coyote_timer = coyote_time
		_coyote_used = false
	elif _coyote_timer > 0.0 and not _coyote_used:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

func _can_jump() -> bool:
	return _coyote_timer > 0.0

func _consume_coyote() -> void:
	_coyote_timer = 0.0
	_coyote_used = true
