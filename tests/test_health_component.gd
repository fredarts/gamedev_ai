extends Node

func test_initial_health():
	var health_comp = HealthComponent.new()
	health_comp.max_health = 5
	health_comp._ready() # Chama manualmente para inicializar
	
	assert(health_comp.health == 5, "A vida inicial deve ser igual ao max_health (5)")
	health_comp.free()

func test_take_damage():
	var health_comp = HealthComponent.new()
	health_comp.max_health = 10
	health_comp._ready()
	
	health_comp.take_damage(3)
	assert(health_comp.health == 7, "A vida deve reduzir para 7 após receber 3 de dano")
	health_comp.free()

func test_heal_limits():
	var health_comp = HealthComponent.new()
	health_comp.max_health = 5
	health_comp._ready()
	
	health_comp.take_damage(3) # Vida cai para 2
	health_comp.heal(10) # Cura em 10 (excedendo o máximo)
	
	assert(health_comp.health == 5, "A vida não pode exceder o limite máximo (5) ao ser curado")
	health_comp.free()

func test_death_signal():
	var health_comp = HealthComponent.new()
	health_comp.max_health = 3
	health_comp._ready()
	
	var died_emitted := false
	health_comp.died.connect(func(): died_emitted = true)
	
	health_comp.take_damage(3)
	
	assert(died_emitted, "Deve emitir o sinal 'died' quando a vida chegar a 0")
	health_comp.free()
