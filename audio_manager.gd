extends Node

## Gerenciador Global de Áudio (Autoload/Singleton).
## Toca músicas de fundo (BGM) automaticamente com base na cena atual
## e gerencia sons de Interface Gráfica (UI).

@export var bgm_playlist: Array[SceneBGMData] = []
@export var default_crossfade_duration: float = 1.5

var _bgm_player_1: AudioStreamPlayer
var _bgm_player_2: AudioStreamPlayer
var _active_bgm_player: AudioStreamPlayer
var _crossfade_tween: Tween
var _current_scene_path: String = ""

func _ready() -> void:
	# Cria os dois players necessários para o efeito de crossfade
	_bgm_player_1 = AudioStreamPlayer.new()
	_bgm_player_2 = AudioStreamPlayer.new()
	
	add_child(_bgm_player_1)
	add_child(_bgm_player_2)
	
	_active_bgm_player = _bgm_player_1
	
	# Aguarda um frame para garantir que a cena inicial foi carregada
	call_deferred("_check_initial_scene")

## Função chamada todo frame. Ideal para detectar mudança de cena de forma passiva.
func _process(_delta: float) -> void:
	var tree := get_tree()
	if not tree or not tree.current_scene:
		return
		
	var new_scene_path := tree.current_scene.scene_file_path
	
	# Se a cena mudou desde a última checagem
	if new_scene_path != _current_scene_path and not new_scene_path.is_empty():
		_current_scene_path = new_scene_path
		_on_scene_changed(new_scene_path)

func _check_initial_scene() -> void:
	var tree := get_tree()
	if tree and tree.current_scene:
		_current_scene_path = tree.current_scene.scene_file_path
		_on_scene_changed(_current_scene_path)

func _on_scene_changed(new_scene_path: String) -> void:
	# Procura na playlist se existe uma música configurada para esta cena
	var found_bgm: AudioData = null
	
	for entry in bgm_playlist:
		# Compara usando o caminho completo (res://...) ou o UID (uid://...)
		# A Godot 4 salva caminhos de export_file como UID por padrão se o arquivo existir.
		# Então precisamos checar se o caminho do entry corresponde ao UID ou ao resource_path da cena atual
		if entry:
			var is_match = false
			# Checa se o texto configurado bate exatamente
			if entry.scene_path == new_scene_path:
				is_match = true
			# Checa se o texto configurado é um UID e bate com a cena
			elif entry.scene_path.begins_with("uid://"):
				var loaded_res = load(entry.scene_path)
				if loaded_res and loaded_res.resource_path == new_scene_path:
					is_match = true
					
			if is_match:
				found_bgm = entry.bgm_data
				break
			
	if found_bgm:
		play_bgm(found_bgm, default_crossfade_duration)
	else:
		stop_bgm(default_crossfade_duration)

## Toca um som global (Ex: clique de botão, notificação).
func play_ui_sound(audio_data: AudioData) -> void:
	if not audio_data or not audio_data.stream:
		return
		
	var player = AudioStreamPlayer.new()
	player.stream = audio_data.stream
	player.volume_db = audio_data.volume_db
	
	var actual_pitch = audio_data.pitch_scale
	if audio_data.pitch_variation > 0.0:
		actual_pitch += randf_range(-audio_data.pitch_variation, audio_data.pitch_variation)
	player.pitch_scale = actual_pitch
	
	player.bus = audio_data.bus
	
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)

## Inicia uma nova música de fundo com transição suave.
func play_bgm(audio_data: AudioData, crossfade_duration: float = 1.5) -> void:
	if not audio_data or not audio_data.stream:
		return
		
	# Se a mesma música já estiver tocando, ignora e mantém tocando
	if _active_bgm_player.stream == audio_data.stream and _active_bgm_player.playing:
		return
		
	# Descobre qual player está livre
	var fading_out_player = _active_bgm_player
	var fading_in_player = _bgm_player_2 if _active_bgm_player == _bgm_player_1 else _bgm_player_1
	
	_active_bgm_player = fading_in_player
	
	# Configura a nova música
	fading_in_player.stream = audio_data.stream
	fading_in_player.bus = audio_data.bus
	fading_in_player.pitch_scale = audio_data.pitch_scale
	fading_in_player.volume_db = -80.0 # Começa mudo
	fading_in_player.play()
	
	# Reseta o Tween anterior
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
		
	_crossfade_tween = create_tween()
	_crossfade_tween.set_parallel(true)
	
	# Fade In
	_crossfade_tween.tween_property(fading_in_player, "volume_db", audio_data.volume_db, crossfade_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Fade Out
	if fading_out_player.playing:
		_crossfade_tween.tween_property(fading_out_player, "volume_db", -80.0, crossfade_duration) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
	# Para o player antigo ao fim do fade
	_crossfade_tween.chain().tween_callback(fading_out_player.stop)

## Para a música atual com fade out.
func stop_bgm(fade_duration: float = 1.0) -> void:
	if not _active_bgm_player.playing:
		return
		
	if _crossfade_tween and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
		
	_crossfade_tween = create_tween()
	_crossfade_tween.tween_property(_active_bgm_player, "volume_db", -80.0, fade_duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_crossfade_tween.tween_callback(_active_bgm_player.stop)
