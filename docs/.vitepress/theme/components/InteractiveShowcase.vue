<script setup>
import { ref, onMounted } from 'vue'

const activeTab = ref('mcp')
const activePersona = ref('architect')
const uniformIntensity = ref(0.75)
const diffApplied = ref(false)

// SFX Audio Web Synthesis (Zero dependencies, pure Web Audio API)
let audioCtx = null
const isPlayingSfx = ref(false)
const currentSound = ref('coin')

function playWebSound(type) {
  currentSound.value = type
  isPlayingSfx.value = true
  
  try {
    if (!audioCtx) {
      audioCtx = new (window.AudioContext || window.webkitAudioContext)()
    }
    if (audioCtx.state === 'suspended') {
      audioCtx.resume()
    }
    
    const now = audioCtx.currentTime
    const osc = audioCtx.createOscillator()
    const gain = audioCtx.createGain()
    osc.connect(gain)
    gain.connect(audioCtx.destination)
    
    if (type === 'coin') {
      osc.type = 'sine'
      osc.frequency.setValueAtTime(987.77, now) // B5
      osc.frequency.setValueAtTime(1318.51, now + 0.08) // E6
      gain.gain.setValueAtTime(0.2, now)
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35)
      osc.start(now)
      osc.stop(now + 0.35)
    } else if (type === 'jump') {
      osc.type = 'square'
      osc.frequency.setValueAtTime(150, now)
      osc.frequency.exponentialRampToValueAtTime(600, now + 0.15)
      gain.gain.setValueAtTime(0.15, now)
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.2)
      osc.start(now)
      osc.stop(now + 0.2)
    } else if (type === 'laser') {
      osc.type = 'sawtooth'
      osc.frequency.setValueAtTime(880, now)
      osc.frequency.exponentialRampToValueAtTime(110, now + 0.15)
      gain.gain.setValueAtTime(0.2, now)
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.18)
      osc.start(now)
      osc.stop(now + 0.18)
    } else if (type === 'explosion') {
      // Noise buffer for explosion
      const bufferSize = audioCtx.sampleRate * 0.4
      const buffer = audioCtx.createBuffer(1, bufferSize, audioCtx.sampleRate)
      const data = buffer.getChannelData(0)
      for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1
      }
      const noise = audioCtx.createBufferSource()
      noise.buffer = buffer
      
      const filter = audioCtx.createBiquadFilter()
      filter.type = 'lowpass'
      filter.frequency.setValueAtTime(800, now)
      filter.frequency.linearRampToValueAtTime(50, now + 0.4)
      
      noise.connect(filter)
      filter.connect(gain)
      gain.gain.setValueAtTime(0.3, now)
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4)
      noise.start(now)
      noise.stop(now + 0.4)
    }
  } catch (e) {
    console.warn("Audio Context init deferred", e)
  }
  
  setTimeout(() => {
    isPlayingSfx.value = false
  }, 400)
}

onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active-reveal')
      }
    })
  }, { threshold: 0.1 })

  document.querySelectorAll('.showcase-reveal').forEach(el => observer.observe(el))
})
</script>

