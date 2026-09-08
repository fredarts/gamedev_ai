# Project Plan: Gerador Procedural de Efeitos Sonoros (SFX) [COMPLETO, ROBUSTO & PRÁTICO]

## 📋 Resumo Executivo
- **Objetivo**: Integrar um sistema de síntese procedural de efeitos sonoros (SFX) completo, de alta fidelidade e hiper-prático diretamente no plugin **Gamedev AI** para o Godot 4.x. 
- **Filosofia de Design**:
  - **Robusto & Completo**: Motor de síntese de áudio PCM 16-bit com 6 formas de onda (Seno, Quadrada PWM, Dente de Serra, Triângulo, Ruído Branco e Ruído Chiptune Lo-Fi), filtros de corte (Low-pass/High-pass), envelope ADSR suavizado (sem pops/cliques), bitcrusher, arpejo e pitch slide.
  - **Prático & Fácil de Usar**:
    - **Para a IA**: Ferramenta mágica com inferência semântica: a IA pode apenas chamar `generate_sfx(description: "moeda retrô brilhante")` ou presets diretos; se o caminho do arquivo não for informado, o gerador cria e organiza automaticamente em `res://audio/sfx/<nome>.wav`.
    - **Para o Usuário**: Painel dedicado no Dock com 1-Click Preview, botão "Mutate/Randomize" (estilo bfxr), exportação direta para um nó `AudioStreamPlayer` na cena ativa com 1 clique, e slash command `/sfx <tipo>`.

- **Arquivos Alvo**:
  - `addons/gamedev_ai/audio/sfx_synthesizer.gd` [NOVO] - Motor matemático de síntese (formas de onda, envelope ADSR, modulações, bitcrusher, filtros IIR).
  - `addons/gamedev_ai/audio/sfx_presets.gd` [NOVO] - Biblioteca expandida de presets de jogos organizados por categorias (Ação, Plataforma, RPG, UI, Arcade) com suporte a mutação por seed.
  - `addons/gamedev_ai/audio/wav_writer.gd` [NOVO] - Codificador RIFF WAVE com criação automática de pastas recursivas e scan de importação imediato.
  - `addons/gamedev_ai/tools/audio_tools.gd` [NOVO] - Ferramentas para a IA: `generate_sfx` (com inferência semântica e auto-path) e `play_sfx_preview`.
  - `addons/gamedev_ai/tool_executor.gd` [MODIFICADO] - Registro do `AudioTools` e validação de argumentos.
  - `addons/gamedev_ai/dock/dock_sfx.gd` [NOVO] - Controlador da interface de SFX no Dock com galeria rápida, visualizador de onda e exportação para a cena ativa.
  - `addons/gamedev_ai/dock/dock_chat.gd` [MODIFICADO] - Mapeamento do slash command `/sfx` no chat.
  - `addons/gamedev_ai/system_prompt.gd` [MODIFICADO] - Instruções e regras para a IA usar sons procedurais em mecânicas e UI.

---

## 🏗️ Arquitetura Completa & Fluxo de Uso Prático

```
                                  ┌───────────────────────────────┐
                                  │      Interação do Usuário     │
                                  │  - Painel SFX no Dock         │
                                  │  - Slash Command: /sfx coin   │
                                  │  - Solicitação da IA no Chat  │
                                  └───────────────┬───────────────┘
                                                  │
                                                  ▼
                                  ┌───────────────────────────────┐
                                  │           AudioTools          │
                                  │  - Semantic Preset Resolver   │
                                  │  - Auto Pathing (res://audio/)│
                                  │  - Direct In-Memory Preview   │
                                  └───────────────┬───────────────┘
                                                  │
                                                  ▼
                                  ┌───────────────────────────────┐
                                  │         SFXSynthesizer        │
                                  │  - 6 Formas de Onda           │
                                  │  - ADSR Envelope com Anti-Pop │
                                  │  - Bitcrusher & Lo-Fi Noise   │
                                  │  - Pitch Slides & Arpeggios   │
                                  │  - Low/High Pass Filters      │
                                  └──────┬─────────────────┬──────┘
                                         │                 │
            ┌────────────────────────────┴─────┐     ┌─────┴────────────────────────────┐
            ▼                                  ▼     ▼                                  ▼
┌─────────────────────────┐ ┌────────────────────┐ ┌───────────────────┐ ┌──────────────────────┐
│     AudioStreamWAV      │ │  Direct Scene Hook │ │     WAVWriter     │ │   Filesystem Auto    │
│  (Preview Instantâneo   │ │ Cria AudioStream-  │ │ Grava RIFF WAVE   │ │ Criação de pastas    │
│   sem salvar em disco)  │ │ Player na cena     │ │ 16-bit PCM 44.1kHz│ │ e importação no Godot│
└─────────────────────────┘ └────────────────────┘ └───────────────────┘ └──────────────────────┘
```

