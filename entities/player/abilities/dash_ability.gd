class_name DashAbility
extends Ability

@export var dash_keep: float = 2.0
@export var decel_speed: float = 3.0

var _entity: CharacterBody3D
var _is_dashing: bool = false
var _current_multiplier: float = 1.0

func init(entity: CharacterBody3D) -> void:
	_entity = entity

func start_dash() -> void:
	_is_dashing = true

func stop_dash() -> void:
	_is_dashing = false
	
func update(delta: float) -> void:
	if _is_dashing:
		_current_multiplier = dash_keep
	else:
		_current_multiplier = move_toward(_current_multiplier, 1.0, decel_speed * delta)
	_entity.set_speed_multiplier(_current_multiplier)