<template>
  <section class="deep-showcase-section">
    <div class="showcase-container">
      
      <!-- Section Header -->
      <div class="showcase-header showcase-reveal">
        <span class="section-tag">EXPLORAÇÃO INTERATIVA</span>
        <h2 class="section-title">Engenharia Autônoma em Ação</h2>
        <p class="section-subtitle">
          Clique nas abas interativas abaixo para experimentar cada um dos grandes pilares tecnológicos do Gamedev AI.
        </p>
      </div>

      <!-- Navigation Tabs -->
      <div class="tabs-nav-wrapper showcase-reveal">
        <div class="tabs-nav">
          <button :class="['tab-btn', { active: activeTab === 'mcp' }]" @click="activeTab = 'mcp'">
            <span class="tab-icon">🔌</span>
            <span class="tab-text">Servidor MCP Nativo</span>
          </button>
          
          <button :class="['tab-btn', { active: activeTab === 'orchestrator' }]" @click="activeTab = 'orchestrator'">
            <span class="tab-icon">🤖</span>
            <span class="tab-text">Multi-Agente & Auto-Cura</span>
          </button>
          
          <button :class="['tab-btn', { active: activeTab === 'studios' }]" @click="activeTab = 'studios'">
            <span class="tab-icon">🎨</span>
            <span class="tab-text">Shader & SFX Studios</span>
          </button>
          
          <button :class="['tab-btn', { active: activeTab === 'safety' }]" @click="activeTab = 'safety'">
            <span class="tab-icon">🛡️</span>
            <span class="tab-text">Diff Seguro & Watch Mode</span>
          </button>
        </div>
      </div>

      <!-- Tab Content Area -->
      <div class="tab-content-card showcase-reveal">
        
        <!-- 1. TAB: MCP SERVER -->
        <div v-if="activeTab === 'mcp'" class="panel-layout">
          <div class="panel-info">
            <div class="badge badge-purple">ZERO-COST LOCAL BRIDGE</div>
            <h3 class="panel-heading">Controle Total do Godot a partir de IDEs Externas</h3>
            <p class="panel-body">
              O Gamedev AI inicia um servidor JSON-RPC 2.0 nativo em <code>127.0.0.1:6543</code>. Assistentes externos como <strong>Antigravity, Cursor e Claude Desktop</strong> podem inspecionar cenas, consultar o LSP e manipular o jogo em tempo real.
            </p>
            <ul class="feature-bullets">
              <li>✨ <strong>65 Ferramentas Expostas:</strong> Adicionar nós, pintar tilemaps, gerar shaders e rodar testes.</li>
              <li>🔍 <strong>Recursos MCP em Tempo Real:</strong> Inspeção da Scene Tree viva (<code>godot://scene/active</code>).</li>
              <li>🔒 <strong>100% Local:</strong> Nenhum dado do seu código sai do seu computador.</li>
            </ul>
          </div>

          <div class="panel-visual">
            <div class="terminal-mock">
              <div class="term-bar">
                <span class="circle red"></span>
                <span class="circle yellow"></span>
                <span class="circle green"></span>
                <span class="term-title">mcp_config.json ➔ godot_mcp.py</span>
                <span class="live-tag"><span class="dot-pulse"></span> ONLINE</span>
              </div>
              <div class="term-code">
                <span class="code-comment">// Antigravity IDE executando tool via Godot MCP Server:</span><br>
                <span class="c-key">POST</span> http://127.0.0.1:6543/jsonrpc<br>
                {<br>
                &nbsp;&nbsp;<span class="c-prop">"jsonrpc"</span>: <span class="c-str">"2.0"</span>,<br>
                &nbsp;&nbsp;<span class="c-prop">"method"</span>: <span class="c-str">"tools/call"</span>,<br>
                &nbsp;&nbsp;<span class="c-prop">"params"</span>: {<br>
                &nbsp;&nbsp;&nbsp;&nbsp;<span class="c-prop">"name"</span>: <span class="c-val">"generate_procedural_dungeon"</span>,<br>
                &nbsp;&nbsp;&nbsp;&nbsp;<span class="c-prop">"arguments"</span>: { <span class="c-prop">"algorithm"</span>: <span class="c-str">"BSP"</span>, <span class="c-prop">"max_rooms"</span>: <span class="c-num">8</span> }<br>
                &nbsp;&nbsp;}<br>
                }<br>
                <span class="code-res">➔ Godot Output: [SUCCESS] 8 rooms generated & painted to TileMapLayer.</span>
              </div>
            </div>
          </div>
        </div>

        <!-- 2. TAB: MULTI-AGENT ORCHESTRATOR -->
        <div v-if="activeTab === 'orchestrator'" class="panel-layout">
          <div class="panel-info">
            <div class="badge badge-emerald">PIPELINE DE 4 ESTÁGIOS</div>
            <h3 class="panel-heading">Orquestrador Autônomo com Auto-Cura</h3>
            <p class="panel-body">
              Tarefas complexas não são feitas por um único prompt genérico. O orquestrador divide o trabalho em 4 papéis especializados e repara o código sozinho caso ocorra qualquer erro de compilação ou falha em testes.
            </p>

            <div class="persona-selector">
              <button :class="['persona-btn', { active: activePersona === 'architect' }]" @click="activePersona = 'architect'">
                🟦 Architect
              </button>
              <button :class="['persona-btn', { active: activePersona === 'scene' }]" @click="activePersona = 'scene'">
                🟨 Scene Builder
              </button>
              <button :class="['persona-btn', { active: activePersona === 'coder' }]" @click="activePersona = 'coder'">
                🟩 Coder
              </button>
              <button :class="['persona-btn', { active: activePersona === 'qa' }]" @click="activePersona = 'qa'">
                🟪 QA & Healing
              </button>
            </div>
          </div>

          <div class="panel-visual">
            <div class="orchestrator-card-box">
              <div v-if="activePersona === 'architect'" class="persona-stage">
                <div class="stage-tag">ETAPA 1: PLANEJAMENTO & CONTRATOS</div>
                <h4>Architect Persona</h4>
                <p>Define a arquitetura técnica, sinais públicos e interfaces na memória compartilhada (Blackboard):</p>
                <pre><code>contract CombatSystem:
  - signals: [health_changed(hp), died]
  - exports: [max_health: int = 100, defense: float = 0.2]
  - components: [HealthComponent, HitboxComponent]</code></pre>
              </div>

              <div v-if="activePersona === 'scene'" class="persona-stage">
                <div class="stage-tag">ETAPA 2: HIERARQUIA DE NÓS</div>
                <h4>Scene Builder Persona</h4>
                <p>Cria a estrutura de nós da cena <code>.tscn</code> sem risco de nós órfãos:</p>
                <pre><code>➔ add_node(".", "Area2D", "HitboxComponent")
➔ add_node("HitboxComponent", "CollisionShape2D", "CollisionShape")
➔ set_property("HitboxComponent", "collision_layer", 2)</code></pre>
              </div>

              <div v-if="activePersona === 'coder'" class="persona-stage">
                <div class="stage-tag">ETAPA 3: IMPLEMENTAÇÃO GDSCRIPT</div>
                <h4>Coder Persona</h4>
                <p>Escreve GDScript moderno com tipagem estática estrita e zero código morto:</p>
                <pre><code>func take_damage(amount: int) -> void:
    var final_dmg: int = int(amount * (1.0 - defense))
    current_health = max(0, current_health - final_dmg)
    health_changed.emit(current_health)</code></pre>
              </div>

              <div v-if="activePersona === 'qa'" class="persona-stage">
                <div class="stage-tag">ETAPA 4: TESTES & AUTO-CURA</div>
                <h4>QA Tester Persona (Auto-Healing)</h4>
                <div class="healing-chip">
                  <span class="dot-pulse green"></span> Auto-Healing: 100% dos testes aprovados
                </div>
                <pre><code>➔ Executando assert(current_health == 80) ... [PASS]
➔ Executando assert(health_changed emitido) ... [PASS]
➔ LSP Diagnostics: 0 Errors, 0 Warnings.</code></pre>
              </div>
            </div>
          </div>
        </div>

        <!-- 3. TAB: SHADER & SFX STUDIOS -->
        <div v-if="activeTab === 'studios'" class="panel-layout">
          <div class="panel-info">
            <div class="badge badge-cyan">CREATIVE SUITE NATIVA</div>
            <h3 class="panel-heading">Shader Studio & Sintetizador de SFX</h3>
            <p class="panel-body">
              Crie arte e áudio direto no Godot sem ferramentas externas. Ajuste parâmetros de shaders em tempo real e sintetize efeitos sonoros procedurais WAV com áudio instantâneo.
            </p>
            
            <div class="sfx-interactive-box">
              <span class="sfx-label">Teste os Sons Procedurais (Web Audio API):</span>
              <div class="sfx-buttons">
                <button class="sfx-btn" @click="playWebSound('coin')">🪙 Coin</button>
                <button class="sfx-btn" @click="playWebSound('jump')">🦘 Jump</button>
                <button class="sfx-btn" @click="playWebSound('laser')">🔫 Laser</button>
                <button class="sfx-btn" @click="playWebSound('explosion')">💥 Explosion</button>
              </div>
            </div>
          </div>

          <div class="panel-visual">
            <div class="shader-mockup-window">
              <div class="shader-header">
                <span class="sh-title">🎨 Shader Studio: Hit Flash & Dissolve</span>
                <span class="sh-badge">CanvasItem 2D</span>
              </div>
              <div class="shader-preview-screen" :style="{ filter: `brightness(${1 + uniformIntensity}) drop-shadow(0 0 ${uniformIntensity * 20}px rgba(0, 186, 227, 0.8))` }">
                <div class="game-character-sprite">👾</div>
                <div class="shader-mesh-glow"></div>
              </div>
              <div class="shader-controls">
                <label>Intensidade do Efeito (Uniform Flash):</label>
                <input type="range" min="0" max="1" step="0.05" v-model.number="uniformIntensity" class="slider-cyan" />
              </div>
            </div>
          </div>
        </div>

        <!-- 4. TAB: SAFE DIFF & WATCH MODE -->
        <div v-if="activeTab === 'safety'" class="panel-layout">
          <div class="panel-info">
            <div class="badge badge-amber">SEGURANÇA EM PRIMEIRO LUGAR</div>
            <h3 class="panel-heading">Revisão Visual Lado-a-Lado & Modo Vigiar</h3>
            <p class="panel-body">
              A IA nunca sobrescreve seu código às cegas. Revise cada linha em um visualizador de Diff integrado. E se o jogo falhar no Play, o <strong>Watch Mode</strong> captura os logs vermelhos do Output e propõe a correção automaticamente.
            </p>
            
            <div class="diff-actions">
              <button :class="['diff-btn apply', { applied: diffApplied }]" @click="diffApplied = true">
                {{ diffApplied ? '✓ Alteração Aplicada' : '✓ Aplicar Mudança' }}
              </button>
              <button class="diff-btn skip" @click="diffApplied = false">
                ✕ Rejeitar / Pular
              </button>
            </div>
          </div>

          <div class="panel-visual">
            <div class="diff-viewer-mock">
              <div class="diff-header">
                <span class="f-name">player_controller.gd</span>
                <span class="status-diff">{{ diffApplied ? 'APLICADO NO DISCO' : 'REVISÃO PENDENTE' }}</span>
              </div>
              <div class="diff-code-lines">
                <div class="d-line neutral"><span>32</span> func _jump() -> void:</div>
                <div class="d-line removed"><span>33</span> - &nbsp;&nbsp;velocity.y = -300.0 # Valor fixo antigo</div>
                <div class="d-line added"><span>33</span> + &nbsp;&nbsp;velocity.y = -jump_velocity * (1.2 if is_powerup else 1.0)</div>
                <div class="d-line added"><span>34</span> + &nbsp;&nbsp;jump_sound_player.play()</div>
                <div class="d-line neutral"><span>35</span> &nbsp;&nbsp;jump_count += 1</div>
              </div>
            </div>
          </div>
        </div>

      </div>

    </div>
  </section>
</template>

<style scoped>
.deep-showcase-section {
  padding: 80px 24px 100px;
  background: transparent;
  display: flex;
  justify-content: center;
  position: relative;
}

.showcase-container {
  width: 100%;
  max-width: 1180px;
  margin: 0 auto;
}

.showcase-header {
  text-align: center;
  margin-bottom: 40px;
}

.section-tag {
  display: inline-block;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #10b981;
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.25);
  padding: 6px 14px;
  border-radius: 999px;
  margin-bottom: 16px;
}

