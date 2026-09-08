# Project Plan: Modularização Blindada do Dock (dock.gd)

## 📋 Resumo Executivo
- **Objetivo**: Desmembrar o arquivo monolítico `dock.gd` (~2.948 linhas) em 4 controladores desacoplados e de responsabilidade única, mantendo o `dock.gd` como Fachada central sem quebrar a cena `dock.tscn` nem nenhuma funcionalidade.
- **Arquivos Alvo**:
  - `addons/gamedev_ai/dock/dock_diff.gd` [NOVO]
  - `addons/gamedev_ai/dock/dock_git.gd` [NOVO]
  - `addons/gamedev_ai/dock/dock_settings.gd` [NOVO]
  - `addons/gamedev_ai/dock/dock_chat.gd` [NOVO]
  - `addons/gamedev_ai/dock/dock.gd` [MODIFICADO - Fachada Limpa ~250 linhas]

---

## 🏗️ Estrutura dos Controladores & Dependências

```
addons/gamedev_ai/dock/
├── dock.tscn               # Cena inalterada (mantém todos os nós e unique names intactos)
├── dock.gd                 # Fachada orquestradora (~250 linhas)
├── dock_diff.gd            # Controller: Diff Preview, BBCode colorização, Aprovação/Skip de Patches
├── dock_git.gd             # Controller: Aba Git, Sinais Assíncronos, Commit AI, Branches
├── dock_settings.gd        # Controller: Presets, 11 Idiomas, Vector DB UI, Font Sizes
└── dock_chat.gd            # Controller: Chat, Histórico, Streaming, Slash Commands, TTS, Magic Actions
```

---

## 🎯 Task Breakdown

### Task 1: Implementação do `dock_diff.gd`
- [ ] Criar classe `DockDiff` para controle do painel `DiffPreviewPanel`.
- [ ] Mapear eventos dos botões `Apply Changes` e `Skip`.
- [ ] Integrar com `ToolExecutor.diff_preview_requested` e `EditorUndoRedoManager`.

### Task 2: Implementação do `dock_git.gd`
- [ ] Criar classe `DockGit` para a aba de Git (`TabContainer/Git`).
- [ ] Conectar os sinais assíncronos do `GitManager`.
- [ ] Mapear interações com branches, status reativo, botões com modais de confirmação e commit gerado por IA.

### Task 3: Implementação do `dock_settings.gd`
- [ ] Criar classe `DockSettings` para aba de configurações e cabeçalhos.
- [ ] Gerenciar seletor de presets (Gemini, OpenAI, Local), API keys, base URLs e modelos.
- [ ] Gerenciar troca de idioma dinâmico (11 línguas) via `LocaleManager`.
- [ ] Gerenciar painel e botões de indexação do `VectorDB`.

### Task 4: Implementação do `dock_chat.gd`
- [ ] Criar classe `DockChat` para envio de mensagens, anexos de arquivos/imagens e streaming.
- [ ] Mapear bolhas BBCode de chat, tokens, badges de ferramentas e blocos de código.
- [ ] Mapear histórico de conversas e botão de sumarização (`SummarizeBtn`).
- [ ] Mapear ações mágicas (`MagicActionsBtn`) e reprodutor de áudio TTS (`TTSPlayer`).
- [ ] Mapear drag & drop de nós da árvore e arquivos.

### Task 5: Refatoração da Fachada `dock.gd`
- [ ] Instanciar e inicializar os 4 controladores no `setup()`.
- [ ] Manter contratos de API intactos para `gamedev_ai.gd` (`_set_client`, `_on_log_entry`, `preset_changed`, `settings_updated`).
- [ ] Delegar eventos de nó para seus respectivos controladores.

---

## 🛡️ Checklist de Blindagem e Verificação
- [ ] Nenhuma referência a nó único (`%NodeName`) foi quebrada.
- [ ] Todos os métodos públicos chamados por `gamedev_ai.gd` continuam com a mesma assinatura.
- [ ] Sinais `preset_changed` e `settings_updated` continuam disparando corretamente.
- [ ] Streaming de chat e badges de ferramentas continuam funcionando perfeitamente.
- [ ] Painel de Diff continua interceptando e aplicando mudanças de código com Undo/Redo.
- [ ] Operações de Git assíncronas continuam atualizando o status sem congelar a UI.
- [ ] Troca de idiomas e persistência de presets continuam funcionando.
