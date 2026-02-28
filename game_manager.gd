extends Node

signal potion_updated(has_potion, texture, color)
signal score_updated(new_score)

var score = 0

# Inventário de Poção
var has_potion = false
var potion_texture: Texture2D = null
var potion_color: Color = Color.WHITE

func add_score(points: int):
	score += points
	score_updated.emit(score)

func collect_potion(texture: Texture2D, color: Color) -> bool:
	if has_potion:
		return false # Já tem uma poção
	
	has_potion = true
	potion_texture = texture
	potion_color = color
	potion_updated.emit(has_potion, potion_texture, potion_color)
	return true

func use_potion() -> bool:
	if not has_potion:
		return false
	
	# Consome a poção
	has_potion = false
	potion_updated.emit(has_potion, null, Color.WHITE)
	return true
