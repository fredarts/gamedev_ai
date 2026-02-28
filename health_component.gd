extends Node
class_name HealthComponent

signal health_changed(new_health, max_health)
signal died
signal took_damage(amount)

@export var max_health: int = 3
var health: int

func _ready():
	health = max_health
	# Emit initial state
	health_changed.emit(health, max_health)

func take_damage(amount: int):
	health -= amount
	took_damage.emit(amount)
	health_changed.emit(health, max_health)
	
	if health <= 0:
		died.emit()

func heal(amount: int):
	if health < max_health:
		health += amount
		if health > max_health:
			health = max_health
		health_changed.emit(health, max_health)
