<script setup>
import { useData } from 'vitepress'
import { onMounted } from 'vue'

const { frontmatter, lang } = useData()

onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active-reveal')
      }
    })
  }, { threshold: 0.1 })

  document.querySelectorAll('.bento-reveal').forEach(el => observer.observe(el))
})
</script>

<template>
  <section class="bento-section">
    <div class="bento-container">
      <div class="bento-header bento-reveal">
        <span class="section-tag">ARQUITETURA DE NOVA GERAÇÃO</span>
        <h2 class="section-title">Construído para dar Superpoderes ao Gamedev</h2>
        <p class="section-subtitle">
          Um ecossistema completo de inteligência artificial integrado diretamente no motor Godot 4.7+, sem intermediários na nuvem e com controle absoluto pelo desenvolvedor.
        </p>
      </div>

      <div class="bento-grid">
        
        <!-- CARD 1: Large Card - Chat & Scene Tree Integration -->
        <div class="bento-card card-span-2 bento-reveal glow-cyan">
          <div class="card-inner">
            <div class="card-badge-row">
              <span class="badge badge-cyan">CORE ECOSYSTEM</span>
              <span class="pill-status"><span class="dot-pulse green"></span> Godot 4.7+ Native</span>
            </div>
            
            <h3 class="card-title">Construção e Manipulação Direta via Chat</h3>
            <p class="card-desc">
              Arraste nós diretamente da <strong>Scene Tree</strong> ou arquivos do <strong>FileSystem</strong> para a conversa. A IA compreende o contexto hierárquico, instancia nós, ajusta propriedades e conecta sinais no seu projeto em tempo real.
            </p>

            <div class="mockup-chat-drag">
              <div class="mockup-tree">
                <div class="tree-header">Scene Tree</div>
                <div class="tree-node active">
                  <span class="node-icon">🎮</span> CharacterBody2D
                  <span class="drag-ghost-chip">Arrastando...</span>
                </div>
                <div class="tree-node child"><span class="node-icon">🖼️</span> Sprite2D</div>
                <div class="tree-node child"><span class="node-icon">📦</span> CollisionShape2D</div>
                <div class="tree-node child"><span class="node-icon">🎬</span> AnimationPlayer</div>
              </div>
              <div class="mockup-arrow">➔</div>
              <div class="mockup-chat-panel">
                <div class="chat-msg user">
                  <span class="chip-node">@CharacterBody2D</span> Crie uma máquina de estados com pulo duplo e aceleração suave.
                </div>
                <div class="chat-msg ai">
                  <span class="ai-badge">🤖 Gamedev AI</span>
                  <div class="code-snippet-preview">
                    <code>func _physics_process(delta: float) -> void:</code><br>
                    <span class="c-comment"># Aplicando patch cirúrgico via tool: patch_script</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- CARD 2: MCP Native Server -->
        <div class="bento-card bento-reveal glow-purple">
          <div class="card-inner">
            <div class="card-badge-row">
              <span class="badge badge-purple">MCP PROTOCOL</span>
              <span class="pill-status">Port :6543</span>
            </div>
            <h3 class="card-title">Servidor MCP Nativo & Stdio Bridge</h3>
            <p class="card-desc">
              Conecte <strong>Antigravity, Cursor ou Claude Desktop</strong> ao Godot com zero custo e 100% de privacidade local via Model Context Protocol.
            </p>
            <div class="mcp-network-box">
              <div class="ide-node">IDE Externa</div>
              <div class="connection-line">
                <span class="signal-dot"></span>
                <span class="line-label">JSON-RPC</span>
              </div>
              <div class="godot-node">Godot Editor</div>
            </div>
          </div>
        </div>

        <!-- CARD 3: 65 Agentic Tools -->
        <div class="bento-card bento-reveal glow-emerald">
          <div class="card-inner">
            <div class="card-badge-row">
              <span class="badge badge-emerald">AUTONOMIA TOTAL</span>
              <span class="counter-badge">65 Ferramentas</span>
            </div>
            <h3 class="card-title">65 Ferramentas Agentics</h3>
            <p class="card-desc">
              De geração de masmorras procedurais e autotiling até síntese de shaders e efeitos sonoros WAV em tempo real.
            </p>
            <div class="tags-cloud">
              <span class="tag-chip">Masmorras BSP</span>
              <span class="tag-chip">Autotile 47-tile</span>
              <span class="tag-chip">Sintetizador SFX</span>
              <span class="tag-chip">State Machines</span>
              <span class="tag-chip">Shaders GLSL</span>
              <span class="tag-chip">LSP Diagnostics</span>
            </div>
          </div>
        </div>

        <!-- CARD 4: Local Vector DB & RAG -->
        <div class="bento-card bento-reveal glow-amber">
          <div class="card-inner">
            <div class="card-badge-row">
              <span class="badge badge-amber">KNOWLEDGE ENGINE</span>
              <span class="pill-status">100% Offline</span>
            </div>
            <h3 class="card-title">Banco Vetorial & RAG</h3>
            <p class="card-desc">
              Seu codebase é indexado localmente em um Vector DB. A IA localiza classes customizadas, funções e Singletons sem alucinações.
            </p>
            <div class="radar-box">
              <div class="radar-circle"></div>
              <div class="radar-sweep"></div>
              <div class="radar-point p1"></div>
              <div class="radar-point p2"></div>
              <div class="radar-point p3"></div>
            </div>
          </div>
        </div>

        <!-- CARD 5: Git & GitHub Integration -->
        <div class="bento-card bento-reveal glow-blue">
          <div class="card-inner">
            <div class="card-badge-row">
              <span class="badge badge-blue">VERSION CONTROL</span>
              <span class="pill-status">Aba Nativa</span>
            </div>
            <h3 class="card-title">Git Integrado & Auto-Commit</h3>
            <p class="card-desc">
              Gerencie branches e envie commits padronizados gerados pela IA através da leitura inteligente do seu <code style="color: #60a5fa;">git diff</code>.
            </p>
            <div class="git-mini-mockup">
              <div class="branch-pill">🌿 branch: <span class="b-name">feature/inventory</span></div>
              <div class="commit-bubble">
                <span class="commit-prefix">feat(core):</span> add stackable item system with custom drag signals
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </section>
</template>

