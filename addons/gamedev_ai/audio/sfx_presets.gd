@tool
extends RefCounted
class_name SFXPresets

static func get_preset_names() -> Array[String]:
	return [
		"coin", "laser", "laser_heavy", "explosion", "jump",
		"hit", "hurt", "powerup", "blip", "ui_click",
		"ui_confirm", "ui_cancel", "dash", "game_over", "victory"
	]

static func get_preset(name: String, variation_seed: int = 0) -> Dictionary:
	var base = _get_raw_preset(name)
	if variation_seed != 0:
		return mutate(base, 0.15, variation_seed)
	return base

static func _get_raw_preset(name: String) -> Dictionary:
	match name.to_lower():
		"coin":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 987.77, # B5
				"end_freq": 1318.51,  # E6
				"duration": 0.28,
				"attack_time": 0.005,
				"decay_time": 0.05,
				"sustain_level": 0.4,
				"release_time": 0.18,
				"duty_cycle": 0.5,
				"arpeggio": [0, 5],
				"arpeggio_speed": 0.08
			}
		"laser":
			return {
				"waveform": SFXSynthesizer.Waveform.SAWTOOTH,
				"start_freq": 1200.0,
				"end_freq": 180.0,
				"duration": 0.22,
				"attack_time": 0.005,
				"decay_time": 0.08,
				"sustain_level": 0.2,
				"release_time": 0.12,
				"low_pass": 0.85
			}
		"laser_heavy":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 800.0,
				"end_freq": 100.0,
				"duration": 0.35,
				"attack_time": 0.005,
				"decay_time": 0.12,
				"sustain_level": 0.3,
				"release_time": 0.18,
				"duty_cycle": 0.25,
				"low_pass": 0.5
			}
		"explosion":
			return {
				"waveform": SFXSynthesizer.Waveform.WHITE_NOISE,
				"start_freq": 300.0,
				"end_freq": 60.0,
				"duration": 0.7,
				"attack_time": 0.005,
				"decay_time": 0.25,
				"sustain_level": 0.15,
				"release_time": 0.4,
				"low_pass": 0.35
			}
		"jump":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 160.0,
				"end_freq": 620.0,
				"duration": 0.22,
				"attack_time": 0.01,
				"decay_time": 0.06,
				"sustain_level": 0.4,
				"release_time": 0.12,
				"duty_cycle": 0.5
			}
		"hit":
			return {
				"waveform": SFXSynthesizer.Waveform.CHIPTUNE_NOISE,
				"start_freq": 400.0,
				"end_freq": 120.0,
				"duration": 0.15,
				"attack_time": 0.005,
				"decay_time": 0.06,
				"sustain_level": 0.1,
				"release_time": 0.08,
				"low_pass": 0.7
			}
		"hurt":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 380.0,
				"end_freq": 140.0,
				"duration": 0.25,
				"attack_time": 0.005,
				"decay_time": 0.08,
				"sustain_level": 0.2,
				"release_time": 0.15,
				"duty_cycle": 0.35
			}
		"powerup":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 330.0, # E4
				"end_freq": 660.0,
				"duration": 0.45,
				"attack_time": 0.01,
				"decay_time": 0.05,
				"sustain_level": 0.5,
				"release_time": 0.25,
				"arpeggio": [0, 4, 7, 12],
				"arpeggio_speed": 0.07,
				"duty_cycle": 0.5
			}
		"blip":
			return {
				"waveform": SFXSynthesizer.Waveform.SINE,
				"start_freq": 880.0,
				"end_freq": 880.0,
				"duration": 0.06,
				"attack_time": 0.005,
				"decay_time": 0.02,
				"sustain_level": 0.1,
				"release_time": 0.03
			}
		"ui_click":
			return {
				"waveform": SFXSynthesizer.Waveform.TRIANGLE,
				"start_freq": 1200.0,
				"end_freq": 400.0,
				"duration": 0.035,
				"attack_time": 0.002,
				"decay_time": 0.015,
				"sustain_level": 0.0,
				"release_time": 0.015
			}
		"ui_confirm":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 523.25, # C5
				"end_freq": 1046.50, # C6
				"duration": 0.18,
				"attack_time": 0.005,
				"decay_time": 0.04,
				"sustain_level": 0.3,
				"release_time": 0.12,
				"arpeggio": [0, 7, 12],
				"arpeggio_speed": 0.04,
				"duty_cycle": 0.5
			}
		"ui_cancel":
			return {
				"waveform": SFXSynthesizer.Waveform.SAWTOOTH,
				"start_freq": 400.0,
				"end_freq": 180.0,
				"duration": 0.16,
				"attack_time": 0.005,
				"decay_time": 0.05,
				"sustain_level": 0.1,
				"release_time": 0.09,
				"low_pass": 0.6
			}
		"dash":
			return {
				"waveform": SFXSynthesizer.Waveform.WHITE_NOISE,
				"start_freq": 800.0,
				"end_freq": 300.0,
				"duration": 0.25,
				"attack_time": 0.03,
				"decay_time": 0.1,
				"sustain_level": 0.2,
				"release_time": 0.1,
				"low_pass": 0.5
			}
		"game_over":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 440.0,
				"end_freq": 110.0,
				"duration": 0.8,
				"attack_time": 0.01,
				"decay_time": 0.2,
				"sustain_level": 0.3,
				"release_time": 0.45,
				"arpeggio": [0, -2, -5, -8],
				"arpeggio_speed": 0.15,
				"duty_cycle": 0.4
			}
		"victory":
			return {
				"waveform": SFXSynthesizer.Waveform.SQUARE,
				"start_freq": 440.0,
				"end_freq": 880.0,
				"duration": 0.7,
				"attack_time": 0.01,
				"decay_time": 0.1,
				"sustain_level": 0.5,
				"release_time": 0.35,
				"arpeggio": [0, 4, 7, 12, 16],
				"arpeggio_speed": 0.1,
				"duty_cycle": 0.5
			}
		_:
			# Default fallback: Coin
			return _get_raw_preset("coin")

