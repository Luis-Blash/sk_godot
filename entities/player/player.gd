class_name Player
extends Entity

@export var gravity: float = 55.0
@export var camera: Camera3D
@onready var areaAttack: Area3D = $Area3D

var movement: MovementAbility
var attack: AttackAbility
var jump: JumpAbility
var dash: DashAbility

func _ready() -> void:
	super()
	movement = get_ability(MovementAbility)
	jump = get_ability(JumpAbility)
	dash = get_ability(DashAbility)
	attack = get_ability(AttackAbility)
	if attack:
		attack._area = areaAttack
		attack.setup_area()

func _physics_process(delta: float) -> void:
	if not movement:
		return

	velocity.y -= gravity * delta
	var direction := movement.get_input_direction(camera)
	movement.process_movement(direction)

	if Input.is_action_just_pressed("jump") and jump:
		jump.jump()
	if Input.is_action_just_pressed("dash") and dash:
		dash.start_dash()
	if Input.is_action_just_released("dash") and dash:
		dash.stop_dash()
	if Input.is_action_just_pressed("attack") and attack:
		attack.onAttack()

	super(delta)
