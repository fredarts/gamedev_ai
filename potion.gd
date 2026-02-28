extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verifica se é o Player
	if body.is_in_group("player") or body.name == "Player":
		
		# Acessa o componente de vida do Player
		var health_comp = body.get_node_or_null("HealthComponent")
		
		if health_comp:
			# Prioridade 1: Curar se estiver ferido (consome imediatamente)
			if health_comp.health < health_comp.max_health:
				# O Player tem um método 'heal' que encapsula a lógica visual + componente
				if body.has_method("heal"):
					body.heal(1)
					queue_free()
				return # Se curou, não precisa fazer mais nada
			
		# Prioridade 2: Guardar se estiver cheio e não tiver poção no inventário
		if body.has_method("collect_potion"):
			# Pega a referência visual da poção
			var sprite = $Sprite2D
			
			# Envia os dados visuais para o player guardar
			# O método collect_potion retorna true se conseguiu guardar
			if body.collect_potion(sprite.texture, sprite.modulate):
				queue_free()
