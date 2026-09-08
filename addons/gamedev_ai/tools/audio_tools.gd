@tool
extends BaseToolHandler
class_name AudioTools

var _preview_player: AudioStreamPlayer

func _init():
	_preview_player = AudioStreamPlayer.new()
	if Engine.is_editor_hint():
		var base = EditorInterface.get_base_control()
		if base:
			base.add_child(_preview_player)

func execute(tool_name: String, args: Dictionary) -> bool:
	match tool_name:
		"generate_sfx":
			_generate_sfx(args.get("preset", "coin"), args.get("path", ""), args.get("params", {}))
			return true
		"play_sfx_preview":
			_play_sfx_preview(args.get("preset", "coin"), args.get("params", {}))
			return true
	return false

func _generate_sfx(preset_or_desc: String, path: String = "", custom_params: Dictionary = {}):
	var SFXPresetsScript = load("res://addons/gamedev_ai/audio/sfx_presets.gd")
	var SFXSynthesizerScript = load("res://addons/gamedev_ai/audio/sfx_synthesizer.gd")
	var WAVWriterScript = load("res://addons/gamedev_ai/audio/wav_writer.gd")
	
	var preset_name = SFXPresetsScript.resolve_preset(preset_or_desc)
	var params = SFXPresetsScript.get_preset(preset_name)
	
	# Apply custom overrides
	for k in custom_params:
		params[k] = custom_params[k]
		
	# Auto-generate path if omitted
	var target_path = path.strip_edges()
	if target_path == "":
		var timestamp = str(Time.get_unix_time_from_system()).split(".")[0]
		target_path = "res://audio/sfx/" + preset_name + "_" + timestamp + ".wav"
	elif not target_path.begins_with("res://"):
		target_path = "res://" + target_path
	if not target_path.ends_with(".wav"):
		target_path += ".wav"
		
	var pcm_data = SFXSynthesizerScript.synthesize_pcm(params)
	var err = WAVWriterScript.save_wav(target_path, pcm_data)
	
	if err == OK:
		var duration = params.get("duration", 0.3)
		var msg = "🎵 [b]SFX Generated Successfully![/b]\n"
		msg += "• [b]Preset:[/b] " + preset_name + " (from '" + preset_or_desc + "')\n"
		msg += "• [b]Path:[/b] `" + target_path + "`\n"
		msg += "• [b]Duration:[/b] " + str(snappedf(duration, 0.01)) + "s (16-bit 44.1kHz WAV)\n"
		msg += "[i]The audio file has been imported and is ready to attach to an AudioStreamPlayer.[/i]"
		_emit_output(msg)
	else:
		_emit_output("[color=red]Error generating SFX at " + target_path + ". Code: " + str(err) + "[/color]")

func _play_sfx_preview(preset_or_desc: String, custom_params: Dictionary = {}):
	var SFXPresetsScript = load("res://addons/gamedev_ai/audio/sfx_presets.gd")
	var SFXSynthesizerScript = load("res://addons/gamedev_ai/audio/sfx_synthesizer.gd")
	
	var preset_name = SFXPresetsScript.resolve_preset(preset_or_desc)
	var params = SFXPresetsScript.get_preset(preset_name)
	
	for k in custom_params:
		params[k] = custom_params[k]
		
	var stream = SFXSynthesizerScript.synthesize(params)
	if _preview_player and stream:
		_preview_player.stream = stream
		_preview_player.play()
		_emit_output("🔊 Playing preview of SFX: [b]" + preset_name + "[/b]")
	else:
		_emit_output("SFX synthesized (" + preset_name + ").")
