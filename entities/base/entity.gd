class_name Entity
extends CharacterBody3D

@export var abilities: Array[Ability] = []

func _ready() -> void:
	for i in abilities.size():
		abilities[i] = abilities[i].duplicate()
		abilities[i].init(self)

func set_speed_multiplier(value: float) -> void:  # <- esto
	for ability in abilities:
		if ability is MovementAbility:
			ability.speed_multiplier = value
			return

func _physics_process(delta: float) -> void:
	for ability in abilities:
		ability.update(delta)
	move_and_slide()
