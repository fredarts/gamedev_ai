class_name SceneBGMData
extends Resource

## Mapeia uma Cena (.tscn) para uma Música de Fundo (AudioData).
## Usado pelo AudioManager para trocar a música automaticamente.

@export_file("*.tscn") var scene_path: String = ""
@export var bgm_data: AudioData
