# Agent Integration Plan

## Overview
Integração progressiva e segura das diretrizes metodológicas do Kit `.agent` no plugin Gamedev AI. O objetivo é torná-lo um assistente autônomo, metódico e proativo – capaz de validar o próprio trabalho e rotear contextos focados –, mantendo o ecossistema existente estável sem causar regressões.

## Project Type
**BACKEND** (Godot Plugin Core / Prompt Engineering and Tools)

## Success Criteria
- O "Socratic Gate" precisa forçar ativamente a IA a fazer perguntas antes de gerar implementações complexas e massivas, mitigando falhas e alucinações.
- Suporte a Workflows por comandos (ex: `/brainstorm`, `/plan` e `/debug`) deve alterar efetivamente o nível de interação.
- Roteamento dinâmico sem interrupção: Contextos (UI, Shader, Core) carregam apenas recursos essenciais.
- Scripts de validação (`audit_tools`) testam e acusam falhas arquiteturais diretamente na Engine.

## Tech Stack
- **Linguagem**: GDScript (Godot 4)
- **Modificações Base**: `system_prompt.gd` (para Personas/Workflows), e arquitetura de Tools da Godot (para Scripts de Auditoria).

## File Structure
```text
addons/gamedev_ai/
├── system_prompt.gd           (Modificação Principal: Slash commands, Personas)
├── tools/
│   └── audit_tools.gd         (Novo Arquivo: Tool para varredura de Nodes/Scripts)
└── skills/
    ├── checklists/            (Novo Diretório: Regras isoladas para Auditoria)
    └── ...
```

## Task Breakdown

### Phase 1: Workflows e Portão Socrático (Altíssima Segurança)
**Task 1.1: Implementar Reconhecimento de Slash Commands**
- **Agent**: `backend-specialist`
- **Skill**: `project-planner`
- **INPUT**: Atualizar a estrutura de definição de prompts no `system_prompt.gd` para que o modelo processe macros como `/brainstorm` (abre questionamento longo sem código), `/plan` (estrutura pastas e cena) e `/debug` (foco restrito a logs).
- **OUTPUT**: Regras de "Triggers" explícitas no system prompt que mudam a postura do agente quando detectadas no payload da mensagem.
- **VERIFY**: Testar o input `/brainstorm sistema de craft`. A IA não usará tools de código; apenas iniciará perguntas estruturais e arquiteturais.

**Task 1.2: Injetar o Socratic Gate (Prevenção de Código Cegos)**
- **Agent**: `orchestrator`
- **Skill**: `brainstorming`
- **INPUT**: Adicionar a obrigatoriedade socrática: "Para QUALQUER requisição estrutural complexa, interrompa a ação e levante no mínimo 2 perguntas de trade-off explícitas para clarificar limites".
- **OUTPUT**: Atualização do `system_prompt.gd` com a trava de segurança ("Socratic Gate").
- **VERIFY**: Solicitar "Crie um RPG top-down". A IA deve rebater imediatamente com o delineamento focado, bloqueando instintivamente geradores de código.

### Phase 2: Roteamento de Contexto Básico (Menos Consumo, Maior Precisão)
**Task 2.1: Estruturar Sistema de Rota (Personas Ocultas)**
- **Agent**: `orchestrator`
- **Skill**: `intelligent-routing`
- **INPUT**: Implementar lógica básica no gerenciamento do contexto da solicitação. Se a prompt for sobre "UI/Control", injetar o contexto e os avisos do persona `ui_ux_designer`. Se for "Node/Refactor", usar `core_programmer`. O fallback será a persona clássica "Godot Expert".
- **OUTPUT**: Lógica de separação em blocos. O System Prompt se transforma em um "assembler" que injeta os pedaços modularmente.
- **VERIFY**: Observar no terminal (logs da API) se a montagem limitou os tokens e focou somente no tópico específico.

**Task 2.2: Transição Lógica da Pasta Skills**
- **Agent**: `frontend-specialist`, `backend-specialist`
- **Skill**: `architecture`
- **INPUT**: Classificar as skills atuais (ex: `ui_ux_patterns.md`, `state_machine_implementation.md`) nos grupos da Persona Ativa, evitando que o prompt consuma toda a base de conhecimentos simultaneamente.
- **OUTPUT**: Hierarquia revisada de skills para matching com as Personas da Task 2.1.
- **VERIFY**: Realizar chamadas simuladas de API sem estourar limites não essenciais. 

### Phase 3: Integração das "Audit Tools" (Qualidade e Validação)
**Task 3.1: Criar Módulo `audit_tools.gd`**
- **Agent**: `test-engineer`
- **Skill**: `testing-patterns`
- **INPUT**: Codificar a ferramenta Read-only capaz de verificar orphan nodes, referências `.get_node()` órfãs e chamadas de métodos inexistentes nas cenas ativas. Registrar na array de ferramentas acessíveis.
- **OUTPUT**: Um novo executor na pasta `tools/` focado em checagem sistêmica que o LLM pode usar passivamente.
- **VERIFY**: Engatilhar a chamada do plugin num projeto com Nós intencionalmente quebrado; deve ser retornado um array detalhando as falhas.

**Task 3.2: Implementar Autonomia de Refinamento (Auto-Audit)**
- **Agent**: `product-owner`, `clean-code`
- **Skill**: `code-review-checklist`
- **INPUT**: Colocar a restrição no prompt do Agente Executor dizendo que "Após concluir alterações profundas num script (ex: chamadas a script_tools.gd), você DEVE rodar `audit_tools.gd` para se aferir antes de encerrar o status ao usuário".
- **OUTPUT**: Loop comportamental onde a edição atrelada à validação em "zero shot", se conserta em background sem input adicional do usuário.
- **VERIFY**: Confirmar nos logs de toolcall se a IA autoacionou o *audit* imediatamente após o de *edit*.

## Phase X: Verification
- [ ] A arquitetura do plugin compila sem erros críticos nas instâncias do Godot Editor (v4.x).
- [ ] O **Socratic Gate** para e bloqueia instritamente requisições de grande porte genéricas.
- [ ] Os logs indicam queda consistente no custo de Token via eliminação de Skill Overflow através do Roteamento (Personas ocultas).
- [ ] As `audit_tools` detectam falhas projetadas e retornam avisos precisos à IA (Read-only status pass test).