static func resolve_preset(description: String) -> String:
	var lower = description.to_lower().strip_edges()
	
	if "coin" in lower or "moeda" in lower or "gold" in lower or "ouro" in lower or "pickup" in lower or "item" in lower:
		return "coin"
	if "laser" in lower or "shoot" in lower or "tiro" in lower or "disparo" in lower or "plasma" in lower:
		if "heavy" in lower or "pesado" in lower or "cannon" in lower or "canhao" in lower:
			return "laser_heavy"
		return "laser"
	if "explosion" in lower or "explosao" in lower or "bomb" in lower or "bomba" in lower or "boom" in lower:
		return "explosion"
	if "jump" in lower or "pulo" in lower or "salto" in lower or "bounce" in lower or "quicar" in lower:
		return "jump"
	if "hit" in lower or "golpe" in lower or "soco" in lower or "punch" in lower or "impact" in lower:
		return "hit"
	if "hurt" in lower or "dano" in lower or "damage" in lower or "morrer" in lower:
		return "hurt"
	if "powerup" in lower or "buff" in lower or "upgrade" in lower or "levelup" in lower or "level up" in lower:
		return "powerup"
	if "click" in lower or "clique" in lower or "botao" in lower or "button" in lower:
		return "ui_click"
	if "confirm" in lower or "ok" in lower or "sucesso" in lower or "success" in lower:
		return "ui_confirm"
	if "cancel" in lower or "erro" in lower or "error" in lower or "negar" in lower:
		return "ui_cancel"
	if "dash" in lower or "vento" in lower or "whoosh" in lower or "desvio" in lower:
		return "dash"
	if "game_over" in lower or "game over" in lower or "derrota" in lower or "defeat" in lower:
		return "game_over"
	if "victory" in lower or "vitoria" in lower or "win" in lower or "ganhou" in lower or "fanfare" in lower:
		return "victory"
	if "blip" in lower or "fala" in lower or "dialogue" in lower or "voice" in lower:
		return "blip"
		
	return "coin"

static func mutate(params: Dictionary, amount: float = 0.15, seed_val: int = 0) -> Dictionary:
	var rng = RandomNumberGenerator.new()
	if seed_val != 0:
		rng.seed = seed_val
	else:
		rng.randomize()
		
	var copy = params.duplicate(true)
	
	if copy.has("start_freq"):
		var factor = 1.0 + rng.randf_range(-amount, amount)
		copy["start_freq"] = clampf(copy["start_freq"] * factor, 40.0, 12000.0)
		
	if copy.has("end_freq"):
		var factor = 1.0 + rng.randf_range(-amount, amount)
		copy["end_freq"] = clampf(copy["end_freq"] * factor, 40.0, 12000.0)
		
	if copy.has("duration"):
		var factor = 1.0 + rng.randf_range(-amount, amount)
		copy["duration"] = clampf(copy["duration"] * factor, 0.05, 3.0)
		
	if copy.has("duty_cycle"):
		var delta = rng.randf_range(-amount * 0.5, amount * 0.5)
		copy["duty_cycle"] = clampf(copy["duty_cycle"] + delta, 0.15, 0.85)
		
	return copy
