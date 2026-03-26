<script setup>
import { ref, onMounted, computed } from 'vue'
import { useData } from 'vitepress'

const { frontmatter } = useData()

const showcaseData = computed(() => {
  return frontmatter.value.feature_showcase || []
})

const activeStep = ref(0)
onMounted(() => {
  // Terminal steps animation
  setInterval(() => {
    activeStep.value = (activeStep.value + 1) % 4
  }, 2000)

  // Scroll reveal observer
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active-reveal')
      }
    })
  }, { threshold: 0.1 })

  document.querySelectorAll('.reveal').forEach(el => observer.observe(el))
})
</script>

<template>
  <div v-if="showcaseData.length" class="feature-showcase">
    <div class="showcase-container">
      
      <!-- Seção 1: O Workflow Autônomo -->
      <section v-if="showcaseData[0]" class="showcase-section reveal">
        <div class="text-content">
          <span class="badge">{{ showcaseData[0].tag }}</span>
          <h2>{{ showcaseData[0].title }}</h2>
          <p>{{ showcaseData[0].description }}</p>
        </div>
        <div class="visual-content">
          <div class="terminal-window">
            <div class="terminal-header">
              <span class="dot red"></span>
              <span class="dot yellow"></span>
              <span class="dot green"></span>
              <span class="file-name">gamedev_ai_executor.gd</span>
            </div>
            <div class="terminal-body">
              <div v-for="(step, index) in showcaseData[0].steps" :key="index" 
                   :class="['step-line', { active: activeStep === index, completed: activeStep > index }]">
                <span class="arrow">></span> {{ step }}
                <span v-if="activeStep === index" class="cursor">_</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Seção 2: O Motor de Conhecimento -->
      <section v-if="showcaseData[1]" class="showcase-section reverse reveal">
        <div class="visual-content node-graph-container">
          <div class="node-graph">
            <div class="node central"></div>
            <div v-for="i in 6" :key="i" :class="'node orbit-' + i"></div>
            <div class="scanner-ring"></div>
          </div>
        </div>
        <div class="text-content">
          <span class="badge">{{ showcaseData[1].tag }}</span>
          <h2>{{ showcaseData[1].title }}</h2>
          <p>{{ showcaseData[1].description }}</p>
        </div>
      </section>

      <!-- Seção 3: Socratic Gate -->
      <section v-if="showcaseData[2]" class="showcase-section reveal">
        <div class="text-content">
          <span class="badge">{{ showcaseData[2].tag }}</span>
          <h2>{{ showcaseData[2].title }}</h2>
          <p>{{ showcaseData[2].description }}</p>
        </div>
        <div class="visual-content socratic-visual">
          <div class="question-panel">
            <div class="avatar">🤖</div>
            <div class="msg-bubble">
              "{{ showcaseData[2].question }}"
            </div>
            <div class="options">
              <div class="opt">{{ showcaseData[2].opt1 }}</div>
              <div class="opt">{{ showcaseData[2].opt2 }}</div>
            </div>
          </div>
        </div>
      </section>

    </div>
  </div>
</template>

<style scoped>
.feature-showcase {
  background-color: var(--vp-c-bg);
  padding: 100px 24px;
  overflow: hidden;
}

.showcase-container {
  max-width: 1152px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 160px;
}

.showcase-section {
  display: flex;
  align-items: center;
  gap: 60px;
}

.showcase-section.reverse {
  flex-direction: row-reverse;
}

.text-content {
  flex: 1;
}

.visual-content {
  flex: 1.2;
  display: flex;
  justify-content: center;
}

.badge {
  background: rgba(0, 186, 227, 0.1);
  color: #00bae3;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-bottom: 20px;
  display: inline-block;
}

