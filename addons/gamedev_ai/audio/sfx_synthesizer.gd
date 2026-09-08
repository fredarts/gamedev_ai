@tool
extends RefCounted
class_name SFXSynthesizer

enum Waveform {
	SINE,
	SQUARE,
	SAWTOOTH,
	TRIANGLE,
	WHITE_NOISE,
	CHIPTUNE_NOISE
}

const SAMPLE_RATE: int = 44100

static func synthesize(params: Dictionary) -> AudioStreamWAV:
	var pcm_data = synthesize_pcm(params)
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = pcm_data
	return stream

static func synthesize_pcm(params: Dictionary) -> PackedByteArray:
	var wave_type = params.get("waveform", Waveform.SQUARE)
	var start_freq: float = params.get("start_freq", 440.0)
	var end_freq: float = params.get("end_freq", start_freq)
	var duration: float = clampf(params.get("duration", 0.3), 0.05, 5.0)
	
	# ADSR envelope parameters (fractions of duration)
	var attack_time: float = params.get("attack_time", 0.01)
	var decay_time: float = params.get("decay_time", 0.05)
	var sustain_level: float = params.get("sustain_level", 0.6)
	var release_time: float = params.get("release_time", 0.15)
	
	# Pitch modulation
	var arpeggio_semitones: Array = params.get("arpeggio", []) # Array of int semitones
	var arpeggio_speed: float = params.get("arpeggio_speed", 0.05) # seconds per step
	var vibrato_depth: float = params.get("vibrato_depth", 0.0)
	var vibrato_speed: float = params.get("vibrato_speed", 10.0)
	var square_duty: float = clampf(params.get("duty_cycle", 0.5), 0.1, 0.9)
	
	# Bitcrusher / Lo-Fi
	var bit_crush: int = params.get("bit_crush", 16) # 4 to 16
	var bit_mask: int = 0
	if bit_crush < 16:
		var shift = 16 - bit_crush
		bit_mask = ~((1 << shift) - 1)
	
	# Filter (simple IIR low-pass)
	var low_pass_cutoff: float = params.get("low_pass", 1.0) # 0.05 to 1.0
	
	var total_samples = int(duration * SAMPLE_RATE)
	if total_samples <= 0:
		total_samples = 100
		
	var buffer = PackedByteArray()
	buffer.resize(total_samples * 2) # 16-bit = 2 bytes per sample
	
	var phase: float = 0.0
	var prev_sample: float = 0.0
	var lfsr: int = 0x7FFF # For periodic chiptune noise
	
	var attack_samples = int(attack_time * SAMPLE_RATE)
	var decay_samples = int(decay_time * SAMPLE_RATE)
	var release_samples = int(release_time * SAMPLE_RATE)
	var sustain_samples = total_samples - attack_samples - decay_samples - release_samples
	if sustain_samples < 0:
		# Scale envelope to fit duration
		var sum = attack_samples + decay_samples + release_samples
		if sum > 0:
			var scale = float(total_samples) / sum
			attack_samples = int(attack_samples * scale)
			decay_samples = int(decay_samples * scale)
			release_samples = total_samples - attack_samples - decay_samples
			sustain_samples = 0
			
	var anti_click_fade_in = int(0.002 * SAMPLE_RATE) # 2ms fade in
	var anti_click_fade_out = int(0.005 * SAMPLE_RATE) # 5ms fade out
	
	for i in range(total_samples):
		var progress = float(i) / total_samples
		var current_time = float(i) / SAMPLE_RATE
		
		# 1. Calculate Frequency (Base + Slide + Arpeggio + Vibrato)
		var freq = lerpf(start_freq, end_freq, progress)
		
		if not arpeggio_semitones.is_empty():
			var arp_idx = int(current_time / maxf(arpeggio_speed, 0.01)) % arpeggio_semitones.size()
			var semitone = arpeggio_semitones[arp_idx]
			freq *= pow(2.0, semitone / 12.0)
			
		if vibrato_depth > 0.0:
			freq += sin(current_time * vibrato_speed * TAU) * vibrato_depth
			
		freq = clampf(freq, 20.0, 20000.0)
		
		# 2. Phase Increment
		phase += freq / SAMPLE_RATE
		if phase >= 1.0:
			phase -= floor(phase)
			
		# 3. Waveform Generation
		var sample_val = 0.0
		match wave_type:
			Waveform.SINE:
				sample_val = sin(phase * TAU)
			Waveform.SQUARE:
				sample_val = 1.0 if phase < square_duty else -1.0
			Waveform.SAWTOOTH:
				sample_val = 2.0 * phase - 1.0
			Waveform.TRIANGLE:
				sample_val = 4.0 * abs(phase - 0.5) - 1.0
			Waveform.WHITE_NOISE:
				sample_val = randf_range(-1.0, 1.0)
			Waveform.CHIPTUNE_NOISE:
				# 15-bit shift register noise (classic Game Boy / NES)
				if (i % 8) == 0:
					var bit = ((lfsr >> 0) ^ (lfsr >> 1)) & 1
					lfsr = (lfsr >> 1) | (bit << 14)
				sample_val = 1.0 if (lfsr & 1) == 1 else -1.0
				
		# 4. ADSR Envelope
		var env = 1.0
		if i < attack_samples:
			env = float(i) / maxf(attack_samples, 1)
		elif i < attack_samples + decay_samples:
			var decay_progress = float(i - attack_samples) / maxf(decay_samples, 1)
			env = lerpf(1.0, sustain_level, decay_progress)
		elif i < attack_samples + decay_samples + sustain_samples:
			env = sustain_level
		else:
			var rel_idx = i - (attack_samples + decay_samples + sustain_samples)
			var rel_progress = float(rel_idx) / maxf(release_samples, 1)
			env = lerpf(sustain_level, 0.0, rel_progress)
			
		# 5. Anti-Click Micro-Fades
		if i < anti_click_fade_in:
			env *= float(i) / anti_click_fade_in
		if i >= total_samples - anti_click_fade_out:
			var out_idx = total_samples - i
			env *= float(out_idx) / anti_click_fade_out
			
		sample_val *= env
		
		# 6. Low-Pass Filter
		if low_pass_cutoff < 0.99:
			sample_val = lerpf(prev_sample, sample_val, clampf(low_pass_cutoff, 0.02, 1.0))
			prev_sample = sample_val
			
		# 7. Soft Clipper (Anti-distortion)
		sample_val = clampf(sample_val, -1.0, 1.0)
		sample_val = sample_val * 0.95 # Safety headroom
		
		# 8. Convert to 16-bit Integer PCM
		var int_sample = int(sample_val * 32767.0)
		if bit_mask != 0:
			int_sample = int_sample & bit_mask
			
		int_sample = clampi(int_sample, -32768, 32767)
		if int_sample < 0:
			int_sample += 65536
			
		var byte_idx = i * 2
		buffer[byte_idx] = int_sample & 0xFF
		buffer[byte_idx + 1] = (int_sample >> 8) & 0xFF
		
	return buffer
