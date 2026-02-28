class_name ShieldItemData
extends ItemData

## Classe especializada para Escudos.
## Focada em defesa, bloqueio de dano e resistências elementais.

@export_group("Status de Defesa")
## Quantidade de dano físico base que o escudo absorve ao bloquear.
@export var base_defense: int = 10
## Custo de stamina/energia para manter o bloqueio ou absorver um golpe.
@export var block_stamina_cost: int = 15
## Quantos golpes o escudo aguenta antes de quebrar (0 para inquebrável).
@export var durability: int = 100

@export_group("Propriedades Mágicas")
## Se for verdadeiro, o escudo pode bloquear ataques mágicos ou refletir projéteis mágicos.
@export var is_magical: bool = false

@export_group("Resistências Elementais (%)")
## Porcentagem de dano de Fogo bloqueada (0.0 a 1.0). Ex: 0.30 reduz 30% do dano. Valores negativos aumentam o dano recebido.
@export_range(-1.0, 1.0) var fire_resistance: float = 0.0
## Porcentagem de dano de Gelo bloqueada (0.0 a 1.0).
@export_range(-1.0, 1.0) var ice_resistance: float = 0.0
## Porcentagem de dano de Veneno bloqueada (0.0 a 1.0).
@export_range(-1.0, 1.0) var poison_resistance: float = 0.0
## Porcentagem de dano de Raio bloqueada (0.0 a 1.0).
@export_range(-1.0, 1.0) var lightning_resistance: float = 0.0
