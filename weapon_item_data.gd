class_name WeaponItemData
extends ItemData

## Classe especializada para armas (Espadas, Arcos, Cajados, etc).
## Permite criar qualquer combinação: Espada Mágica Cortante de Fogo, Arco Físico Perfurante, etc.

enum AttackType { MELEE, RANGED }
enum DamageType { SLASHING, PIERCING, BLUNT }
enum Handling { ONE_HANDED, TWO_HANDED }
enum Element { NONE, FIRE, ICE, POISON, LIGHTNING }

@export_group("Classificação da Arma")
## Como a arma ataca (corpo-a-corpo ou à distância).
@export var attack_type: AttackType = AttackType.MELEE
## O tipo de dano físico base (Cortante, Perfurante, Contusão).
@export var damage_type: DamageType = DamageType.SLASHING
## Se a arma ocupa uma ou duas mãos.
@export var handling: Handling = Handling.ONE_HANDED

@export_group("Status de Combate")
## Dano adicional ou dano base que esta arma causa.
@export var damage_bonus: int = 5
## Modificador do tamanho da Hitbox (ex: 1.5 para uma lança longa).
@export var attack_range_modifier: float = 1.0
## Modificador de velocidade. Reduz o cooldown do CombatComponent (ex: 0.8 para atacar mais rápido).
@export var attack_speed_modifier: float = 1.0
## Força extra aplicada ao knockback do CombatComponent.
@export var knockback_bonus: float = 0.0

@export_group("Propriedades Mágicas")
## Se for verdadeira, a arma inflige dano mágico (pode ignorar armadura física).
@export var is_magical: bool = false
## Tipo elemental do dano, útil para aplicar shaders de fraqueza nos inimigos.
@export var elemental_type: Element = Element.NONE

@export_group("Propriedades Ranged (Apenas se Ranged)")
## A cena do projétil a ser instanciada (Flecha, Bola de Fogo).
@export var projectile_scene: PackedScene
## Velocidade com que o projétil viaja.
@export var projectile_speed: float = 400.0

@export_group("Custo e Resistência")
## Custo de stamina/mana para realizar um ataque com esta arma.
@export var stamina_cost: int = 10
## Quantos golpes a arma aguenta antes de quebrar (0 para inquebrável).
@export var durability: int = 100

