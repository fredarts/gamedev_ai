# Plano de Implementação: UI Theme & Responsive Component Generator (Godot 4.3+)

**Arquivo:** `docs/PLAN-ui-theme-generator.md`  
**Autor:** `project-planner` / `game-developer`  
**Status:** Planejamento Concluído — Pronto para Revisão  

---

## 🎯 1. Visão Geral & Experiência do Usuário (UX)

O **UI Theme Generator** é um estúdio completo de design e componentização de interface para Godot 4.3+, permitindo gerar temas de alto padrão visual (`Theme` `.tres`), paletas harmoniosas e componentes de interface responsivos prontos para uso (HUDs, Menus de Pausa, Inventários, Caixas de Diálogo e Telas de Título).

---

## 🖥️ 2. Como Será a Experiência do Usuário (User Experience Journey)

O desenvolvedor poderá interagir com o gerador de duas formas fluidas: **Visualmente pelo Dock do Godot** ou **Via Chat com a IA**.

### 🌟 Fluxo Visual no Dock (Aba "🎨 UI Studio")
```
┌─────────────────────────────────────────────────────────────┐
│ 🎨 Gamedev AI - UI Theme Studio                             │
├─────────────────────────────────────────────────────────────┤
│ Preset de Tema: [ Modern Dark Glassmorphism ▾ ]             │
│ Paleta Base:   [ Primária: #3B82F6 ] [ Acento: #10B981 ]    │
│ Superfície:    [ Fundo: #0F172A ]    [ Borda: #334155 ]     │
│ Cantos (Radius): [━━━●━━━━━] 10px   Borda: [━●━━━━━━] 2px    │
│ Estilo:        (●) Glassmorphism  ( ) RPG Gold  ( ) Cyberpunk│
├─────────────────────────────────────────────────────────────┤
│ 👁️ PREVIEW EM TEMPO REAL:                                    │
│   [ Normal Button ]  [ Hovered Button ]  [ Disabled Button ]│
│   Progress: [████████░░░░] 65%   Slider: [━━━●━━━━] 40%     │
├─────────────────────────────────────────────────────────────┤
│ 🔘 [ Gerar Tema & Definir Global no Projeto ]               │
│ 📦 [ Instanciar Componente Responsivo na Cena Aberta... ▾ ] │
│    ├── 🎮 HUD de Gameplay Completo (HP/Mana/Minimap)        │
│    ├── ⚙️ Menu de Pausa & Configurações de Áudio/Vídeo      │
│    ├── 🎒 Grade de Inventário com Slots e Tooltips         │
│    ├── 💬 Caixa de Diálogo RPG com Retrato e Escolhas       │
│    └── 🏆 Tela de Título / Menu Principal com Animações    │
└─────────────────────────────────────────────────────────────┘
```

### 💬 Fluxo Via Chat (Linguagem Natural com a IA)
* **Exemplo 1:** *"Crie um tema Cyberpunk Neon escuro com botões arredondados e aplique como tema padrão do jogo."*
  * **Ação da IA:** Executa `generate_ui_theme`, cria `res://themes/theme_cyberpunk.tres`, configura `ProjectSettings.gui/theme/custom` e recarrega o tema no editor.
* **Exemplo 2:** *"Crie um Menu de Pausa com abas de áudio, vídeo e controles usando o tema do meu jogo e anexe à cena atual."*
  * **Ação da IA:** Executa `create_responsive_ui_component`, gera `res://scenes/ui/pause_menu.tscn` perfeitamente ancorado (Full Rect) com containers responsivos (`MarginContainer`, `VBoxContainer`, `HSlider`).

---

## 🎨 3. Biblioteca de Estilos & Presets de Design

O gerador trará presets matematicamente calibrados com harmonia de cores, contraste acessível e hierarquia tipográfica:

| Preset | Identidade Visual | Elementos Chave |
| :--- | :--- | :--- |
| **Sleek Glassmorphism** | Moderno, translúcido e minimalista | Fundo `#121826d9`, borda highlight `#ffffff26`, cantos 10px, sombras suaves de dispersão. |
| **Cyberpunk Neon** | Futurista, alta tecnologia e contraste | Fundo grafite escuro `#0a0d14`, azul neon `#00f0ff`, rosa choque `#ff0055`, cantos retos 2px ou chanfrados. |
| **RPG Fantasy Gold** | Medieval nobre, pergaminho e ouro | Fundo obsidiana `#10141d`, borda dourada `#d4af37`, botões com relevo e fontes clássicas. |
| **Cozy / Pastel Casual** | Acolhedor, suave e amigável | Cores quentes/pastel `#2d3142`, menta `#06d6a0`, botões em formato de pílula (radius 24px). |
| **Retro Pixel 16-Bit** | Nostálgico, arcade clássico | Bordas duras sólidas de 3px, cantos 0px, alto contraste preto/branco e cores vibrantes primárias. |

