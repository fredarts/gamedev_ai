# Project Plan: Fase 2 - Robustez e Automação TDD (Q2) [PREMIUM STANDARD]

## 📋 Resumo Executivo
- **Objetivo**: Elevar a confiabilidade, autonomia e segurança operacional do plugin **Gamedev AI** implementando três pilares essenciais de robustez sem pontos cegos de concorrência, vazamento de memória ou travamento de UI:
  1. **Transações Atômicas de Cena (`EditorUndoRedoManager`)**: Agrupamento seguro de ações encadeadas de nós, propriedades e conexões de sinais sob o contexto correto da cena atual, com retenção de referências (`add_do_reference`/`add_undo_reference`), rollback de dois estágios (Two-Phase Execution) e suporte nativo a Ctrl+Z/Ctrl+Y.
  2. **Executor de Testes GUT Headless Assíncrono (TDD Loop)**: Execução não-bloqueante via `OS.execute_with_pipe` / worker polling, watchdog timer anti-zumbi, parser estruturado de asserções/erros e feedback loop para a IA resolver bugs automaticamente (Red → Green → Refactor).
  3. **Diagnósticos em Tempo Real via Godot Language Server (LSP)**: Cliente TCP JSON-RPC 2.0 resiliente com acumulador de framing (`Content-Length`), detecção dinâmica de portas nas `EditorSettings`, handshake completo (`initialize`/`didOpen`) e fallback nativo de compilação com `GDScript.reload()`.

- **Arquivos Alvo**:
  - `addons/gamedev_ai/lsp_client.gd` [NOVO] - Cliente TCP JSON-RPC para o Godot Language Server com buffer acumulador e handshake.
  - `addons/gamedev_ai/test_runner.gd` [NOVO] - Gerenciador assíncrono de testes GUT em modo headless com pipes e watchdog timer.
  - `addons/gamedev_ai/tool_executor.gd` [MODIFICADO] - Orquestração de transações atômicas com rollback em 2 fases, injeção de `LSPClient` e `TestRunner`.
  - `addons/gamedev_ai/tools/base_tool_handler.gd` [MODIFICADO] - Helpers para gestão de referências de nós, captura de estado prévio e contexto de cena.
  - `addons/gamedev_ai/tools/node_tools.gd` [MODIFICADO] - Refatoração integral das operações de nós com suporte estrito a Undo/Redo e retenção de memória.
  - `addons/gamedev_ai/tools/project_tools.gd` [MODIFICADO] - Integração do `run_tests` assíncrono e nova ferramenta `get_lsp_diagnostics`.
  - `addons/gamedev_ai/system_prompt.gd` [MODIFICADO] - Registro de ferramentas, instruções de TDD e boas práticas de inspeção pré-voo.

---

## 🏗️ Arquitetura Detalhada & Contratos de Interface

```
                          ┌──────────────────────────────────────────────┐
                          │                 Gamedev AI                   │
                          │          (Dock / Providers / Chat)           │
                          └──────────────────────┬───────────────────────┘
                                                 │
                                                 ▼
                          ┌──────────────────────────────────────────────┐
                          │             ToolExecutor (Fachada)           │
                          │  - begin_transaction(action_name, scene_root)│
                          │  - commit_transaction()                      │
                          │  - abort_and_rollback()                      │
                          └──────┬───────────────┬────────────────┬──────┘
                                 │               │                │
            ┌────────────────────┴──┐     ┌──────┴─────────┐   ┌──┴──────────────────────┐
            ▼                       ▼     ▼                ▼   ▼                         ▼
  ┌──────────────────┐    ┌─────────────┐ ┌──────────────┐ ┌─────────────────────────────────┐
  │   NodeTools      │    │ ProjectTools│ │  TestRunner  │ │ LSPClient (StreamPeerTCP)       │
  │- add_do_method   │    │- run_tests  │ │- Pipes / Poll│ │- Content-Length Accumulator     │
  │- add_undo_method │    │- get_lsp_   │ │- Watchdog 45s│ │- Handshake & didOpen/didChange  │
  │- add_reference   │    │  diagnostics│ │- GUT Parser  │ │- Fallback: GDScript.reload()    │
  └─────────┬────────┘    └──────┬──────┘ └──────┬───────┘ └─────────────┬───────────────────┘
            │                    │               │                       │
            ▼                    ▼               ▼                       ▼
  ┌──────────────────┐    ┌─────────────┐ ┌──────────────┐ ┌─────────────────────────────────┐
  │EditorUndoRedo-   │    │ Retorno     │ │ Godot Engine │ │ Godot Language Server (TCP)     │
  │Manager (Godot 4) │    │ Estruturado │ │ --headless   │ │ porta dinâmica (ex: 6005)       │
  │Context: SceneRoot│    │ para a IA   │ │ -s gut_cmdln │ │ Diagnósticos de Sintaxe e Tipos │
  └──────────────────┘    └─────────────┘ └──────────────┘ └─────────────────────────────────┘
```