---

## 🎯 Task Breakdown Detalhado

### 🔷 Task 1: Motor Completo de Síntese de Áudio (`sfx_synthesizer.gd`)
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `game-development`
- **Prioridade**: P0
- **Capacidades Matemáticas**:
  1. **Formas de Onda**:
     - `SINE`: Senoide pura para blips e magia suave.
     - `SQUARE`: Onda quadrada com Duty-Cycle variável (largura de pulso de 10% a 50%) para o clássico som de 8-bit (NES/Game Boy).
     - `SAWTOOTH`: Dente de serra rica em harmônicos para lasers, buzzers e distorções.
     - `TRIANGLE`: Onda triangular suave para passos, saltos e sub-graves.
     - `WHITE_NOISE`: Ruído aleatório contínuo para explosões e vento.
     - `CHIPTUNE_NOISE`: Ruído periódico retro com registrador de deslocamento de 7 ou 15 bits para percussões chiptune.
  2. **Modulações & Dinâmica**:
     - Envelope ADSR: Attack Time, Decay Time, Sustain Level, Release Time com curvas exponenciais.
     - Micro-rampas anti-clipping: Fade-in de 2ms e Fade-out de 5ms automáticos para 0 estalos/clicks de início e fim.
     - Pitch Slide: Mudança contínua de frequência (positiva para subida/jump/coin, negativa para queda/laser/hit).
     - Arpejo: Sequência de até 4 saltos tonais programados em semitons.
     - Vibrato: Modulação de frequência por LFO com controle de velocidade e profundidade.
     - Bitcrusher: Quantização de resolução de bits (ex: reduzir de 16 bits para 4 ou 8 bits para textura retro) e redução de sample rate.
     - Filtros IIR: Low-Pass (abafa agudos) e High-Pass (remove graves).
  3. **Performance**:
     - Síntese rápida por buffers vetoriais em `PackedByteArray` pré-alocados (geração de SFX de 0.5s em < 5ms).
- **INPUT**: Dicionário de parâmetros de síntese.
- **OUTPUT**: Objeto `AudioStreamWAV` pronto para execução ou gravação.
- **VERIFY**: Sintetizar cada forma de onda e testar amplitude estritamente contida em [-32768, 32767].

---