---

## 🛠️ 4. Catálogo de Ferramentas a Implementar

### 1. `generate_ui_theme`
* **Função:** Gera um recurso `Theme` `.tres` completo para todos os controles principais do Godot (`Button`, `Panel`, `LineEdit`, `ProgressBar`, `HSlider`, `TabContainer`, `PopupMenu`, `Window`, `Label`).
* **Parâmetros:**
  * `preset_or_name`: `STRING` (`"glassmorphism"`, `"cyberpunk"`, `"fantasy_gold"`, `"cozy_pastel"`, `"retro_pixel"`, `"custom"`)
  * `save_path`: `STRING` (ex: `"res://themes/theme_main.tres"`)
  * `colors`: `DICTIONARY` (customização opcional: `primary`, `background`, `accent`, `text`, `border`)
  * `metrics`: `DICTIONARY` (customização opcional: `corner_radius`, `border_width`, `font_size_base`, `shadow_size`)
  * `set_as_project_theme`: `BOOLEAN` (default: `true`, registra no `ProjectSettings`)

### 2. `create_responsive_ui_component`
* **Função:** Instancia ou gera uma cena `.tscn` de componente responsivo pronta para produção, com nós de layout adequados (`MarginContainer`, `PanelContainer`, `GridContainer`), âncoras automáticas e conexões de sinais.
* **Componentes Suportados:**
  * `"hud"`: Barras de vida/mana, contador de moedas, moldura de minimap e hotbar.
  * `"pause_menu"`: Modal de pausa com sliders de volume (Master/Music/SFX) e botões Continuar/Opções/Sair.
  * `"inventory_grid"`: Grade responsiva de slots com badges de quantidade e detector de clique/hover.
  * `"dialogue_box"`: Caixa inferior com retrato do personagem, nome estilizado e `RichTextLabel` com suporte a BBCode.
  * `"main_menu"`: Tela de título responsiva com pilha vertical de botões e efeitos visuais.
* **Parâmetros:**
  * `component_type`: `STRING`
  * `save_path`: `STRING` (ex: `"res://ui/pause_menu.tscn"`)
  * `theme_path`: `STRING` (caminho do `.tres` a vincular)
  * `parent_node_path`: `STRING` (se instanciar diretamente na cena aberta)

### 3. `apply_theme_to_scene`
* **Função:** Aplica um tema `.tres` recursivamente a uma árvore de nós existente ou substitui overrides individuais para harmonizar a cena.
* **Parâmetros:**
  * `node_path`: `STRING`
  * `theme_path`: `STRING`

### 4. `inspect_theme`
* **Função:** Inspeciona as classes configuradas, cores e fontes de um recurso `.tres` existente.

---

## 📦 5. Arquitetura de Código

| Arquivo | Ação | Descrição |
| :--- | :--- | :--- |
| `addons/gamedev_ai/ui_studio/theme_builder.gd` | **[NOVO]** | Construtor programático de `StyleBoxFlat`, paletas e `Theme` `.tres` |
| `addons/gamedev_ai/ui_studio/component_templates.gd` | **[NOVO]** | Fábrica de cenas de componentes responsivos (HUD, Pause, Inventário, Diálogo) |
| `addons/gamedev_ai/tools/ui_theme_tools.gd` | **[NOVO]** | Handler de tools integrado ao `ToolExecutor` |
| `addons/gamedev_ai/dock/dock_ui_studio.gd` | **[NOVO]** | Controlador da aba visual "🎨 UI Studio" no Dock do plugin |
| `addons/gamedev_ai/tool_executor.gd` | **[MODIFICAR]** | Registro de handlers e schemas JSON em `get_tool_definitions()` |
| `addons/gamedev_ai/test_ui_theme_tools.gd` | **[NOVO]** | Testes automatizados de geração de tema e montagem de componentes |

---

## 🧪 6. Plano de Validação & Testes Automatizados

1. **Teste de Geração de Tema:** Gerar temas nos 5 presets principais e validar se todos os `StyleBoxFlat` contêm propriedades válidas de cor, borda e raio.
2. **Teste de Registro no ProjectSettings:** Verificar se `ProjectSettings.set_setting("gui/theme/custom", path)` é aplicado e salvo sem erros.
3. **Teste de Criação de Componentes Responsivos:** Gerar as 5 cenas de templates e validar que usam âncoras e containers (`MarginContainer`, `PanelContainer`, `GridContainer`).
