class_name AudioMappingData
extends Resource

## Associa um nome amigável a um arquivo de áudio.
## Facilita o preenchimento no Inspetor da Godot.

## O nome descritivo da ação (Ex: "step", "attack", "hurt"). 
## Este é o exato nome que você usará no Call Method Track da Animação.
@export var action_name: StringName = &""

## O recurso de som (AudioData) que será tocado para esta ação.
@export var audio_data: AudioData
