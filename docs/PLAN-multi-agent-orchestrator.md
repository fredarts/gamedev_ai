# Project Plan: Sistema Multi-Agente In-Editor (Orquestrador) [PREMIUM STANDARD]

## 📋 Resumo Executivo
- **Objetivo**: Implementar um sistema de orquestração multi-agente in-editor autônomo, modular e blindado para o plugin **Gamedev AI** no Godot 4.x. O sistema divide a execução de sistemas e mecânicas de grande porte em uma pipeline sequencial com 4 personas hiper-especializadas, isolamento estrito de contexto (Sub-Session Context), quadro compartilhado (Blackboard), validação de contratos em tempo de execução (Handoff Gatekeeper) e loop de auto-recuperação TDD:
  1. **Game Architect**: Modela estruturas de dados, schemas, recursos customizados (`Resource`, `RefCounted`, `@export`) e contratos de sinais/APIs.
  2. **Scene & UI Builder**: Constrói grafos de nós `.tscn`, organiza hierarquias visuais, containers e define âncoras/layouts de interface.
  3. **GDScript Coder**: Implementa lógica de negócio fortemente tipada em GDScript 2.0, conecta sinais, trata inputs e valida sintaxe via LSP.
  4. **QA Tester**: Cria suítes de testes unitários/integração com GUT, executa via `TestRunner` headless e homologa a feature com critérios de aceitação.

- **Arquivos Alvo**:
  - `addons/gamedev_ai/orchestration/agent_orchestrator.gd` [NOVO] - Motor central da máquina de estados do pipeline, persistência de sessão e orquestração.
  - `addons/gamedev_ai/orchestration/blackboard.gd` [NOVO] - Quadro estruturado em memória e persistido em disco para handoff de artefatos entre etapas.
  - `addons/gamedev_ai/orchestration/persona_config.gd` [NOVO] - Definição das 4 personas, restrição estrita de ferramentas e prompts especializados.
  - `addons/gamedev_ai/orchestration/personas/architect_persona.gd` [NOVO] - Persona especializada em arquitetura e modelagem de dados.
  - `addons/gamedev_ai/orchestration/personas/scene_builder_persona.gd` [NOVO] - Persona especializada em grafos de cena e UI.
  - `addons/gamedev_ai/orchestration/personas/coder_persona.gd` [NOVO] - Persona especializada em GDScript 2.0 e sinais.
  - `addons/gamedev_ai/orchestration/personas/qa_persona.gd` [NOVO] - Persona especializada em testes GUT e asserções TDD.
  - `addons/gamedev_ai/dock/dock_chat.gd` [MODIFICADO] - Barra visual de progresso de pipeline, badges das personas no chat e comando `/orchestrate`.
  - `addons/gamedev_ai/system_prompt.gd` [MODIFICADO] - Diretrizes do orquestrador e catálogo de papéis.

---

## 🛡️ Matriz de Pontos Cegos & Mitigações Arquiteturais