h2 {
  font-size: 2.5rem;
  font-weight: 800;
  margin-bottom: 24px;
  line-height: 1.1;
  background: linear-gradient(to right, #fff, #888);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

p {
  font-size: 1.15rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
}

/* TERMINAL VISUAL */
.terminal-window {
  width: 100%;
  max-width: 500px;
  background: #1e1e1e;
  border-radius: 12px;
  box-shadow: 0 30px 60px rgba(0, 0, 0, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
  overflow: hidden;
}

.terminal-header {
  background: #333;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.dot { width: 10px; height: 10px; border-radius: 50%; }
.red { background: #ff5f56; }
.yellow { background: #ffbd2e; }
.green { background: #27c93f; }
.file-name { color: #888; font-size: 0.8rem; margin-left: 8px; font-family: monospace; }

.terminal-body {
  padding: 24px;
  font-family: 'Fira Code', monospace;
  font-size: 0.95rem;
  height: 200px;
}

.step-line {
  color: #666;
  margin-bottom: 12px;
  transition: all 0.3s;
}

.step-line.active { color: #00bae3; transform: translateX(5px); }
.step-line.completed { color: #27c93f; }
.arrow { opacity: 0.5; margin-right: 8px; }
.cursor { animation: blink 1s infinite; }

@keyframes blink { 50% { opacity: 0; } }

/* NODE GRAPH VISUAL */
.node-graph-container {
  height: 300px;
  position: relative;
}

.node-graph {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
}

.node {
  position: absolute;
  background: #00bae3;
  border-radius: 50%;
  box-shadow: 0 0 20px rgba(0, 186, 227, 0.5);
}

.node.central { width: 30px; height: 30px; z-index: 2; }

.node.orbit-1 { width: 12px; height: 12px; transform: translate(100px, -40px); animation: float 4s infinite ease-in-out; }
.node.orbit-2 { width: 15px; height: 15px; transform: translate(-80px, 60px); animation: float 5s infinite ease-in-out -1s; }
.node.orbit-3 { width: 10px; height: 10px; transform: translate(50px, 90px); animation: float 6s infinite ease-in-out -2s; }
.node.orbit-4 { width: 18px; height: 18px; transform: translate(-120px, -70px); animation: float 4.5s infinite ease-in-out -0.5s; }
.node.orbit-5 { width: 8px; height: 8px; transform: translate(140px, 40px); animation: float 7s infinite ease-in-out -1.5s; }
.node.orbit-6 { width: 22px; height: 22px; transform: translate(20px, -130px); animation: float 5.5s infinite ease-in-out -3s; }

.scanner-ring {
  border: 2px solid rgba(0, 186, 227, 0.2);
  border-radius: 50%;
  width: 400px;
  height: 400px;
  animation: scan 3s infinite linear;
}

@keyframes float { 0%, 100% { transform: translate(var(--x), var(--y)); } 50% { transform: translate(var(--x), calc(var(--y) - 20px)); } }
@keyframes scan { 0% { transform: scale(0.1); opacity: 1; } 100% { transform: scale(1.5); opacity: 0; } }

/* SOCRATIC VISUAL */
.question-panel {
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 32px;
  border-radius: 20px;
  max-width: 450px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
}

.avatar { font-size: 2rem; margin-bottom: 16px; }
.msg-bubble {
  background: rgba(0, 186, 227, 0.1);
  padding: 16px;
  border-radius: 12px;
  margin-bottom: 24px;
  font-style: italic;
  color: #00bae3;
}

.options { display: flex; flex-direction: column; gap: 12px; }
.opt {
  background: rgba(255, 255, 255, 0.05);
  padding: 12px 20px;
  border-radius: 10px;
  font-size: 0.9rem;
  border: 1px solid rgba(255, 255, 255, 0.1);
  cursor: pointer;
  transition: all 0.3s;
}

.opt:hover {
  background: rgba(0, 186, 227, 0.2);
  border-color: #00bae3;
  transform: translateX(5px);
}

@media (max-width: 768px) {
  .showcase-section, .showcase-section.reverse {
    flex-direction: column;
    text-align: center;
    gap: 40px;
  }
  h2 { font-size: 2rem; }
  .feature-showcase { padding: 60px 24px; }
}
</style>
