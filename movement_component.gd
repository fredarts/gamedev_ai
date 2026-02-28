class_name MovementComponent
extends Node

@export var walk_speed: float = 100.0
@export var run_speed: float = 200.0

var entity: CharacterBody2D

func _ready() -> void:
	entity = get_parent() as CharacterBody2D

func move(direction: Vector2) -> void:
	if entity:
		# Compatibility if still used by something else, default to run_speed
		entity.velocity = direction * run_speed
		entity.move_and_slide()

func process_movement(delta: float) -> void:
	pass