| # | Ponto Cego Detectado | Risco no Godot 4 / LLM | Solução Premium Standard |
|---|---|---|---|
| **1** | **Context Bloat / Estouro de Tokens** | Rodar 4 agentes no mesmo histórico acumula dezenas de tool calls intermediárias, estourando a janela de contexto de modelos locais e encarecendo a API. | **Contexto Isolado por Sub-Sessão**: Cada agente recebe apenas seu prompt especialista + solicitação do usuário + JSON limpo do **Blackboard**, sem o histórico bruto das etapas anteriores. |
| **2** | **Falha Silenciosa no Handoff** | O Architect declara ter criado um arquivo de dados, mas a tool falha; o Scene Builder tenta instanciar e quebra a cadeia inteira. | **Handoff Gatekeeper**: Verificação física de arquivos (`FileAccess.file_exists`) e compilação antes de autorizar a transição para a próxima etapa. |
| **3** | **Interrupções e Quedas de Rede** | Fechar o editor ou sofrer timeout de rede durante a etapa 2 perderia o progresso das etapas anteriores. | **Persistência de Estado do Pipeline (`.gamedev_ai/orchestration_state.json`)**: Suporte a `pause()`, `resume()`, `retry_current_stage()` e retomada após restart do Godot. |
| **4** | **Corrupção de Undo/Redo** | Ferramentas de diferentes etapas misturadas geravam histórico desordenado de Ctrl+Z. | **Transações Atômicas Nomeadas por Fase**: Cada etapa abre uma transação atômica (`[Orchestrator] Step 2: Scene Builder`), permitindo rollback limpo de fases inteiras. |
| **5** | **Loop Infinito em Auto-Healing TDD** | Coder introduz novos erros ao tentar corrigir falhas do QA, gerando loop infinito de chamadas. | **Limite Rígido de Auto-Healing (Máx 2 iterações)** com detecção de regressão e solicitação de intervenção do usuário se a contagem de falhas aumentar. |
| **6** | **Ambiguidade Visual no Chat** | O usuário não saberia qual agente está respondendo ou qual etapa está travada. | **Header Visual no Dock + Badges de Persona**: Barra horizontal com status em tempo real (`PENDING`, `RUNNING`, `DONE`, `ERROR`) e cores temáticas por papel. |

---

## 🏗️ Arquitetura Detalhada & Contratos do Blackboard