.section-title {
  font-size: 2.3rem;
  font-weight: 800;
  color: #ffffff;
  margin: 0 0 16px;
  letter-spacing: -0.02em;
  line-height: 1.25;
}

.section-subtitle {
  font-size: 1.1rem;
  color: var(--vp-c-text-2);
  max-width: 720px;
  margin: 0 auto;
  line-height: 1.6;
}

/* Tabs Nav */
.tabs-nav-wrapper {
  display: flex;
  justify-content: center;
  margin-bottom: 32px;
}

.tabs-nav {
  display: flex;
  gap: 12px;
  background: rgba(18, 20, 28, 0.75);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  padding: 8px;
  border-radius: 999px;
  flex-wrap: wrap;
  justify-content: center;
}

.tab-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: 999px;
  font-size: 0.9rem;
  font-weight: 700;
  color: #94a3b8;
  background: transparent;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab-btn:hover {
  color: #ffffff;
  background: rgba(255, 255, 255, 0.05);
}

.tab-btn.active {
  color: #ffffff;
  background: rgba(0, 186, 227, 0.2);
  border: 1px solid rgba(0, 186, 227, 0.4);
  box-shadow: 0 0 16px rgba(0, 186, 227, 0.25);
}

/* Tab Content Card */
.tab-content-card {
  background: radial-gradient(130% 130% at 50% 0%, rgba(28, 32, 44, 0.7) 0%, rgba(14, 16, 24, 0.85) 100%);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-top: 1px solid rgba(255, 255, 255, 0.18);
  border-radius: 28px;
  padding: 44px;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
  min-height: 400px;
}