### 🔷 Task 2: Biblioteca de Presets Expandida & Resolvedor Semântico (`sfx_presets.gd`)
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `game-development`
- **Prioridade**: P0
- **Presets Integrados por Categoria**:
  - **Ação & Combate**:
    - `laser`: Disparo rápido de energia com dente de serra e queda exponencial.
    - `laser_heavy`: Disparo de canhão de plasma com filtro abafado.
    - `explosion`: Explosão massiva com ruído branco, queda de tom e decay longo.
    - `hit`: Impacto corporal ou de projétil curto com ruído e triângulo.
    - `hurt`: Som de dano tomado pelo personagem com tom descendente.
  - **Plataforma & Movimentação**:
    - `jump`: Salto clássico com onda quadrada e pitch slide ascendente.
    - `double_jump`: Salto com arpejo duplo rápido.
    - `land`: Impacto no chão curto e abafado com low-pass.
    - `dash`: Efeito rápido de vento/whoosh com ruído filtrado.
    - `coin`: Som metálico clássico brilhante de 2 tons ascendentes (Si5 -> Mi6).
    - `powerup`: Arpejo ascendente triunfante de 4 tons com vibrato sutil.
  - **Interface & UI**:
    - `ui_click`: Clique de botão seco e tátil (10ms).
    - `ui_hover`: Blip sutil e agudo de passagem de cursor.
    - `ui_confirm`: Acorde curto ascendente de confirmação.
    - `ui_cancel`: Tom descendente curto de recusa/fechamento.
    - `ui_error`: Buzzer curto com onda dente de serra para alertas de erro.
  - **Narrativa & Arcade**:
    - `dialogue_blip`: Som de fala estilo Undertale/Animal Crossing com pitch modulável por personagem.
    - `game_over`: Sequência descendente melancólica com arpejo retro.
    - `victory`: Fanfarra triunfante curta de vitória.
- **Função de Mutação**: `mutate(preset_params, amount: float = 0.1, seed: int = 0)` permite gerar variações sonoras automáticas (ex: passos na grama nunca soam 100% idênticos).
- **Mapeador Semântico Natural**: `resolve_preset(text: String)` mapeia termos livres como `"moeda"`, `"pulo"`, `"tiro"`, `"som de clique"`, `"explosão"` diretamente para o preset técnico correto.
- **INPUT**: Nome do preset ou descrição em linguagem natural.
- **OUTPUT**: Dicionário completo de parâmetros com variação controlada.
- **VERIFY**: Testar o mapeador semântico com frases em português e inglês e verificar correspondência dos presets.

---

### 🔷 Task 3: Codificador WAV Robusto com Auto-Directory (`wav_writer.gd`)
- **Agente**: `game-developer`
- **Skills**: `clean-code`
- **Prioridade**: P0
- **Recursos Práticos**:
  - Auto-Criação de Pastas: Se o caminho especificado for `res://audio/sfx/weapons/laser.wav` e as pastas não existirem, o codificador cria toda a árvore recursivamente sem travar.
  - Gravação de Cabeçalho RIFF WAVE:
    - `ChunkID`: "RIFF"
    - `Format`: "WAVE"
    - `Subchunk1ID`: "fmt " (16 para PCM, AudioFormat = 1, NumChannels = 1, SampleRate = 44100, BitsPerSample = 16)
    - `Subchunk2ID`: "data" (Tamanho dos dados em bytes)
  - Notificação Automática do Godot: Aciona `EditorInterface.get_resource_filesystem().scan()` para que o arquivo `.wav` vire um recurso utilizável no Inspetor em < 100ms.
- **INPUT**: Buffer de áudio e caminho do arquivo.
- **OUTPUT**: Arquivo `.wav` físico e importado no projeto.
- **VERIFY**: Gravar em subpastas aninhadas inexistentes e validar criação dos diretórios e reprodução do arquivo gerado.

---

### 🔷 Task 4: Ferramentas da IA Simples e Inteligentes (`AudioTools`)
- **Agente**: `game-developer`
- **Skills**: `clean-code`, `api-patterns`
- **Prioridade**: P0
- **Ferramentas Expostas**:
  1. `generate_sfx(preset_or_description: String, path: String = "", params: Dictionary = {})`:
     - Se `path` for omitido, resolve automaticamente para: `res://audio/sfx/<preset>_<timestamp>.wav`.
     - Gera o som, salva no projeto e retorna: `{"success": true, "path": path, "duration": duration}`.
  2. `play_sfx_preview(preset_or_description: String, params: Dictionary = {})`:
     - Sintetiza e toca instantaneamente no editor via `AudioStreamPlayer` sem criar arquivos.
- **Integração no `tool_executor.gd`**:
  - `AudioTools` registrado no array de handlers com suporte a preview e geração.
