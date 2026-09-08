@tool
extends RefCounted
class_name WAVWriter

static func save_wav(path: String, pcm_data: PackedByteArray, sample_rate: int = 44100) -> Error:
	if not path.begins_with("res://"):
		return ERR_INVALID_PARAMETER
		
	var global_path = ProjectSettings.globalize_path(path)
	var dir_path = global_path.get_base_dir()
	
	if not DirAccess.dir_exists_absolute(dir_path):
		var make_err = DirAccess.make_dir_recursive_absolute(dir_path)
		if make_err != OK:
			return make_err
			
	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
		
	var data_size = pcm_data.size()
	var chunk_size = 36 + data_size
	var channels: int = 1
	var bits_per_sample: int = 16
	var byte_rate: int = sample_rate * channels * (bits_per_sample / 8)
	var block_align: int = channels * (bits_per_sample / 8)
	
	# --- 1. RIFF Header ---
	file.store_string("RIFF")
	file.store_32(chunk_size)
	file.store_string("WAVE")
	
	# --- 2. Format Chunk ---
	file.store_string("fmt ")
	file.store_32(16) # Subchunk1Size (16 for PCM)
	file.store_16(1)  # AudioFormat (1 for PCM)
	file.store_16(channels)
	file.store_32(sample_rate)
	file.store_32(byte_rate)
	file.store_16(block_align)
	file.store_16(bits_per_sample)
	
	# --- 3. Data Chunk ---
	file.store_string("data")
	file.store_32(data_size)
	file.store_buffer(pcm_data)
	
	file.close()
	
	# Trigger filesystem scan in editor so Godot imports the .wav
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()
		
	return OK