---

## 🎯 Task Breakdown Detalhado

### 🔷 Pilar 1: Transações Atômicas de Cena (`EditorUndoRedoManager`)

#### Task 1.1: Mecanismo de Transação em Duas Fases (Two-Phase Transaction Manager)
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `game-development`
- **Prioridade**: P0
- **Pontos Cegos Tratados**:
  - Contexto isolado por aba de cena (`EditorInterface.get_edited_scene_root()`). Se a cena atual não tiver root, utiliza contexto global seguro.
  - Rollback em tempo real caso uma das chamadas do lote gere erro (ex: tipo inválido ou nó inexistente), sem poluir a pilha de Undo do editor.
- **Implementação**:
  - Em `tool_executor.gd`:
    - `begin_batch_transaction(name: String, custom_context: Object = null)`
    - `commit_batch_transaction()`
    - `abort_batch_transaction()`
  - Em `base_tool_handler.gd`:
    - Métodos auxiliares `_add_do_property(node, prop, value)`, `_add_undo_property(node, prop, old_value)`.
    - Captura imutável de propriedades anteriores com `duplicate(true)` para `Array`/`Dictionary`/`Resource`.
- **INPUT**: Array de chamadas de ferramentas a serem executadas em lote em uma única resposta da IA.
- **OUTPUT**: Histórico unificado no Godot 4 (1 único Ctrl+Z reverte o conjunto inteiro).
- **VERIFY**: Teste automatizado executando `add_node` + `set_property` + `connect_signal`; simular erro no 3º passo e garantir retorno intacto ao estado inicial.

#### Task 1.2: Refatoração de Memória e Referências em `node_tools.gd`
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `game-development`
- **Prioridade**: P0
- **Pontos Cegos Tratados**:
  - Memory leaks causados por `remove_child()` no Undo sem `add_undo_reference(node)`.
  - Falha ao refazer (Redo) de nós deletados por falta de `add_do_reference(node)`.
  - Preservação da ordem de irmãos na árvore (`get_index()` / `move_child()`).
  - Preservação correta de `node.owner` para que nós fiquem visíveis no inspetor de cena.
- **Implementação**:
  - `_add_node`:
    - Do: Adicionar filho, definir owner como raiz da cena, anexar script.
    - Undo: Remover filho da árvore.
    - Referência: `add_do_reference(node)` para gerenciar o ciclo de vida do nó instanciado.
  - `_remove_node`:
    - Do: Desanexar da árvore.
    - Undo: Readicionar como filho no índice original e restaurar owner.
    - Referência: `add_undo_reference(node)` para evitar destruição prematura enquanto o nó estiver no histórico.
  - `_set_property` & `_set_theme_override`:
    - Captura segura do valor prévio via `node.get(property)`.
  - `_connect_signal` & `_disconnect_signal`:
    - Métodos reversíveis com verificação de sinais já existentes (`is_connected`).
- **INPUT**: Operações de árvore de cena.
- **OUTPUT**: Nós íntegros, sem memory leaks nem avisos no debugger do Godot.
- **VERIFY**: Criar árvore com 5 nós, deletar um intermediário, dar Ctrl+Z e Ctrl+Y repetidamente; inspecionar `Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)` para garantir 0 nós órfãos.

---

### 🔷 Pilar 2: Executor de Testes GUT Headless & Feedback Loop TDD

#### Task 2.1: Módulo `TestRunner` Assíncrono Não-Bloqueante (`test_runner.gd`)
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `testing-patterns`
- **Prioridade**: P1
- **Pontos Cegos Tratados**:
  - Bloqueio da thread principal do editor (eliminar `OS.execute` síncrono).
  - Processos do Godot zumbis travados (adicionar `-gexit` e watchdog timer de 45 segundos).
  - Overhead gráfico em testes (adicionar `--rendering-driver dummy` ou `opengl3`).
