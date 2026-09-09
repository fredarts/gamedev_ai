# PLAN: Redesign Visual e UX/UI do Plugin GamedevAI (Estilo Antigravity & Glassmorphism)

**Data:** 2026-09-09  
**Status:** Proposta & Planejamento  
**Agentes Responsáveis:** `project-planner`, `frontend-specialist`, `game-developer`  
**Referência de Estilo:** Antigravity IDE, Cursor, Linear, Glassmorphism Dark Theme  

---

## 1. Diagnóstico e Análise Crítica do Estado Atual

A partir da inspeção visual das 4 abas atuais do plugin (`Chat`, `Configurações`, `Git`, `Shaders`) e do código em `addons/gamedev_ai/dock/`:

### 1.1. Aba Chat
* **Problema de Densidade e Poluição no Topo:** A barra superior combina `v`, `A-`, `A+`, `+ New Chat`, `History`, `Summarize` em botões retangulares sólidos cinzas, sem hierarquia. O botão de nova conversa não se destaca como ação primária.
* **Mensagens e Bolhas de Chat:** O balão do usuário possui uma borda azul opaca espessa (`border_color = Color(0.2, 0.22, 0.3)`), cantos simples e fundo sólido escuro sem profundidade. O contador de tokens fica isolado sem um pill badge elegante.
* **Pill de Contexto ("Using selection..."):** Um retângulo escuro solto no meio da tela, sem ícone distintivo ou badge semântico.
* **Barra de Voz e Magic Actions:** O botão "Read Aloud", o controle de áudio e o botão "Magic Actions" parecem três barras empilhadas e desconexas, competindo pela atenção antes da caixa de prompt.
* **Caixa de Entrada (Prompt Input):** O botão de enviar/parar vermelho no canto inferior direito destoa muito fortemente do restante da paleta (vermelho vivo com cantos circulares). O campo de texto tem borda simples e padding rígido.

### 1.2. Aba Configurações
* **Alinhamento Quebrado:** A linha de presets aperta `Preset:`, dropdown, `Adicionar`, `Editar`, `Del` em botões de larguras desiguais.
* **Instruções Customizadas:** Um `TextEdit` plano e escuro ocupando muito espaço vertical, com um botão "✨ Enhance Instructions with AI" estilizado com gradiente de emoji que quebra a sobriedade profissional.
* **Vector Database:** Uso de emojis literais (`🗃 Vector Database`, `🔍 Scan Changes`, `⚡ Index Codebase`) em vez de ícones SVG consistentes do tema do Godot/Antigravity. O display é uma caixa de texto crua.

### 1.3. Aba Git
* **Botão Gigante "Initialize Repository":** Um verde brilhante plano (`#2e9947`) ocupando toda a largura no topo, criando um salto visual agressivo.
* **Cores e Contraste Inconsistentes:** O botão "Refresh Status" é azul ardósia, enquanto botões na base usam contornos vermelhos neon ("Undo Uncommitted Changes", "Force Pull Overwrite", "Forçar Envio") sem espaçamento respirável.
* **Falta de Empty State Ilustrado:** Mensagem simples em texto "No Git repository found in project root" dentro de um quadro vazio.

### 1.4. Aba Shaders
* **Salada de Cores nos Botões de Ação:** A barra inferior exibe 4 botões coloridos lado a lado:
  - 🔄 Recompile: Azul
  - 🎲 Randomize: Roxo
  - 🎯 Apply to Selection: Verde Claro
  - 💾 Save to Project: Verde Oliva
  Essa profusão de cores primárias diferentes causa fadiga visual e destoa do padrão de ferramentas profissionais (onde botões secundários são neutros/glass e apenas o CTA principal tem acento).
* **Grid de Parâmetros:** Controles de shader (Active, Flash Color, Flash Modifier) possuem espaçamento e alinhamento irregular em relação ao viewport 2D.

---

## 2. Conceito Visual Proposto: "Antigravity Dark Glass"

### 2.1. Fundamentos do Design System (UI/UX Pro Max)
* **Glassmorphism Refinado:**
  - Superfícies translúcidas com profundidade em camadas:
    - **Nível 0 (Fundo do Dock):** `#0B0D13` (preto azulado profundo).
    - **Nível 1 (Cards & Painéis):** `rgba(18, 22, 32, 0.70)` com borda sutil `rgba(255, 255, 255, 0.08)`.
    - **Nível 2 (Inputs, Elementos Interativos):** `rgba(26, 32, 48, 0.65)` com borda `rgba(255, 255, 255, 0.12)`.
    - **Nível 3 (Hover / Destaque):** `rgba(38, 48, 70, 0.85)` com borda com brilho de foco `#3B82F6` (Electric Blue).
* **Efeito "Glass Rim" (Refração de Borda):**
  - No Godot 4, criamos `StyleBoxFlat` com bordas finas de 1px com transparência branca (`Color(1, 1, 1, 0.08)` a `Color(1, 1, 1, 0.14)`), `corner_radius` suave de 8px a 12px, e sombra difusa discreta (`shadow_color = Color(0, 0, 0, 0.35)`, `shadow_size = 6`).