.panel-layout {
  display: grid;
  grid-template-columns: 1fr 1.2fr;
  gap: 40px;
  align-items: center;
}

.panel-info {
  display: flex;
  flex-direction: column;
}

.panel-heading {
  font-size: 1.8rem;
  font-weight: 800;
  color: #ffffff;
  margin: 12px 0 16px;
  line-height: 1.3;
}

.panel-body {
  font-size: 1rem;
  color: var(--vp-c-text-2);
  line-height: 1.65;
  margin-bottom: 20px;
}

.feature-bullets {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
  font-size: 0.92rem;
  color: #cbd5e1;
}

/* Badges */
.badge {
  display: inline-block;
  align-self: flex-start;
  font-size: 0.72rem;
  font-weight: 800;
  letter-spacing: 0.06em;
  padding: 4px 12px;
  border-radius: 6px;
}

.badge-purple { background: rgba(168, 85, 247, 0.15); color: #c084fc; border: 1px solid rgba(168, 85, 247, 0.3); }
.badge-emerald { background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.3); }
.badge-cyan { background: rgba(0, 186, 227, 0.15); color: #38bdf8; border: 1px solid rgba(0, 186, 227, 0.3); }
.badge-amber { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3); }

/* Terminal Visual */
.terminal-mock {
  background: #0d1117;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

.term-bar {
  display: flex;
  align-items: center;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.03);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  gap: 8px;
}