<style scoped>
.bento-section {
  padding: 80px 24px 60px;
  background: transparent;
  display: flex;
  justify-content: center;
  position: relative;
  overflow: hidden;
}

.bento-container {
  width: 100%;
  max-width: 1180px;
  margin: 0 auto;
}

.bento-header {
  text-align: center;
  margin-bottom: 54px;
}

.section-tag {
  display: inline-block;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #00bae3;
  background: rgba(0, 186, 227, 0.1);
  border: 1px solid rgba(0, 186, 227, 0.25);
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

/* Bento Grid */
.bento-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.card-span-2 {
  grid-column: span 2;
}

/* Bento Card - Glassmorphism */
.bento-card {
  position: relative;
  background: radial-gradient(140% 140% at 50% 0%, rgba(32, 36, 48, 0.6) 0%, rgba(16, 18, 26, 0.8) 100%);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border: 1px solid rgba(255, 255, 255, 0.07);
  border-top: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 24px;
  padding: 32px;
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.45);
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  overflow: hidden;
}

.bento-card:hover {
  transform: translateY(-6px);
  border-color: rgba(255, 255, 255, 0.2);
  box-shadow: 0 24px 56px rgba(0, 0, 0, 0.65);
}

.bento-card.glow-cyan:hover { border-color: rgba(0, 186, 227, 0.4); box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6), 0 0 30px rgba(0, 186, 227, 0.12); }
.bento-card.glow-purple:hover { border-color: rgba(168, 85, 247, 0.4); box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6), 0 0 30px rgba(168, 85, 247, 0.12); }
.bento-card.glow-emerald:hover { border-color: rgba(16, 185, 129, 0.4); box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6), 0 0 30px rgba(16, 185, 129, 0.12); }
.bento-card.glow-amber:hover { border-color: rgba(245, 158, 11, 0.4); box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6), 0 0 30px rgba(245, 158, 11, 0.12); }
.bento-card.glow-blue:hover { border-color: rgba(59, 130, 246, 0.4); box-shadow: 0 20px 50px rgba(0, 0, 0, 0.6), 0 0 30px rgba(59, 130, 246, 0.12); }