* **Paleta de Cores Unificada (Sem Emojis & Sem Cores Berrantes):**
  - **Acento Primário:** `#3B82F6` (Electric Blue) / `#2563EB` (Active/Click).
  - **Superfície Base:** `#0F172A` / `#111827`.
  - **Texto Primário:** `#F8FAFC` (Slate 50).
  - **Texto Secundário / Muted:** `#94A3B8` (Slate 400).
  - **Semântica:**
    - Sucesso: Emerald suave (`#10B981`, badge translúcido `rgba(16, 185, 129, 0.12)`).
    - Atenção / Modificado: Amber (`#F59E0B`).
    - Perigo / Erro: Rose refinado (`#F43F5E`, não vermelho puro saturado).
* **Iconografia Padronizada:**
  - Substituir todos os emojis por ícones SVG monocromáticos com preenchimento/contorno consistente (SVG tinting com suporte nativo do plugin em `_load_svg_icon`).

---

## 3. Plano de Melhorias por Módulo

### Fase 1: Fundação do Design System & Estilos Nativos Godot (`dock_theme.gd` ou `dock.gd`)
- [ ] Criar gerador de estilos `StyleBoxGlass`:
  - `create_glass_panel(bg_alpha, border_alpha, corner_radius)`
  - `create_glass_input(corner_radius, is_focused)`
  - `create_glass_button(variant: "primary" | "secondary" | "danger" | "ghost")`
- [ ] Implementar hierarquia tipográfica com fontes nativas do Godot Editor (mantendo proporções ideais e contraste WCAG AAA).

### Fase 2: Redesign da Aba Chat
- [ ] **Top Bar:** Agrupar `A- / A+` em um segmented control discreto; transformar `+ New Chat` em um botão primário com ícone sutil e borda de vidro; histórico e opções em botões de ação compactos.
- [ ] **Bolhas de Mensagens:**
  - Usuário: Card translúcido com leve gradiente escuro (`rgba(30, 41, 59, 0.85)`), borda superior sutil e badge "Você" com timestamp/token pill em estilo chip.
  - Assistente (GamedevAI): Fundo transparente com borda esquerda acentuada ou card translúcido limpo (`rgba(15, 23, 42, 0.6)`), tipografia nítida e bloco de código integrado.
- [ ] **Área de Prompt e Ações:**
  - Transformar o container de input em um card flutuante integrado: textarea sem bordas internas brutas, botões de anexo e configurações como icon-buttons minimalistas dentro do rodapé do card de input.
  - Botão de envio elegante: ícone de seta ou envio moderno, integrado organicamente, mudando para estado de carregamento/stop pulsante sutil.
  - Context Pill: chip compacto flutuante acima do input com botão de fechar (x) e ícone de script Godot.

### Fase 3: Redesign da Aba Configurações & Vector Database
- [ ] Unificar a barra de presets em um card estilizado com ações em ícones (Adicionar `+`, Editar `✎`, Remover `🗑`).
- [ ] Substituir o botão "Enhance" por uma ação contextual com ícone limpo de faísca (sparkles) e micro-interação.
- [ ] Vector Database: Transformar a visualização em um painel estruturado com status do índice (Ex: "128 arquivos indexados • Atualizado há 5 min") e botões de ação harmonizados.

### Fase 4: Redesign da Aba Git
- [ ] Criar componente de **Empty State Moderno** quando não houver repositório (ícone de branch em vidro translúcido, descrição e botão de inicialização elegante).
- [ ] Quando ativo: árvore de arquivos modificados com tags de status (`M`, `A`, `D`) coloridas em badges translúcidos.
- [ ] Grupo de botões de sincronização: "Commit & Push" como ação principal destacada; ações perigosas ("Force Push", "Undo") em menu suspenso ou botões de alerta discretos para evitar cliques acidentais e poluição visual.

### Fase 5: Redesign da Aba Shaders
- [ ] Toolbar superior unificada para categoria e shader presets em estilo pill/glass.
- [ ] Viewport 2D com moldura em vidro (bezel moderno e indicador de zoom/grid discreto).
- [ ] Inspetor de Uniforms: Controles de cores e sliders remodelados com estilo plano translúcido.
- [ ] Barra inferior harmonizada: Botão principal "Apply to Selection" em acento primário; "Recompile", "Randomize" e "Save" em estilo neutro glass.

---

## 4. Cronograma e Dependências

| Tarefa | Arquivos Afetados | Complexidade |
|--------|-------------------|--------------|
| 1. Design Tokens & Glass Style Factory | `dock.gd`, `dock_chat.gd` | Média |
| 2. Redesign Chat Bubbles & Input Box | `dock_chat.gd`, `dock.tscn` | Alta |
| 3. Redesign Git View & Empty States | `dock_git.gd`, `dock.tscn` | Média |
| 4. Redesign Settings & Vector DB | `dock_settings.gd`, `dock.tscn` | Média |
| 5. Redesign Shaders Dock & Uniforms | `dock_shader.gd`, `dock.tscn` | Média |
