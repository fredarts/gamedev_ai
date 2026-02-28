class_name ItemData
extends Resource

## Classe base para todos os itens do jogo.
## Contém os atributos universais compartilhados por armas, poções, materiais, etc.

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export_group("Informações Básicas")
## O nome de exibição do item.
@export var name: String = "Novo Item"
## Descrição rica em detalhes para exibir na UI do inventário (Lore, efeitos, etc).
@export_multiline var description: String = "Descrição detalhada do item."
## O ícone Pixel Art do item.
@export var icon: Texture2D
## Valor de venda do item nos mercadores.
@export var price: int = 10
## Quantidade máxima que pode ser empilhada no mesmo slot do inventário.
@export var max_stack: int = 99

@export_group("Imersão Visual e Sonora")
## A cor da luz emitida quando o item está no chão. Deixe transparente para não emitir luz.
@export var drop_light_color: Color = Color.TRANSPARENT
## Efeito de partículas (Cena) instanciado ao pegar o item do chão (Puff de fumaça, brilho, etc).
@export var pickup_effect: PackedScene
## Som tocado no momento em que o player pega o item.
@export var pickup_sound: AudioStream
## Som tocado quando o player consome/usa o item.
@export var use_sound: AudioStream
## Cena com Particle2D (ou similar) instanciada ao usar o item.
@export var visual_effect: PackedScene

@export_group("Mecânicas de RPG")
## A raridade do item (pode definir a cor do nome na UI).
@export var rarity: Rarity = Rarity.COMMON
## O peso do item, caso você implemente um limite de carga no inventário.
@export var weight: float = 0.1
## Nível mínimo que o jogador precisa ter para equipar/usar.
@export var level_requirement: int = 1
## Se for item de missão, não pode ser vendido ou destruído.
@export var is_quest_item: bool = false
