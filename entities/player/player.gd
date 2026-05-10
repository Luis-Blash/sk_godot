class_name Player
extends Entity

@export var gravity: float = 55.0
@export var camera: Camera3D
@onready var areaAttack: Area3D = $Area3D

var movement: MovementAbility
var attack: AttackAbility

func _ready() -> void:
	super()
	areaAttack.monitoring = false
	for ability in abilities:
		if ability is MovementAbility:
			movement = ability
		if ability is AttackAbility:
			attack = ability
			attack._area = areaAttack
			attack.setup_area()

func _physics_process(delta: float) -> void:
	if not movement:
		return
		
	velocity.y -= gravity * delta
	var direction := movement.get_input_direction(camera)
	movement.process_movement(direction)
	
	if Input.is_action_just_pressed("attack"):
		attack.onAttack()
	
	super(delta)