.circle { width: 10px; height: 10px; border-radius: 50%; }
.circle.red { background: #ef4444; }
.circle.yellow { background: #f59e0b; }
.circle.green { background: #10b981; }

.term-title {
  font-size: 0.75rem;
  color: #64748b;
  margin-left: 8px;
  font-family: monospace;
}

.live-tag {
  margin-left: auto;
  font-size: 0.7rem;
  color: #10b981;
  font-weight: 700;
  display: flex;
  align-items: center;
  gap: 6px;
}

.term-code {
  padding: 20px;
  font-family: monospace;
  font-size: 0.82rem;
  line-height: 1.6;
  color: #e2e8f0;
}

.code-comment { color: #64748b; }
.c-key { color: #f43f5e; font-weight: bold; }
.c-prop { color: #38bdf8; }
.c-str { color: #a5f3fc; }
.c-val { color: #34d399; }
.c-num { color: #fbbf24; }
.code-res { color: #4ade80; display: block; margin-top: 12px; font-weight: bold; }

/* Persona Box */
.persona-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 16px;
}

.persona-btn {
  padding: 8px 14px;
  background: rgba(30, 41, 59, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  color: #cbd5e1;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.persona-btn.active {
  background: rgba(16, 185, 129, 0.2);
  border-color: rgba(16, 185, 129, 0.4);
  color: #6ee7b7;
}

.orchestrator-card-box {
  background: #0f172a;
  border: 1px solid rgba(16, 185, 129, 0.2);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

.persona-stage h4 {
  font-size: 1.2rem;
  font-weight: 700;
  color: #fff;
  margin: 6px 0 10px;
}

.stage-tag {
  font-size: 0.7rem;
  font-weight: 800;
  color: #34d399;
  letter-spacing: 0.05em;
}

.persona-stage pre {
  background: #090d16;
  border: 1px solid rgba(255, 255, 255, 0.06);
  padding: 14px;
  border-radius: 10px;
  font-size: 0.8rem;
  color: #a5f3fc;
  overflow-x: auto;
  margin-top: 12px;
}

.healing-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: rgba(16, 185, 129, 0.2);
  color: #34d399;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 700;
  margin-bottom: 8px;
}

/* SFX Buttons */
.sfx-interactive-box {
  margin-top: 16px;
}

.sfx-label {
  font-size: 0.82rem;
  color: #94a3b8;
  display: block;
  margin-bottom: 8px;
}

.sfx-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.sfx-btn {
  padding: 8px 14px;
  background: rgba(0, 186, 227, 0.15);
  border: 1px solid rgba(0, 186, 227, 0.3);
  border-radius: 8px;
  color: #38bdf8;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.sfx-btn:hover {
  background: rgba(0, 186, 227, 0.3);
  transform: scale(1.04);
}

.sfx-btn:active {
  transform: scale(0.96);
}

/* Shader Mockup */
.shader-mockup-window {
  background: #0f172a;
  border: 1px solid rgba(0, 186, 227, 0.25);
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

.shader-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.sh-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: #ffffff;
}

.sh-badge {
  font-size: 0.7rem;
  background: rgba(0, 186, 227, 0.2);
  color: #38bdf8;
  padding: 2px 8px;
  border-radius: 4px;
}

.shader-preview-screen {
  height: 140px;
  background: radial-gradient(circle at center, #1e293b 0%, #090d16 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 4rem;
  transition: filter 0.2s ease;
  position: relative;
  overflow: hidden;
}

.shader-controls {
  margin-top: 16px;
  font-size: 0.82rem;
  color: #94a3b8;
}

.slider-cyan {
  width: 100%;
  margin-top: 8px;
  accent-color: #00bae3;
  cursor: pointer;
}

/* Diff Viewer Mock */
.diff-viewer-mock {
  background: #0d1117;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.6);
}

.diff-header {
  display: flex;
  justify-content: space-between;
  padding: 10px 16px;
  background: rgba(255, 255, 255, 0.03);
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  font-size: 0.8rem;
  color: #94a3b8;
  font-family: monospace;
}

.status-diff {
  color: #10b981;
  font-weight: 700;
}

.diff-code-lines {
  padding: 14px;
  font-family: monospace;
  font-size: 0.8rem;
  line-height: 1.6;
}

.d-line {
  padding: 2px 6px;
  border-radius: 4px;
}

.d-line span { color: #64748b; margin-right: 8px; }
.d-line.neutral { color: #cbd5e1; }
.d-line.removed { background: rgba(239, 68, 68, 0.15); color: #f87171; }
.d-line.added { background: rgba(16, 185, 129, 0.15); color: #4ade80; }

.diff-actions {
  display: flex;
  gap: 12px;
  margin-top: 16px;
}

.diff-btn {
  padding: 10px 18px;
  border-radius: 8px;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
}

.diff-btn.apply {
  background: #10b981;
  color: #022c22;
}

.diff-btn.apply.applied {
  background: #059669;
  color: #ecfdf5;
}

.diff-btn.skip {
  background: rgba(255, 255, 255, 0.05);
  color: #94a3b8;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.showcase-reveal {
  opacity: 0;
  transform: translateY(24px);
  transition: all 0.7s cubic-bezier(0.16, 1, 0.3, 1);
}

.showcase-reveal.active-reveal {
  opacity: 1;
  transform: translateY(0);
}

@media (max-width: 960px) {
  .panel-layout {
    grid-template-columns: 1fr;
    gap: 30px;
  }
}
</style>