- **Implementação**:
  - Utilizar `OS.execute_with_pipe(exe_path, args)` no Godot 4.2+ para ler stdout em streaming não-bloqueante no `_process`.
  - Fallback para subprocesso em segundo plano monitorado com arquivo de saída (`--log-file user://gut_run.log`).
  - Resolução inteligente de caminhos de teste:
    - Se arquivo específico for passado (`res://test/unit/test_player.gd`), usa `-gtest=...`.
    - Se pasta for passada (`res://test/`), usa `-gdir=...`.
    - Se vazio, busca `.gutconfig.json` ou varre pastas `res://test/` e `res://tests/`.
- **INPUT**: Caminho opcional ou suíte completa de testes.
- **OUTPUT**: Sinais `test_output(line: String)` e `tests_finished(result: Dictionary)`.
- **VERIFY**: Rodar suite de 10 testes assíncronos e verificar que a UI do editor continua 60 FPS durante toda a execução.

#### Task 2.2: Parser Estruturado GUT & Prompt TDD para IA
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `tdd-workflow`
- **Prioridade**: P1
- **Pontos Cegos Tratados**:
  - Saídas com ANSI color codes poluindo o contexto da IA.
  - Falta de linha e motivo exato do erro de asserção.
- **Implementação**:
  - Regex parser para extrair:
    - `passed_count`, `failed_count`, `pending_count`, `assert_count`, `time_taken`.
    - Detalhes de cada falha: `{ script: String, test_name: String, line: int, expected: Variant, got: Variant, message: String }`.
  - Atualização da tool `run_tests` em `project_tools.gd` para retornar sumário estruturado.
  - Integração no `system_prompt.gd` com workflow TDD:
    - Quando o usuário pede uma funcionalidade com TDD: (1) Criar teste GUT que falha, (2) Rodar `run_tests`, (3) Implementar código de produção, (4) Rodar `run_tests` até passar (Green), (5) Refatorar se necessário.
- **INPUT**: Log bruto emitido pelo GUT no terminal.
- **OUTPUT**: Dicionário limpo e formatado em Markdown/BBCode para o usuário e contexto semântico para a IA.
- **VERIFY**: Testar parser com teste falhando intencionalmente e confirmar que a IA recebe a falha exata sem poluição de caracteres de terminal.

---

### 🔷 Pilar 3: Diagnósticos via Godot Language Server (LSP)

#### Task 3.1: Cliente TCP JSON-RPC do Godot LSP com Buffer Acumulador (`lsp_client.gd`)
- **Agente**: `backend-specialist` / `game-developer`
- **Skills**: `clean-code`, `api-patterns`
- **Prioridade**: P1
- **Pontos Cegos Tratados**:
  - Mensagens TCP fragmentadas ou pacotes múltiplos combinados em um único buffer.
  - Porta dinâmica configurada pelo usuário (`EditorSettings: network/language_server/remote_port`).
  - Falha de conexão caso o servidor de LSP esteja desativado no editor.
- **Implementação**:
  - `StreamPeerTCP` com polling no `_process` do editor.
  - Buffer de recepção (`_rx_buffer: PackedByteArray`) com parser de header `Content-Length: \d+\r\n\r\n`.
  - Máquina de estados de conexão: `DISCONNECTED` → `CONNECTING` → `HANDSHAKE_INIT` → `INITIALIZED` → `READY`.
  - Tratamento de mensagens JSON-RPC:
    - Envio: `initialize`, `initialized`, `textDocument/didOpen`, `textDocument/didChange`, `textDocument/didClose`.
    - Recepção: Escuta assíncrona de `textDocument/publishDiagnostics` mapeando diagnósticos por URI de arquivo.
- **INPUT**: Conexão TCP na porta local do editor Godot.
- **OUTPUT**: Dicionário de diagnósticos por arquivo `{ "res://scripts/player.gd": [ { "line": 12, "col": 5, "severity": 1, "message": "Identifier not declared" } ] }`.
- **VERIFY**: Conectar cliente ao editor, disparar `didOpen` em script com erro e validar recebimento do diagnóstico em < 100ms.

