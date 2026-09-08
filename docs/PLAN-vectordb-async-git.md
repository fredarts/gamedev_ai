# Project Plan: Vector DB Cloud Gemini & Non-Blocking Async Git

## 📋 Overview
- **Task**: Corrigir URL e modelo de embedding no `vector_db.gd` (`text-embedding-004`) e tornar todas as operações do `git_manager.gd` assíncronas via `Thread`.
- **Target Files**:
  - `addons/gamedev_ai/vector_db.gd`
  - `addons/gamedev_ai/git_manager.gd`
  - `addons/gamedev_ai/dock/dock.gd`

---

## 🎯 Task Breakdown

### Task 1: Vector DB Gemini Endpoint & Model Update
- [ ] Atualizar `_prepare_request` em `vector_db.gd` para usar o modelo `text-embedding-004`.
- [ ] Configurar URL de produção: `https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=` + `api_key`.
- [ ] Validar extração do vetor de resposta no manipulador `_on_http_request_completed`.

### Task 2: Git Manager Thread-based Async Architecture
- [ ] Adicionar sinais de início e conclusão de comandos Git em `git_manager.gd`.
- [ ] Implementar `execute_git_async()` utilizando `Thread` do Godot para executar `OS.execute` sem bloquear a Main Thread.
- [ ] Conectar os métodos (`git_status`, `git_pull`, `git_push`, `git_force_pull`, etc.) à fila de execução em thread.

### Task 3: UI Integration in Dock
- [ ] Conectar os sinais assíncronos do `git_manager` em `dock.gd`.
- [ ] Adicionar feedback visual (loading/spinner ou texto "Executando...") durante operações do Git.
- [ ] Atualizar a interface automaticamente ao término da thread sem travamentos.

---

## 🏁 Verification Checklist
- [ ] Indexação com Gemini completa sem erros de conexão na porta 8000.
- [ ] Busca semântica retorna resultados relevantes com embeddings gerados pelo `text-embedding-004`.
- [ ] Operações de Git não congelam os frames/interação da Godot.
