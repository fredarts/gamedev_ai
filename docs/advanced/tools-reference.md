# Todas as Ferramentas da IA (Tools Reference)

O **Gamedev AI** possui **65 ferramentas internas** que o assistente pode chamar autonomamente durante uma conversa ou via servidor MCP (Model Context Protocol). Essas ferramentas são o "braço mecânico" que permite à IA interagir diretamente com o Godot Engine.

---

## 🔧 1. Scripts e Código GDScript

### `create_script`
Cria um novo arquivo GDScript (`.gd`) no caminho especificado com tipagem estática e boas práticas.
- **Parâmetros:** `path` (`res://...`), `content` (código completo).

### `edit_script`
Substitui o conteúdo inteiro de um script existente por uma nova versão.
- **Parâmetros:** `path`, `content`.
- ⚠️ *Deprecado em favor do `patch_script` para evitar sobrescritas desnecessárias.*

### `patch_script`
Edição cirúrgica: busca um bloco exato de código dentro do script e substitui apenas aquele trecho pelo novo conteúdo sem alterar o restante do arquivo.
- **Parâmetros:** `path`, `search_content` (bloco exato a encontrar), `replace_content` (novo bloco).

### `replace_selection`
Substitui o texto atualmente selecionado no Editor de Scripts do Godot (usado pelos botões de ação rápida como Refatorar e Corrigir).
- **Parâmetros:** `text` (novo código).

### `view_file_outline`
Retorna o sumário estrutural de um script: `class_name`, `extends`, funções, sinais, exports, enums, constantes e classes internas com seus números de linha.
- **Parâmetros:** `path`.

### `get_lsp_diagnostics`
Consulta em tempo real o Godot Language Server (LSP) para capturar avisos e erros de compilação/sintaxe do script antes de rodar o jogo.
- **Parâmetros:** `path`.

---

## 🌳 2. Nós e Manipulação da Scene Tree

### `add_node`
Adiciona um novo nó à cena aberta no editor (Node2D, CharacterBody2D/3D, Label, Button, etc.).
- **Parâmetros:** `parent_path` (use `.` para a raiz), `type` (classe do nó), `name`, `script_path` (opcional).

### `remove_node`
Remove um nó da Scene Tree da cena atual. Requer confirmação de segurança.
- **Parâmetros:** `node_path`.

### `set_property`
Altera qualquer propriedade de um nó no Inspector (posição, rotação, escala, textura, cores, visibilidade).
- **Parâmetros:** `node_path`, `property`, `value`.

### `set_theme_override`
Define um override de tema em nós do tipo Control (tamanho de fonte, cores, stylebox).
- **Parâmetros:** `node_path`, `override_type` (`color`, `constant`, `font`, `font_size`, `stylebox`), `name`, `value`.

### `connect_signal`
Conecta um sinal de um nó emissor a um método de um nó receptor na cena atual.
- **Parâmetros:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (opcional), `flags` (opcional).

### `disconnect_signal`
Desconecta um sinal previamente conectado entre dois nós.
- **Parâmetros:** `source_path`, `signal_name`, `target_path`, `method_name`.

### `attach_script`
Anexa um arquivo GDScript existente a um nó na cena.
- **Parâmetros:** `node_path`, `script_path`.

### `analyze_node_children`
Retorna a árvore hierárquica detalhada de um nó específico até uma profundidade configurável.
- **Parâmetros:** `node_path`, `max_depth` (padrão: 5).

---

## 📂 3. Arquivos, Cenas e Recursos

### `read_file`
Lê o conteúdo completo de qualquer arquivo de texto do projeto.
- **Parâmetros:** `path`.

### `list_dir`
Lista os arquivos e subdiretórios de uma pasta do projeto.
- **Parâmetros:** `path`.

### `find_file`
Busca arquivos no projeto por padrão de nome ou extensão.
- **Parâmetros:** `pattern`.

### `remove_file`
Deleta um arquivo ou diretório do disco após confirmação.
- **Parâmetros:** `path`.

### `move_files_batch`
Move ou renomeia múltiplos arquivos em lote, atualizando automaticamente dependências internas do Godot.
- **Parâmetros:** `moves` (dicionário de caminho antigo para novo caminho).

### `create_scene`
Cria um novo arquivo de cena (`.tscn`) com o nó raiz configurado e a abre no editor.
- **Parâmetros:** `path`, `root_type`, `root_name`.

### `instance_scene`
Instancia uma cena `.tscn` como filha de um nó na cena atualmente aberta.
- **Parâmetros:** `parent_path`, `scene_path`, `name`.

### `create_resource`
Cria novos arquivos de recurso (`.tres`) para itens, inventários, estatísticas ou configurações.
- **Parâmetros:** `path`, `type`, `properties` (opcional).

---

## 🔍 4. Busca, Inspeção e Análise

