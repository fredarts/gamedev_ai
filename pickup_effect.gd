class_name PickupEffect
extends GPUParticles2D

## Script simples para garantir que a partícula toque uma vez e depois se destrua
## para não acumular memória (Memory Leak) no jogo.

func _ready() -> void:
	# Garante que a emissão comece ao entrar na cena
	emitting = true
	# Assim que todas as partículas sumirem, o nó se deleta automaticamente
	finished.connect(queue_free)
