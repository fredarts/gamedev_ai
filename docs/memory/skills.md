# As 25 Skills Embutidas (Catálogo Completo)

O Gamedev AI não é uma IA genérica que depende apenas da memória treinada na internet. Ele conta com **25 módulos de expertise** escritos especificamente para Godot 4.6, que são consultados automaticamente durante as conversas para garantir que o código gerado siga as melhores práticas da indústria.

Abaixo, cada uma das 25 Skills é detalhada com seu propósito e exemplos de quando a IA as utiliza.

---

## 📜 GDScript & Linguagem

### 1. `gdscript_style_guide`
**Guia de Estilo GDScript.** Convenções de nomenclatura (snake_case, PascalCase), organização de arquivos, tipagem estática, ordem de declarações e boas práticas de formatação seguindo o padrão oficial do Godot.

### 2. `gdscript_modern_features`
**Funcionalidades Modernas do GDScript.** Lambdas, tipagem estática expandida, `await`, `super()`, enums tipados, `match` patterns avançados e todas as novidades do GDScript 2.0+ que substituíram sintaxes antigas.

### 3. `gdscript_deprecated`
**Funções Deprecadas do GDScript.** Lista completa de funções, métodos e padrões que foram removidos ou substituídos entre Godot 3 e Godot 4. A IA consulta esta skill para nunca sugerir código obsoleto.

### 4. `gdscript_recipes_and_patterns`
**Receitas e Padrões de GDScript.** Soluções prontas para problemas comuns: singleton pattern, object pooling, dependency injection, observer pattern e implementações idiomáticas em GDScript.

### 5. `gdscript_signals_and_tweens`
**Sinais e Tweens.** Guia aprofundado sobre o sistema de sinais do Godot 4, `SceneTreeTween`, criação de animações procedurais, encadeamento de tweens e boas práticas de desacoplamento com sinais.

---

## 🏗️ Arquitetura & Estrutura

### 6. `common_architectures`
**Arquiteturas Comuns de Jogos.** Padrões arquiteturais como Entity-Component, MVC para jogos, Service Locator, Event Bus e como estruturar projetos Godot de médio e grande porte.

### 7. `project_structure_guidelines`
**Diretrizes de Estrutura de Projeto.** Organização ideal de pastas (`src/`, `assets/`, `ui/`, `autoloads/`), convenções de nomes de arquivos, autoloads vs. dependency injection e quando usar cada abordagem.

### 8. `state_machine_implementation`
**Implementação de Máquinas de Estados.** Padrão de máquina de estados com nós filhos, transições limpas, estados hierárquicos e integração com AnimationTree para personagens complexos.

---

## 🎮 Sistemas de Jogo

### 9. `inventory_and_item_systems`
**Sistemas de Inventário e Itens.** Arquitetura de inventários baseada em Resources, slots, stacking, drag & drop de itens, serialização para save games e UI de inventário responsiva.

### 10. `quest_and_dialogue_systems`
**Sistemas de Quest e Diálogo.** Implementação de árvores de diálogo, sistema de missões com estados (ativa/completa/falha), NPCs, condições de progresso e integração com UI.

### 11. `save_system_and_persistence`
**Sistema de Save e Persistência.** Serialização completa de game state em JSON/binário, auto-save, múltiplos slots, versionamento de saves e migração entre versões.

### 12. `data_management_and_crafting`
**Gestão de Dados e Crafting.** Sistemas de crafting com receitas baseadas em Resources, bancos de dados de itens, tabelas de loot e balanceamento de economia de jogo.

---

## 🕹️ Mecânicas & Física

### 13. `physics_and_collision_handling`
**Física e Colisão.** Configuração de collision layers/masks, CharacterBody2D/3D, RigidBody, raycasting, áreas de detecção e resolução de problemas comuns de física.

### 14. `input_handling_and_remapping`
**Input e Remapeamento.** InputMap, ações customizadas, suporte a gamepad/teclado/touch, remapeamento em runtime, input buffering e dead zones.

### 15. `ai_and_pathfinding`
**IA e Pathfinding.** NavigationServer2D/3D, NavigationAgent, avoidance, behavior trees simplificadas, perseguição, patrulha e IA de inimigos com estados.

---

## 🎨 Visual & Áudio

### 16. `shaders_and_vfx`
**Shaders e Efeitos Visuais.** Shaders em Godot Shading Language, efeitos de dissolve, outline, distorção, partículas GPU, trails e técnicas de VFX para jogos 2D e 3D.

### 17. `post_processing_and_environment`
**Pós-Processamento e Ambiente.** WorldEnvironment, glow, fog, SSAO, SSR, tonemap, color correction e configuração de ambientes cinematográficos.

### 18. `animation_and_cutscenes`
**Animação e Cutscenes.** AnimationPlayer, AnimationTree, blend spaces, state machines de animação, cutscenes com AnimationPlayer e transições suaves.

### 19. `audio_management_best_practices`
**Gerenciamento de Áudio.** AudioBus, AudioStreamPlayer2D/3D, pool de efeitos sonoros, música adaptativa, crossfade, mixagem e organização do sistema de áudio.

---

## 🖥️ Interface & Plataforma

### 20. `ui_ux_patterns`
**Padrões de UI/UX.** Menus responsivos, HUD, themes globais, focus navigation para gamepad, transições de tela, pop-ups e melhores práticas de UI no Godot.

### 21. `mobile_and_resolution_scaling`
**Mobile e Escalamento de Resolução.** Configuração de stretch mode, aspect ratio, touch input, virtual joystick, otimizações para mobile e testes multi-resolução.

### 22. `localization_and_i18n`
**Localização e Internacionalização.** Sistema de traduções com `.csv`/`.po`, TranslationServer, troca de idioma em runtime, formatação de números/datas e RTL support.

---

## 🌐 Multiplayer & Performance

### 23. `multiplayer_and_networking_api`
**Multiplayer e Networking.** ENet, WebSocket, MultiplayerSpawner/Synchronizer, RPCs, authority, client-server architecture, lobby systems e sincronização de estado.

### 24. `performance_optimization`
**Otimização de Performance.** Profiling, object pooling, LOD, culling, batch rendering, otimização de GDScript, redução de draw calls e técnicas para jogos 60fps.

### 25. `level_generation_and_pcg`
**Geração de Levels e Procedural Content.** Geração procedural de dungeons, wave function collapse, noise-based terrain, TileMap automático e sementes aleatórias reproduzíveis.

---

## 🛠️ Criando Suas Próprias Skills

O sistema de Skills é **extensível**! Você pode criar seus próprios arquivos `.md` na pasta `addons/gamedev_ai/skills/` para ensinar à IA as regras específicas do seu projeto.

**Exemplo:** Crie um arquivo chamado `meu_estilo_de_arte.md` com:
```markdown
# Regras de Arte do Nosso Estúdio

- Todos os sprites devem ter resolução 16x16 ou 32x32
- Usar paleta de cores limitada (máximo 32 cores)
- Animações de personagem devem ter no mínimo 4 frames
- Nomear sprites como: tipo_nome_acao_frame.png
```

A IA passará a seguir essas regras sempre que criar ou modificar assets visuais no seu projeto.
