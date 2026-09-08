@tool
extends RefCounted
class_name DockSFX

var _parent_control: Control
var _player: AudioStreamPlayer
var _current_preset: String = "coin"
var _current_params: Dictionary = {}

signal sound_generated(path: String)

func setup(parent: Control):
	_parent_control = parent
	_player = AudioStreamPlayer.new()
	if _parent_control:
		_parent_control.add_child(_player)
	_load_preset("coin")

func _load_preset(preset_name: String):
	_current_preset = preset_name
	var SFXPresetsScript = load("res://addons/gamedev_ai/audio/sfx_presets.gd")
	if SFXPresetsScript:
		_current_params = SFXPresetsScript.get_preset(_current_preset)

func play_preview():
	var SFXSynthesizerScript = load("res://addons/gamedev_ai/audio/sfx_synthesizer.gd")
	if SFXSynthesizerScript and not _current_params.is_empty():
		var stream = SFXSynthesizerScript.synthesize(_current_params)
		if _player and stream:
			_player.stream = stream
			_player.play()

func mutate():
	var SFXPresetsScript = load("res://addons/gamedev_ai/audio/sfx_presets.gd")
	if SFXPresetsScript and not _current_params.is_empty():
		_current_params = SFXPresetsScript.mutate(_current_params, 0.15)
		play_preview()

func save_to_file(path: String = "") -> String:
	var SFXSynthesizerScript = load("res://addons/gamedev_ai/audio/sfx_synthesizer.gd")
	var WAVWriterScript = load("res://addons/gamedev_ai/audio/wav_writer.gd")
	
	var target_path = path.strip_edges()
	if target_path == "":
		var timestamp = str(Time.get_unix_time_from_system()).split(".")[0]
		target_path = "res://audio/sfx/" + _current_preset + "_" + timestamp + ".wav"
	elif not target_path.begins_with("res://"):
		target_path = "res://" + target_path
	if not target_path.ends_with(".wav"):
		target_path += ".wav"
		
	var pcm_data = SFXSynthesizerScript.synthesize_pcm(_current_params)
	var err = WAVWriterScript.save_wav(target_path, pcm_data)
	if err == OK:
		sound_generated.emit(target_path)
		return target_path
	return ""

func insert_into_current_scene(player_name: String = "") -> bool:
	if not Engine.is_editor_hint():
		return false
		
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		return false
		
	# First save file so it is a permanent resource
	var wav_path = save_to_file()
	if wav_path == "":
		return false
		
	var stream = load(wav_path)
	if not stream:
		return false
		
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	var target_parent = root
	if not selected_nodes.is_empty() and selected_nodes[0] is Node:
		target_parent = selected_nodes[0]
		
	var new_player = AudioStreamPlayer.new()
	if player_name != "":
		new_player.name = player_name
	else:
		new_player.name = _current_preset.capitalize().replace(" ", "") + "Player"
		
	new_player.stream = stream
	
	target_parent.add_child(new_player)
	new_player.owner = root
	
	EditorInterface.save_scene()
	return true