#### Task 3.2: Ferramenta `get_lsp_diagnostics` & Fallback de Compilação
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `lint-and-validate`
- **Prioridade**: P1
- **Pontos Cegos Tratados**:
  - Se o LSP falhar ou estiver desabilitado, a IA não pode ficar cega.
  - Scripts não salvos em disco precisam ser diagnosticados antes da confirmação do usuário.
- **Implementação**:
  - Criar ferramenta `get_lsp_diagnostics(file_path: String, source_code: String = "")` em `project_tools.gd`.
  - Fallback automático: Se o `LSPClient` estiver desconectado, o método carrega o código no motor do GDScript:
    ```gdscript
    var script = GDScript.new()
    script.source_code = source_code_or_file
    var err = script.reload()
    ```
  - Integrar checagem pré-voo após `edit_script` e `patch_script`: Se a edição gerar erro de sintaxe, alertar a IA imediatamente para auto-correção antes de submeter ao usuário.
- **INPUT**: Caminho do arquivo ou código fonte modificado.
- **OUTPUT**: Diagnóstico limpo de compilação com severidade (`Error`, `Warning`, `Information`, `Hint`).
- **VERIFY**: Testar em script com erro de sintaxe com e sem conexão TCP de LSP e garantir relatório de erro idêntico em ambos os caminhos.

---

## 🛡️ Matriz Completa de Riscos & Estratégias de Mitigação

| Risco | Severidade | Probabilidade | Estratégia de Mitigação |
|-------|------------|---------------|-------------------------|
| **Vazamento de nós (Orphan Nodes) no Undo/Redo** | Crítica | Média | Registro estrito de `add_do_reference` e `add_undo_reference` em todas as mutações da árvore de nós. |
| **Execução parcial corrompida em Batch de Tools** | Alta | Média | Two-Phase Execution: se qualquer tool intermediária falhar, disparar `abort_batch_transaction()` desfazendo alterações imediatas. |
| **Processo Godot Headless travado em loop infinito** | Alta | Média | Flag mandatória `-gexit` + Watchdog Timer de 45s com `OS.kill(pid)` automático em caso de timeout. |
| **Travamento de UI do Editor durante testes** | Alta | Baixa | Uso exclusivo de pipes não-bloqueantes (`OS.execute_with_pipe`) ou polling em timer secundário. |
| **Fragmentação de pacotes TCP no LSP** | Média | Alta | Acumulador de bytes com validação rigorosa de `Content-Length` antes de tentar o parse do JSON-RPC. |
| **LSP desativado pelo usuário no Godot** | Média | Média | Leitura dinâmica das `EditorSettings` e fallback automático para compilação nativa com `GDScript.reload()`. |

---

## 🧪 Phase X: Plano de Verificação & Validação (Definition of Done)

- [ ] **1. Teste de Transações Atômicas de Cena**:
  - Executar comando composto de IA que cria um `CharacterBody2D`, adiciona um `CollisionShape2D`, define propriedade `shape` e conecta o sinal `ready`.
  - Pressionar **Ctrl+Z** no Godot: Verificar se toda a estrutura e conexões são revertidas em 1 único passo.
  - Pressionar **Ctrl+Y**: Verificar se a estrutura inteira é recriada perfeitamente.
  - Verificar contagem de nós órfãos: `Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT) == 0`.
- [ ] **2. Teste de Resiliência a Falhas (Rollback)**:
  - Disparar lote contendo 2 comandos válidos e 1 comando propositalmente inválido.
  - Confirmar que a transação é abortada e nenhum resíduo fica na cena ou na pilha de Undo.
- [ ] **3. Teste do Executor GUT Headless & TDD**:
  - Criar script `test_example.gd` contendo 1 teste assert verdadeiro e 1 assert falso.
  - Executar `run_tests` via plugin e validar:
    - Editor não congela durante a execução.
    - Saída estruturada reporta exatamente 1 passed e 1 failed com a linha correta.
    - Processo encerra sem deixar instâncias do Godot em segundo plano.
- [ ] **4. Teste de Diagnósticos LSP & Fallback**:
  - Abrir conexão com o Godot Language Server local na porta 6005.
  - Executar `get_lsp_diagnostics` em script com erro sintático e validar captura do erro.
  - Desligar a porta TCP e rodar novamente: validar que o fallback nativo (`GDScript.reload`) identifica o mesmo erro.
- [ ] **5. Auditoria de Código & Padrões**:
  - Rodar checklist de validação do repositório (`python .agent/scripts/checklist.py .`).
