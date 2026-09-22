# Plano de Implementação: Hardening, Schemas de Tools e Compatibilidade Godot 4.3+

**Arquivo:** `docs/PLAN-core-hardening.md`  
**Autor:** `project-planner` / `game-developer`  
**Status:** Pronto para Revisão  

---

## 🎯 Objetivo Geral
Corrigir vulnerabilidades arquiteturais e pontos cegos críticos do plugin `Gamedev AI`, alinhando os esquemas JSON de Function Calling, garantindo compatibilidade dinâmica entre `TileMap` (Godot 4.0–4.2) e `TileMapLayer` (Godot 4.3+), implementando resiliência a múltiplos formatos de retorno no orquestrador multi-agente e assegurando transações atômicas com persistência de cena no `UndoRedo`.

---

## 📋 Análise de Impacto & Componentes Afetados

| Componente | Arquivo Alvo | Natureza da Mudança |
| :--- | :--- | :--- |
| **Tool Definitions (Function Calling)** | `addons/gamedev_ai/tool_executor.gd` | Adição de schemas JSON para Shaders, SFX e TileMaps |
| **TileMap Unification** | `addons/gamedev_ai/tools/tilemap_tools.gd` | Suporte dinâmico à assinatura de 4 vs 5 argumentos |
| **Orchestrator Handoff Tolerance** | `addons/gamedev_ai/orchestration/agent_orchestrator.gd` | Suporte a regex para markdown codeblocks, JSON puro e HTML comments |
| **Scene Atomic Transactions & Persistence** | `addons/gamedev_ai/tools/node_tools.gd` e `tool_executor.gd` | Salvamento coordenado de cenas modificadas via EditorInterface / ResourceSaver |

---

## 🛠️ Tarefas Detalhadas por Módulo

### 1. Alinhamento de Schemas no `tool_executor.gd`
* Adicionar definições JSON completas em `get_tool_definitions()` para:
  1. `generate_shader`: `preset`, `path`, `custom_code`, `uniforms`.
  2. `apply_shader_to_node`: `node_path`, `shader_path`, `preset`, `uniforms`.
  3. `get_shader_presets_list`: Sem parâmetros obrigatórios.
  4. `generate_sfx`: `preset`, `path`, `params`.
  5. `play_sfx_preview`: `preset`, `params`.
  6. `configure_tileset_atlas`: `texture_path`, `tile_size`, `save_path`, `terrain_set_config`, `physics_config`.
  7. `build_tilemap_layout`: `layer_node_path`, `layout_matrix`, `source_id`.
  8. `paint_terrain_cells`: `layer_node_path`, `terrain_set`, `terrain_id`, `cell_coordinates`, `ignore_empty_terrains`.
  9. `read_tilemap_layout`: `layer_node_path`, `bounding_box`.
  10. `clear_tilemap_region`: `layer_node_path`, `rect`, `cell_coordinates`.
* Validar que as chaves de `_TOOL_REQUIRED_ARGS` e `get_tool_definitions()` estejam em 100% de paridade.

### 2. Unificação Dinâmica de `TileMap` e `TileMapLayer` no `tilemap_tools.gd`
* Criar método helper `_set_tile_cell(target_node: Node, pos: Vector2i, source_id: int, atlas: Vector2i, alt: int, layer: int = 0)`:
  * Se o nó for `TileMapLayer` (Godot 4.3+): executa `target_node.set_cell(pos, source_id, atlas, alt)`.
  * Se o nó for `TileMap` clássico (Godot 4.0–4.2): executa `target_node.set_cell(layer, pos, source_id, atlas, alt)`.
* Atualizar `_paint_terrain_cells`, `_read_tilemap_layout` e `_clear_tilemap_region` para identificar se o nó alvo é camada individual ou mapa com múltiplas camadas.

### 3. Tolerância no Handoff do Orquestrador no `agent_orchestrator.gd`
* Refatorar `_extract_artifact_report(text: String) -> Dictionary`:
  * **Estratégia 1 (HTML Comment):** `<!-- ARTIFACT_REPORT { ... } -->`
  * **Estratégia 2 (Markdown JSON):** ````json ... ```` contendo chaves esperadas (`resources`, `scenes`, `scripts`).
  * **Estratégia 3 (JSON Raw):** Busca pelo primeiro `{` e último `}` contendo a estrutura de relatório.
  * **Estratégia 4 (Fallback Heurístico):** Se o modelo executou tools via tool calls (ex: `create_script`, `create_scene`), utilizar os registros já capturados no `Blackboard` sem rejeitar o handoff.

### 4. Transações Atômicas de Cena e Persistência de Undo/Redo
* Em `node_tools.gd`, após executar adições/remoções de nós ou propriedades:
  * Manter `EditorInterface.mark_scene_as_unsaved()` ativo.
  * Opcionalmente acionar `EditorInterface.save_scene()` quando uma macro batch action (`commit_batch_transaction`) for concluída pelo orquestrador.
  * Garantir que todas as ações de nós usem o `UndoRedo` do `EditorUndoRedoManager` vinculado à cena atualmente editada (`EditorInterface.get_edited_scene_root()`).

---

## 🧪 Plano de Verificação e Testes

1. **Validação de Schemas:**
   * Executar teste estático comparando `_TOOL_REQUIRED_ARGS.keys()` contra os nomes definidos em `get_tool_definitions()`.
2. **Teste de Compatibilidade de TileMap:**
   * Testar criação de tiles em cena contendo nó `TileMapLayer` e cena contendo nó `TileMap`.
3. **Teste de Handoff Multi-formato do Orquestrador:**
   * Simular saídas em JSON puro, comentário HTML e markdown block verificando se o `Blackboard` é populado corretamente em todos os casos.
4. **Teste de Persistência:**
   * Criar nós via comando de chat e verificar se o estado da cena permanece salvo e acessível no histórico de Undo (Ctrl+Z).