### `grep_search`
Busca textual com suporte a filtros de extensão em todos os arquivos do projeto.
- **Parâmetros:** `query`, `include` (opcional), `max_results` (padrão: 20).

### `search_in_files`
Busca por expressões regulares (Regex) em todos os scripts do projeto.
- **Parâmetros:** `pattern`.

### `get_class_info`
Consulta o `ClassDB` do Godot para extrair métodos, propriedades, sinais e constantes de qualquer classe do engine.
- **Parâmetros:** `class_name`.

### `capture_editor_screenshot`
Tira uma captura de tela em tempo real da janela do editor Godot para análise visual multimodal da IA.

---

## 🧠 5. Memória Persistente e Conhecimento (RAG)

### `save_memory`
Salva uma decisão arquitetural, preferência ou padrão na memória persistente do projeto.
- **Parâmetros:** `category` (`architecture`, `convention`, `preference`, `bug_fix`, `project_info`), `content`.

### `list_memories`
Lista todas as memórias salvas associadas ao projeto.

### `delete_memory`
Remove um registro de memória pelo seu identificador.
- **Parâmetros:** `id`.

### `read_skill`
Carrega o conteúdo de uma das 25 habilidades embutidas de desenvolvimento de jogos.
- **Parâmetros:** `skill_name`.

### `index_codebase`
Gera embeddings vetoriais de todos os scripts do projeto no banco vetorial local (Vector DB).

### `semantic_search`
Realiza buscas semânticas por intenção e significado no código indexado.
- **Parâmetros:** `query`.

---

## 🔊 6. Áudio e Efeitos Sonoros Procedurais

### `generate_sfx`
Sintetiza proceduralmente efeitos sonoros em formato WAV com reprodução retro/arcade (pulos, tiros, explosões, moedas, powerups, cliques, dano).
- **Parâmetros:** `preset` (`jump`, `laser`, `explosion`, `coin`, `powerup`, `hit`, `click`), `save_path` (opcional).

### `play_sfx_preview`
Gera e reproduz uma prévia do som sintetizado em tempo real sem gravar no disco.
- **Parâmetros:** `preset`.

---

## 🎨 7. Shaders e Sintetizador Visual

### `generate_shader`
Gera arquivos `.gdshader` customizados para canvas 2D, materiais espaciais 3D ou pós-processamento.
- **Parâmetros:** `preset` (`dissolve`, `hologram`, `outline`, `hit_flash`, `water`, `pixelate`, `glow`, `glitch`, `fire`, etc.), `mode` (`canvas_item`, `spatial`, `particles`), `save_path` (opcional).

### `apply_shader_to_node`
Cria ou atualiza um `ShaderMaterial` e o anexa ao nó 2D ou 3D selecionado.
- **Parâmetros:** `node_path`, `shader_path`, `uniform_values` (opcional).

### `get_shader_presets_list`
Retorna o catálogo completo de presets de shaders disponíveis e seus parâmetros/uniformes.

---

## 🗺️ 8. TileMaps, Terrenos e Masmorras Procedurais

### `configure_tileset_atlas`
Configura atlas de texturas para um `TileSet`, definindo tamanho dos tiles, camadas de física (colisões) e grupos de terreno.
- **Parâmetros:** `texture_path`, `tile_size` (ex: `[16, 16]`), `save_path`, `terrain_set_config`, `physics_config`.

### `build_tilemap_layout`
Pinta uma matriz bidimensional inteira de tiles em um nó `TileMapLayer`.
- **Parâmetros:** `layer_node_path`, `layout_matrix` (matriz 2D de IDs de tiles), `source_id`.

### `paint_terrain_cells`
Pinta células com auto-tiling inteligente usando o sistema nativo de terrenos do Godot 4.
- **Parâmetros:** `layer_node_path`, `terrain_set`, `terrain_id`, `cell_coordinates`.

### `read_tilemap_layout`
Lê coordenadas e IDs de tiles posicionados em uma área retangular do TileMap.
- **Parâmetros:** `layer_node_path`, `bounding_box` (opcional).

### `clear_tilemap_region`
Remove tiles de uma região delimitada ou lista de coordenadas.
- **Parâmetros:** `layer_node_path`, `rect` ou `cell_coordinates`.

### `generate_procedural_dungeon`
Gera masmorras completas (salas, corredores, conexões, portas e escadas) usando algoritmos BSP, Random Walk ou Cellular Automata e as grava no TileMap.
- **Parâmetros:** `width`, `height`, `algorithm`, `min_room_size`, `max_rooms`, `seed` (opcional).

### `scaffold_autotile_bitmasks`
Configura automaticamente as máscaras de bits (bitmasks) de terrenos 2x2, 3x3 minimal, 16-pipe ou 47-tile em um recurso de TileSet.
- **Parâmetros:** `tileset_path`, `terrain_set`, `terrain_id`, `pattern_type`.

