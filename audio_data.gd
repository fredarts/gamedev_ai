class_name AudioData
extends Resource

## Define os dados de um efeito sonoro ou música para ser tocado.
## Pode ser reutilizado em múltiplos lugares e entidades.

@export var stream: AudioStream
@export_range(-80.0, 24.0) var volume_db: float = 0.0
@export_range(0.1, 4.0) var pitch_scale: float = 1.0

## Variação randômica do pitch (Ex: 0.1 significa que o pitch varia em +/- 0.1).
## Ótimo para sons de passos, ataques e impactos não soarem repetitivos.
@export_range(0.0, 1.0) var pitch_variation: float = 0.0

## Distância máxima que o som pode ser ouvido (Apenas para sons 2D espaciais).
@export var max_distance: float = 2000.0

## Qual canal de áudio esse som vai tocar (Ex: "Master", "Music", "SFX").
@export var bus: StringName = &"Master"
