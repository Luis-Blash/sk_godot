class_name MovementAbility
extends Ability

@export var speed: float = 16.0
@export var rotation_speed: float = 0.15

var _entity: CharacterBody3D

func init(entity: CharacterBody3D) -> void:
	_entity = entity

func update(delta: float) -> void:
	pass 
	
func process_movement(direction: Vector3) -> void:
	_entity.velocity.x = direction.x * speed
	_entity.velocity.z = direction.z * speed
	
	if direction.length() > 0.1:
		#Rotation player
		var target_angle := atan2(direction.x, direction.z)
		_entity.rotation.y = lerp_angle(_entity.rotation.y, target_angle, rotation_speed)


# CAMERA
func get_input_direction(camara: Camera3D) -> Vector3:
	var input := Vector2.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.y = Input.get_axis("move_up", "move_down")
	
	if input.length() > 1.0:
		input = input.normalized()
	
	if not camara:
		return Vector3(input.x, 0, input.y)
	# Direct camera move
	var angle := deg_to_rad(-camara.current_angle_deg)
	return Vector3(
		input.x * cos(angle) + input.y * sin(angle),
		0,
		-input.x * sin(angle) + input.y * cos(angle)
	)
	
# NORMAL
#func get_input_direction() -> Vector3:
	#var input := Vector2.ZERO
	#input.x = Input.get_axis("move_left", "move_right")
	#input.y = Input.get_axis("move_up", "move_down")
	#
	#if input.length() > 1.0:
		#input = input.normalized()
	#
	#return Vector3(input.x, 0, input.y)