### `get_atlas_image`
Extrai e inspeciona fatias e coordenadas de textura de um atlas.
- **Parâmetros:** `tileset_path`, `source_id`, `atlas_coords`.

---

## 🏃 9. Animações e Máquinas de Estados

### `create_animation`
Cria novas animações no `AnimationPlayer` com faixas de propriedades, duração configurável e modos de loop.
- **Parâmetros:** `player_node_path`, `animation_name`, `library_name`, `length`, `loop_mode`, `tracks`.

### `setup_spritesheet_animation`
Fatia um spritesheet (`Sprite2D`) e constrói animações completas com cálculo automático de FPS e faixa `RESET`.
- **Parâmetros:** `player_node_path`, `sprite_node_path`, `animation_name`, `start_frame`, `frame_count`, `fps`, `loop_mode`.

### `add_animation_event_track`
Adiciona faixas de chamadas de método ou faixas de áudio em instantes específicos da animação (ex: disparar evento de dano no frame 3).
- **Parâmetros:** `player_node_path`, `animation_name`, `timestamp`, `event_type`, `target_node_path`, `method_name_or_property`, `method_args_or_value`.

### `inspect_animation_player`
Inspeciona bibliotecas, faixas, durações e propriedades de um `AnimationPlayer`.
- **Parâmetros:** `player_node_path`.

### `create_state_machine`
Configura um `AnimationTree` com raiz do tipo `AnimationNodeStateMachine`.
- **Parâmetros:** `tree_node_path`, `anim_player_path`, `states`, `transitions`, `start_state`.

### `create_blend_space_2d`
Cria e calibra nós de BlendSpace2D (para movimentação direcional de 4 ou 8 direções).
- **Parâmetros:** `tree_node_path`, `state_name`, `blend_points`, `blend_mode`, `min_space`, `max_space`.

### `connect_state_machine_transition`
Cria e configura conexões e transições entre estados de uma máquina de estados de animação.
- **Parâmetros:** `tree_node_path`, `from_state`, `to_state`, `switch_mode`, `xfade_time`.

### `inspect_animation_tree`
Retorna a topologia completa de nós, estados e transições de um `AnimationTree`.
- **Parâmetros:** `tree_node_path`.

### `setup_character_animation_suite`
Monta todo o ecossistema de animação de um personagem em uma única etapa: cria `AnimationPlayer`, `AnimationTree`, State Machine (`Idle`, `Walk`, `Run`, `Jump`, `Attack`) e conecta ao `Sprite2D`.
- **Parâmetros:** `parent_path`, `sprite_node_path`.

---

## 🖥️ 10. UI Studio e Temas

### `generate_ui_theme`
Gera recursos de tema (`.tres`) completos com tipografia, botões, painéis, caixas de diálogo e StyleBoxes customizados.
- **Parâmetros:** `preset_or_name` (`glassmorphism`, `cyberpunk`, `retro_rpg`, `minimal_dark`, `scifi`), `save_path`, `colors`, `metrics`, `set_as_project_theme`.

### `create_responsive_ui_component`
Instancia componentes de UI responsivos pré-construídos com âncoras automáticas.
- **Parâmetros:** `component_type` (`hud`, `pause_menu`, `inventory_grid`, `dialogue_box`, `main_menu`), `save_path`, `theme_path`, `parent_node_path`.

### `apply_theme_to_scene`
Aplica recursivamente um recurso de tema à raiz da cena ou a uma ramificação específica de UI.
- **Parâmetros:** `theme_path`, `node_path`.

### `inspect_theme`
Examina propriedades, cores e fontes definidas em um arquivo `.tres` de tema.
- **Parâmetros:** `theme_path`.

---

## ⚡ 11. OmniTools, Reflexão e Debugger

### `omni_eval`
Avalia e executa trechos dinâmicos de GDScript e expressões matemáticas em tempo real dentro do contexto do editor.
- **Parâmetros:** `code`, `context_node_path` (opcional).

### `omni_manage`
Executa operações de introspecção avançada, consultas no `ClassDB` e manipulação de metadados em memória.
- **Parâmetros:** `action`, `query`, `target`.

### `get_runtime_errors`
Captura mensagens de erro, warnings e stack traces emitidos pelo depurador durante a execução do jogo no Godot.
- **Parâmetros:** `clear_after_read` (opcional).

### `get_runtime_status`
Informa o estado da sessão de depuração do jogo (em execução, pausado, parado).

---

## 🧪 12. Testes e Auditoria

### `run_tests`
Executa rotinas de testes automatizados unitários ou de integração no projeto.
- **Parâmetros:** `test_script_path` (opcional).

### `audit_scene`
Realiza auditoria arquitetural na cena ativa, verificando nós órfãos, scripts ausentes e problemas de hierarquia.

### `audit_script`
Executa análise estática em scripts GDScript procurando más práticas, erros de escopo e problemas de tipagem.
- **Parâmetros:** `path`.
