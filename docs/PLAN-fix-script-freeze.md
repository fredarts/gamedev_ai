# PLAN-fix-script-freeze.md
## Resolução de Travamentos e Otimização de Leitura de Múltiplos Scripts

---

## 🎯 Objetivo
Eliminar congelamentos ("Não Respondendo") e falhas na Godot Engine quando a IA processa e lê múltiplos arquivos de script em lote, garantindo 60 FPS no editor, transferência assíncrona em background e preservação de 100% do contexto relevante da tarefa ativa.

---

## 🔍 Diagnóstico e Análise de Causa Raiz

| Componente | Problema Identificado | Impacto |
| :--- | :--- | :--- |
| **`dock_chat.gd`** | `_append_collapsible_block` injeta todo o texto lido (milhares de linhas de código) diretamente no `RichTextLabel` com `fit_content = true`. | Bloqueia a Main Thread do Godot com cálculo de layout de fontes (HarfBuzz / TextServer). |
| **`ai_provider.gd`** | `http_request.use_threads` permanece `false` por padrão. | Transferência de JSONs pesados com histórico fatiada no frame loop principal do editor. |
| **`ai_provider.gd`** | `_sanitize_old_tool_outputs()` só checava roles `"function"` e `"tool"`, ignorando `"role": "user"` do Gemini (`functionResponse`). | Histórico cresce indefinidamente sem podar saídas de ferramentas de turnos passados. |
| **`ai_provider.gd`** | `prune_history()` não permitia descartar saídas anteriores ao active prompt de forma seletiva. | Acúmulo de megabytes em memória durante longas sessões de chat. |
| **`file_tools.gd`** | `read_file` sem suporte opcional a paginação (`start_line`, `end_line`) e sem teto de segurança. | Leituras de arquivos gigantescos consomem cotas desnecessárias de tokens. |

---

## 📐 Solução Proposta

```
┌────────────────────────────────────────────────────────────────────────┐
│                        ARQUITETURA DA SOLUÇÃO                          │
├────────────────────────────────┬───────────────────────────────────────┤
│        CAMADA DE UI            │          CAMADA DE PROVEDOR           │
│   (dock_chat.gd)               │   (ai_provider.gd / gemini_provider)  │
├────────────────────────────────┼───────────────────────────────────────┤
│ • O RichTextLabel exibe apenas │ • http_request.use_threads = true     │
│   resumos / chips compactos    │ • Gemini tool outputs no histórico    │
│   ex: "📄 Lido player.gd       │   são preservados durante o prompt    │
│   (450 linhas)"                │   ativo e podados em turnos velhos.   │
│ • Zero sobrecarga no HarfBuzz  │ • Upload em background worker thread  │
└────────────────────────────────┴───────────────────────────────────────┘
```

---

## 📋 Tarefas de Implementação

### Fase 1: Proteção e Virtualização da UI do Chat (`dock_chat.gd`)
- [ ] **1.1** Modificar `_append_collapsible_block` em `addons/gamedev_ai/dock/dock_chat.gd`:
  - Se o conteúdo ultrapassar 25 linhas ou 1.200 caracteres, truncar a visualização para o preview inicial (primeiras 10 linhas + resumo `... [X linhas omitidas da visualização]`).
  - Garantir que o conteúdo cru permaneça intacto no payload enviado à IA.

### Fase 2: Ativação de Threads no `AIProvider` (`ai_provider.gd`)
- [ ] **2.1** Ativar `http_request.use_threads = true` no método `setup()` de `addons/gamedev_ai/ai_provider.gd`.
- [ ] **2.2** Atualizar o `_timeout_timer` e gerenciador de estado para garantir sincronia limpa e sem conflito de concorrência com o `HTTPRequest`.

### Fase 3: Pruning Inteligente e Compatibilidade com Gemini (`ai_provider.gd`)
- [ ] **3.1** Atualizar `_sanitize_old_tool_outputs()` para reconhecer o formato do Gemini (`role == "user"` contendo `parts` com `functionResponse`).
- [ ] **3.2** Garantir regra de isolamento: saídas de ferramentas geradas no prompt ativo **nunca** são podadas enquanto a resposta estiver em progresso; a poda só age em saídas de ferramentas de interações passadas/concluídas.

### Fase 4: Suporte a Intervalos no `FileTools` (`file_tools.gd` e `tool_executor.gd`)
- [ ] **4.1** Em `addons/gamedev_ai/tools/file_tools.gd`, estender `_read_file(path, start_line = 1, end_line = -1)` para permitir leitura de fatias específicas quando solicitado pela IA.
- [ ] **4.2** Atualizar a declaração do schema em `tool_executor.gd` e as orientações em `system_prompt.gd`.

---

## 🧪 Plano de Verificação

1. **Teste de UI com Arquivo Grande:**
   - Disparar a leitura de um script com mais de 1.000 linhas e verificar se o chat responde instantaneamente sem congelar a janela do editor.
2. **Teste de Lote (Batch Tool Calls):**
   - Solicitar à IA que analise 5 scripts simultâneos (`player.gd`, `dock_chat.gd`, `ai_provider.gd`, `gemini_provider.gd`, `tool_executor.gd`).
   - Verificar se o framerate do Godot se mantém fluido durante todo o ciclo de leitura e requisição.
3. **Teste de Integridade do Contexto:**
   - Perguntar à IA detalhes específicos localizados no final de um script lido em lote para certificar que o conteúdo não foi cortado para o modelo.
4. **Execução de Testes Automatizados:**
   - Rodar a suíte de testes do plugin (`test_runner.gd` / GUT) para garantir que nenhuma regressão foi introduzida.

---

## 👥 Atribuição de Especialistas
- **Primary Agent:** `debugger` & `game-developer`
- **Reviewer:** `project-planner`
