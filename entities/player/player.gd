class_name Player
extends Entity

var movement: MovementAbility
@export var camera: Camera3D

func _ready() -> void:
	super()
	for ability in abilities:
		if ability is MovementAbility:
			movement = ability

func _physics_process(delta: float) -> void:
	if not movement:
		return
		
	var direction := movement.get_input_direction(camera)
	movement.process_movement(direction)
	
	super(delta)
