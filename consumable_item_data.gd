class_name ConsumableItemData
extends ItemData

## Classe especializada para itens de consumo (Poções, Comidas, Pergaminhos).
## Trabalha em conjunto com HealthComponent e MovementComponent.

enum StatusEffect { NONE, REGEN, STRENGTH, SPEED, INVISIBILITY }

@export_group("Efeitos de Consumo")
## Quantidade de vida restaurada instantaneamente.
@export var health_restored: int = 0
## Quantidade de mana/stamina restaurada instantaneamente.
@export var mana_restored: int = 0

@export_group("Buffs Temporários")
## Tipo de efeito contínuo aplicado ao jogador.
@export var status_effect: StatusEffect = StatusEffect.NONE
## Duração do buff em segundos.
@export var effect_duration: float = 0.0
## Bônus temporário de velocidade de movimento (soma com o MovementComponent).
@export var movement_speed_bonus: float = 0.0
