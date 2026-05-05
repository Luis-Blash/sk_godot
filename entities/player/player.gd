class_name Player
extends Entity

@export var gravity: float = 55.0
@export var camera: Camera3D

var movement: MovementAbility

func _ready() -> void:
	super()
	for ability in abilities:
		if ability is MovementAbility:
			movement = ability

func _physics_process(delta: float) -> void:
	if not movement:
		return
		
	velocity.y -= gravity * delta
		
	var direction := movement.get_input_direction(camera)
	movement.process_movement(direction)
	
	super(delta)