.card-inner {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.card-badge-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
}

.badge {
  font-size: 0.7rem;
  font-weight: 800;
  letter-spacing: 0.06em;
  padding: 4px 10px;
  border-radius: 6px;
}

.badge-cyan { background: rgba(0, 186, 227, 0.15); color: #00bae3; border: 1px solid rgba(0, 186, 227, 0.3); }
.badge-purple { background: rgba(168, 85, 247, 0.15); color: #c084fc; border: 1px solid rgba(168, 85, 247, 0.3); }
.badge-emerald { background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.3); }
.badge-amber { background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.3); }
.badge-blue { background: rgba(59, 130, 246, 0.15); color: #60a5fa; border: 1px solid rgba(59, 130, 246, 0.3); }

.pill-status, .counter-badge {
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
  display: flex;
  align-items: center;
  gap: 6px;
}

.counter-badge {
  font-weight: 700;
  color: #34d399;
}

.dot-pulse {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #10b981;
  box-shadow: 0 0 8px #10b981;
}

.card-title {
  font-size: 1.35rem;
  font-weight: 700;
  color: #ffffff;
  margin: 0 0 10px;
}

.card-desc {
  font-size: 0.95rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin-bottom: 22px;
}

/* Mockup Chat & Drag */
.mockup-chat-drag {
  display: flex;
  align-items: center;
  gap: 16px;
  background: rgba(10, 12, 18, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.06);
  border-radius: 14px;
  padding: 16px;
  margin-top: auto;
}

.mockup-tree {
  flex: 0 0 180px;
  font-size: 0.8rem;
  background: rgba(20, 24, 34, 0.8);
  border-radius: 8px;
  padding: 10px;
}

.tree-header {
  font-size: 0.7rem;
  color: #64748b;
  text-transform: uppercase;
  font-weight: 700;
  margin-bottom: 8px;
}

.tree-node {
  padding: 3px 6px;
  border-radius: 4px;
  color: #cbd5e1;
  display: flex;
  align-items: center;
  gap: 6px;
}

.tree-node.active {
  background: rgba(0, 186, 227, 0.2);
  color: #38bdf8;
  border: 1px dashed #00bae3;
  font-weight: 600;
}

.tree-node.child {
  padding-left: 16px;
  color: #94a3b8;
}

.drag-ghost-chip {
  font-size: 0.65rem;
  background: #0284c7;
  color: #fff;
  padding: 2px 6px;
  border-radius: 4px;
  margin-left: auto;
}

.mockup-arrow {
  color: #00bae3;
  font-weight: 800;
  font-size: 1.2rem;
  animation: pulseX 1.5s infinite;
}

@keyframes pulseX {
  0%, 100% { transform: translateX(0); }
  50% { transform: translateX(4px); }
}

.mockup-chat-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.chat-msg {
  padding: 8px 12px;
  border-radius: 8px;
  font-size: 0.82rem;
}

.chat-msg.user {
  background: rgba(30, 41, 59, 0.7);
  color: #e2e8f0;
}

.chip-node {
  background: rgba(0, 186, 227, 0.25);
  color: #38bdf8;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 600;
}

.chat-msg.ai {
  background: rgba(15, 23, 42, 0.9);
  border: 1px solid rgba(0, 186, 227, 0.2);
}

.ai-badge {
  font-size: 0.7rem;
  color: #38bdf8;
  font-weight: 700;
  display: block;
  margin-bottom: 4px;
}

.code-snippet-preview {
  font-family: monospace;
  font-size: 0.75rem;
  color: #a5f3fc;
}

.c-comment {
  color: #64748b;
}

/* MCP Box */
.mcp-network-box {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: rgba(15, 18, 28, 0.7);
  border: 1px solid rgba(168, 85, 247, 0.2);
  border-radius: 12px;
  padding: 16px;
  margin-top: auto;
}

.ide-node, .godot-node {
  padding: 8px 14px;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 700;
}

.ide-node { background: rgba(168, 85, 247, 0.2); color: #d8b4fe; border: 1px solid rgba(168, 85, 247, 0.4); }
.godot-node { background: rgba(0, 186, 227, 0.2); color: #38bdf8; border: 1px solid rgba(0, 186, 227, 0.4); }

.connection-line {
  position: relative;
  flex: 1;
  height: 2px;
  background: rgba(168, 85, 247, 0.3);
  margin: 0 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.signal-dot {
  position: absolute;
  width: 6px;
  height: 6px;
  background: #c084fc;
  border-radius: 50%;
  box-shadow: 0 0 8px #c084fc;
  animation: moveDot 2s infinite ease-in-out;
}

@keyframes moveDot {
  0% { left: 0%; }
  100% { left: 100%; }
}

.line-label {
  font-size: 0.65rem;
  color: #94a3b8;
  position: absolute;
  top: -16px;
}

/* Tags Cloud */
.tags-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: auto;
}

.tag-chip {
  font-size: 0.75rem;
  padding: 5px 10px;
  background: rgba(16, 185, 129, 0.1);
  color: #6ee7b7;
  border: 1px solid rgba(16, 185, 129, 0.25);
  border-radius: 8px;
}

/* Radar */
.radar-box {
  position: relative;
  height: 100px;
  background: rgba(15, 20, 30, 0.8);
  border: 1px solid rgba(245, 158, 11, 0.2);
  border-radius: 12px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: auto;
}

.radar-circle {
  width: 70px;
  height: 70px;
  border-radius: 50%;
  border: 1px dashed rgba(245, 158, 11, 0.35);
}

.radar-sweep {
  position: absolute;
  width: 100%;
  height: 100%;
  background: conic-gradient(from 0deg at 50% 50%, rgba(245, 158, 11, 0.3) 0deg, transparent 60deg);
  border-radius: 50%;
  animation: spinRadar 3s linear infinite;
}

@keyframes spinRadar {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.radar-point {
  position: absolute;
  width: 5px;
  height: 5px;
  background: #fbbf24;
  border-radius: 50%;
  box-shadow: 0 0 6px #fbbf24;
}

.radar-point.p1 { top: 30%; left: 40%; }
.radar-point.p2 { top: 60%; left: 65%; }
.radar-point.p3 { top: 45%; left: 70%; }

/* Git Mini */
.git-mini-mockup {
  background: rgba(15, 23, 42, 0.8);
  border: 1px solid rgba(59, 130, 246, 0.25);
  border-radius: 12px;
  padding: 12px;
  margin-top: auto;
}

.branch-pill {
  font-size: 0.75rem;
  color: #94a3b8;
  margin-bottom: 6px;
}

.b-name {
  color: #60a5fa;
  font-weight: 700;
}

.commit-bubble {
  font-size: 0.78rem;
  color: #cbd5e1;
  background: rgba(30, 41, 59, 0.6);
  padding: 6px 10px;
  border-radius: 6px;
}

.commit-prefix {
  color: #38bdf8;
  font-weight: 700;
}

/* Animations */
.bento-reveal {
  opacity: 0;
  transform: translateY(24px);
  transition: all 0.7s cubic-bezier(0.16, 1, 0.3, 1);
}

.bento-reveal.active-reveal {
  opacity: 1;
  transform: translateY(0);
}

@media (max-width: 960px) {
  .bento-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .card-span-2 {
    grid-column: span 2;
  }
}

@media (max-width: 680px) {
  .bento-grid {
    grid-template-columns: 1fr;
  }
  .card-span-2 {
    grid-column: span 1;
  }
  .mockup-chat-drag {
    flex-direction: column;
  }
}
</style>