```
                           ┌──────────────────────────────────────────────┐
                           │               User Prompt / UI               │
                           │   "/orchestrate Sistema de Inventário"       │
                           └──────────────────────┬───────────────────────┘
                                                  │
                                                  ▼
                           ┌──────────────────────────────────────────────┐
                           │              AgentOrchestrator               │
                           │  - Sub-Session Manager (Context Isolation)   │
                           │  - Handoff Gatekeeper (Asset Verifier)       │
                           │  - Phase-Named UndoRedo Transactions         │
                           └──────┬───────────────┬────────────────┬──────┘
                                  │               │                │
            ┌─────────────────────┴───┐     ┌─────┴──────────┐     └───┬─────────────────────────┐
            ▼                         ▼     ▼                ▼         ▼                         ▼
┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
│     GAME ARCHITECT      │ │   SCENE & UI BUILDER    │ │     GDSCRIPT CODER      │ │        QA TESTER        │
│ 📐 Prompt: Data Model   │ │ 🖼️ Prompt: UI & Nodes   │ │ 💻 Prompt: Code Logic   │ │ 🧪 Prompt: GUT Testing  │
│ 🛠️ Tools: Data/Resource │ │ 🛠️ Tools: add_node/inst.│ │ 🛠️ Tools: patch/signals │ │ 🛠️ Tools: run_tests/LSP │
└───────────┬─────────────┘ └───────────┬─────────────┘ └───────────┬─────────────┘ └───────────┬─────────────┘
            │                           │                           │                           │
            ▼                           ▼                           ▼                           ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   SHARED BLACKBOARD (JSON Schema)                                           │
│  - "resources": ["res://data/item_data.gd", "res://data/inventory_data.gd"]                                 │
│  - "scenes": ["res://ui/inventory_slot.tscn", "res://ui/inventory_ui.tscn"]                                │
│  - "scripts": ["res://ui/inventory_ui.gd"]                                                                  │
│  - "signals": [{"source": "GridContainer/Slot1", "signal": "slot_clicked", "target": "inventory_ui.gd"}]   │
│  - "tests": ["res://test/unit/test_inventory.gd"] (Status: ✅ PASSED 4/4)                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Task Breakdown Detalhado

### 🔷 Task 1: Motor do Orquestrador (`AgentOrchestrator`) & Isolamento de Sub-Sessões
- **Agente**: `project-planner` / `game-developer`
- **Skills**: `clean-code`, `parallel-agents`
- **Prioridade**: P0
- **Implementação**:
  - Criar `addons/gamedev_ai/orchestration/agent_orchestrator.gd`.
  - Máquina de estados: `IDLE` → `STAGE_ARCHITECT` → `STAGE_SCENE_BUILDER` → `STAGE_CODER` → `STAGE_QA` → `COMPLETED` / `FAILED`.
  - Criar `addons/gamedev_ai/orchestration/blackboard.gd` com métodos:
    - `register_resource(path, class_name, exports)`
    - `register_scene(path, root_type, node_paths)`
    - `register_script(path, functions, signals)`
    - `register_test_results(summary)`
    - `to_condensed_prompt() -> String` (Gera o resumo compacto para o próximo sub-agente).
  - Isolamento de Sub-Sessão: Para cada etapa, instanciar ou resetar o buffer de mensagens, injetando apenas o `condensed_prompt` do Blackboard.
- **INPUT**: Solicitação de tarefa complexa do usuário.
- **OUTPUT**: Orquestração fluida com consumo otimizado de tokens.
- **VERIFY**: Testar transição de dados entre as 4 fases e verificar que o buffer de tokens permanece < 4k por fase.

---

### 🔷 Task 2: Configuração e Especialização das 4 Personas & Políticas de Ferramentas
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `game-development`
- **Prioridade**: P0
- **Implementação**:
  - `persona_config.gd` e 4 arquivos em `addons/gamedev_ai/orchestration/personas/`:
    1. **`ArchitectPersona`**:
       - Role: Modelagem pura de dados (`Resource`, `RefCounted`, schemas, constantes).
       - Ferramentas Permitidas: `create_script`, `create_resource`, `list_dir`, `read_file`, `save_memory`.
       - Ban: Proibido instanciar nós ou criar cenas `.tscn`.
    2. **`SceneBuilderPersona`**:
       - Role: Construção de grafos de nós, árvores de UI, containers, layouts responsivos e âncoras.
       - Ferramentas Permitidas: `create_scene`, `add_node`, `instance_scene`, `set_property`, `set_theme_override`, `analyze_node_children`.
       - Ban: Proibido escrever lógica de gameplay ou conectar sinais em código.
    3. **`CoderPersona`**:
       - Role: Implementação de lógica de jogo, tratamento de signals, estado, animações e validação LSP.
       - Ferramentas Permitidas: `read_file`, `patch_script`, `edit_script`, `connect_signal`, `get_lsp_diagnostics`.
       - Ban: Proibido reestruturar árvores de cenas (deve usar os nós criados pelo Scene Builder).
    4. **`QAPersona`**:
       - Role: Criação de suítes de testes GUT, verificação de asserções, edge cases e validação headless.
       - Ferramentas Permitidas: `create_script`, `read_file`, `run_tests`, `get_lsp_diagnostics`.
- **INPUT**: Persona designada pelo Orquestrador.
- **OUTPUT**: Ações e saídas 100% delimitadas ao domínio de responsabilidade.
- **VERIFY**: Testar tentativa de criação de nós pelo Architect e validar bloqueio / desvio correto.

---

### 🔷 Task 3: Handoff Gatekeeper & Transações Atômicas de Fase
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `game-development`
- **Prioridade**: P0
- **Implementação**:
  - Criar `_validate_stage_handoff(current_stage: int, blackboard: Blackboard) -> Dictionary`:
    - De `ARCHITECT` para `SCENE`: Checar se todos os scripts `.gd` e `.tres` registrados existem no disco e compilam sem erros no LSP (`get_lsp_diagnostics`).
    - De `SCENE` para `CODER`: Checar se os arquivos `.tscn` existem e se os nós declarados no Blackboard estão acessíveis.
    - De `CODER` para `QA`: Checar se os métodos implementados compilam com 0 erros de sintaxe.
  - Vínculo ao `EditorUndoRedoManager`: Cada etapa inicia chamando `tool_executor.begin_batch_transaction("[Orchestrator] " + stage_name)` e comita no final da etapa, permitindo desfazer uma fase inteira com 1 único Ctrl+Z.
- **INPUT**: Conclusão da etapa do sub-agente.
- **OUTPUT**: Transição segura ou interrupção imediata com relatório de correção.
- **VERIFY**: Simular arquivo ausente na saída do Architect e verificar acionamento do Gatekeeper impedindo a etapa seguinte.

---

### 🔷 Task 4: Visual Pipeline Widget & Badges no Dock
- **Agente**: `frontend-specialist` / `game-developer`
- **Skills**: `clean-code`, `frontend-design`
- **Prioridade**: P1
- **Implementação**:
  - Atualizar `dock_chat.gd` e `dock.tscn`:
    - Inserir container de pipeline acima da caixa de mensagens com 4 chips interativos:
      `[ 📐 Architect ] ➔ [ 🖼️ Scene ] ➔ [ 💻 Coder ] ➔ [ 🧪 QA ]`.
    - Estados visuais dos chips:
      - `PENDING`: Cinza / Dimmed.
      - `RUNNING`: Ciano pulsante com spinner ou indicador de atividade.
      - `DONE`: Verde com ícone de checkmark.
      - `ERROR`: Vermelho com tooltip de falha.
    - Botões de controle de orquestração: `Pause`, `Resume`, `Abort / Rollback`.
    - No chat, cada mensagem do orquestrador exibe a badge com cor e ícone da persona ativa.
  - Mapear comando `/orchestrate <descrição da feature>`.
- **INPUT**: Sinais emitidos pelo `AgentOrchestrator` (`stage_changed(stage, name)`, `stage_completed(stage, summary)`, `pipeline_completed()`).
- **OUTPUT**: Experiência visual rica, clara e interativa no Dock.
- **VERIFY**: Executar fluxo orquestrado e verificar transição suave dos 4 chips de status na UI.

---

### 🔷 Task 5: Loop de Auto-Recuperação TDD (QA ↔ Coder) com Proteção contra Regressão
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `tdd-workflow`
- **Prioridade**: P1
- **Implementação**:
  - Se `QAPersona` executar `run_tests` e registrar falhas de asserção:
    - Se `auto_heal_attempts < 2`:
      - Salvar snapshot dos scripts atuais no Blackboard.
      - Retornar o pipeline para o estado `STAGE_CODER` injetando o prompt de correção TDD com os logs e linhas de falha do GUT.
      - O `Coder` gera os patches.
      - O pipeline avança novamente para `STAGE_QA` para reteste.
    - Se a nova contagem de falhas for MAIOR que a anterior (Regressão):
      - Reverter para o snapshot anterior e pausar o pipeline solicitando orientação ao usuário.
- **INPUT**: Falha de asserção em testes GUT.
- **OUTPUT**: Auto-correção autônoma sem risco de corrupção cíclica.
- **VERIFY**: Injetar teste com falha proposital de cálculo, verificar correção automática pelo Coder e aprovação pelo QA no reteste.

---

## 🧪 Phase X: Plano de Verificação & Validação (Definition of Done)

- [ ] **1. Teste de Orquestração Completa (E2E)**:
  - Comando: `/orchestrate Criar sistema de Moedas Coletáveis com Item e HUD`.
  - Validar sequência:
    - 📐 **Architect**: Cria `res://scripts/coin_data.gd` (`Resource`).
    - 🖼️ **Scene Builder**: Cria `res://scenes/coin.tscn` (com `Area2D`, `CollisionShape2D`, `Sprite2D`) e `res://ui/coin_hud.tscn`.
    - 💻 **Coder**: Implementa `coin.gd` e `coin_hud.gd`, conecta sinais de coleta.
    - 🧪 **QA**: Cria `res://test/unit/test_coin.gd`, executa `run_tests` e reporta 100% Passed.
- [ ] **2. Teste de Isolamento de Contexto**:
  - Medir tamanho do prompt enviado ao Coder e QA e garantir que não contém o lixo bruto das tool calls do Architect.
- [ ] **3. Teste do Handoff Gatekeeper**:
  - Forçar falha de criação de arquivo e garantir que o pipeline bloqueia o avanço e reporta o erro.
- [ ] **4. Teste de Auto-Healing TDD**:
  - Simular teste com falha e validar ciclo Coder -> QA com limite de 2 tentativas.
- [ ] **5. Teste de Responsividade e UI no Dock**:
  - Validar renderização dos 4 chips de pipeline e badges coloridas no chat.
