class_name AudioComponent
extends Node2D

## Componente modular responsável por tocar sons espaciais 2D em Entidades.
## Adicione como filho de um Player, Inimigo ou Objeto interativo.

## Lista de mapeamentos de sons para facilitar o preenchimento no Inspetor.
## Adicione elementos aqui para associar nomes (ex: "step") a recursos de áudio.
@export var sound_mappings: Array[AudioMappingData] = []

## Dicionário interno otimizado para busca rápida durante o jogo.
var _sounds_dict: Dictionary = {}

func _ready() -> void:
	# Converte a lista amigável do Inspetor em um dicionário super rápido para o jogo rodar
	for mapping in sound_mappings:
		if mapping and not mapping.action_name.is_empty() and mapping.audio_data:
			_sounds_dict[mapping.action_name] = mapping.audio_data

## Toca um som pelo nome configurado na lista de mapeamentos
func play_sfx(sfx_name: StringName) -> void:
	if _sounds_dict.has(sfx_name):
		play_audio(_sounds_dict[sfx_name])
	else:
		push_warning("AudioComponent em %s tentou tocar '%s', mas não foi mapeado." % [get_parent().name, sfx_name])

## Toca um som espacial instanciando um AudioStreamPlayer2D temporário
func play_audio(audio_data: AudioData) -> void:
	if not audio_data or not audio_data.stream:
		push_warning("AudioComponent em %s tentou tocar um AudioData vazio." % get_parent().name)
		return
		
	var player = AudioStreamPlayer2D.new()
	player.stream = audio_data.stream
	player.volume_db = audio_data.volume_db
	
	# Aplica a variação de pitch (para o som não ficar idêntico toda vez)
	var actual_pitch = audio_data.pitch_scale
	if audio_data.pitch_variation > 0.0:
		actual_pitch += randf_range(-audio_data.pitch_variation, audio_data.pitch_variation)
	player.pitch_scale = actual_pitch
	
	player.max_distance = audio_data.max_distance
	player.bus = audio_data.bus
	
	# Adiciona à árvore, toca o som e configura para se auto-destruir no final
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