- **Integração no `system_prompt.gd`**:
  - "When adding audio to scenes or buttons, proactively use `generate_sfx` to create `.wav` files and assign them to `AudioStreamPlayer` nodes or `@export var sound: AudioStream`."
- **INPUT**: Tool call da IA.
- **OUTPUT**: Feedback claro com caminho gerado ou áudio reproduzido.
- **VERIFY**: Testar chamada omitindo o caminho e verificar geração automática na pasta padrão `res://audio/sfx/`.

---

### 🔷 Task 5: Interface Interativa Prática no Dock (`dock_sfx.gd` & Slash Command `/sfx`)
- **Agente**: `frontend-specialist` / `game-developer`
- **Skills**: `clean-code`, `frontend-design`
- **Prioridade**: P1
- **Funcionalidades da Interface**:
  1. **Galeria de Presets Rápidos**:
     - Botões com ícones e cores: `🪙 Moeda`, `🦘 Pulo`, `🔫 Laser`, `💥 Explosão`, `🥊 Golpe`, `⭐ Powerup`, `🔔 Blip`, `🖱️ Clique`, `💀 Game Over`.
     - Clicar no botão toca o som instantaneamente (preview de 1 clique).
  2. **Controles de Customização Descomplicados**:
     - Slider de **Pitch** (grave a agudo).
     - Slider de **Duração** (rápido a longo).
     - Slider de **Bitcrush** (som moderno a som retro 8-bit).
     - Botão `🎲 Mutar / Randomizar`: Gera variações sem mexer nos sliders.
  3. **Ações Práticas de 1 Clique**:
     - `💾 Salvar no Projeto`: Salva como arquivo `.wav` na pasta padrão ou personalizada.
     - `📌 Inserir na Cena Atual`: Cria automaticamente um nó `AudioStreamPlayer` com o som sintetizado configurado como filho do nó selecionado na árvore do editor!
  4. **Slash Command `/sfx` no Chat**:
     - Usuário pode digitar `/sfx coin` ou `/sfx laser` no chat para gerar e ouvir na hora sem abrir painéis extras.
- **INPUT**: Ações do usuário no Dock ou chat.
- **OUTPUT**: Geração de áudio sem atrito em menos de 2 segundos.
- **VERIFY**: Testar o fluxo completo: Clicar em "Pulo", clicar em "Mutar", clicar em "Inserir na Cena Atual" e validar criação do `AudioStreamPlayer` na cena.

---

## 🛡️ Matriz de Riscos & Mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| **Pops / Cliques de descontinuidade de onda** | Média | Fade-in e Fade-out automáticos com curvas cossenoide nos extremos do buffer. |
| **Sobrecarga de pastas desorganizadas no projeto** | Baixa | Padronização automática em `res://audio/sfx/` com categorização por data ou tipo. |
| **Usuário sem nó selecionado ao 'Inserir na Cena'** | Baixa | Se nenhum nó estiver selecionado, anexa como filho da raiz da cena ativa com aviso amigável. |

---

## 🧪 Phase X: Plano de Verificação & Validação

- [ ] **1. Teste de Formas de Onda & Síntese**:
  - Validar integridade matemática das 6 formas de onda sem aliasing ou estouro de amplitude.
- [ ] **2. Teste de Presets & Mutação**:
  - Testar todos os 15+ presets e verificar que mutações geram sons harmoniosos.
- [ ] **3. Teste de Auto-Directory & Gravação WAV**:
  - Gravar áudio em pasta inexistente e checar criação automática dos diretórios e integridade do arquivo `.wav`.
- [ ] **4. Teste de Tool da IA com Auto-Path**:
  - Chamar `generate_sfx("jump")` sem passar `path` e verificar salvamento automático em `res://audio/sfx/jump_*.wav`.
- [ ] **5. Teste de Interface & Inserção na Cena**:
  - Utilizar a interface do Dock para gerar um som e inserir na cena aberta, verificando o nó `AudioStreamPlayer` funcional.
