<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { withBase, useData } from 'vitepress'

const { lang } = useData()

const isPt = computed(() => {
  return !lang.value || lang.value === 'pt-BR' || lang.value === 'pt' || lang.value === ''
})

const slides = [
  {
    image: withBase('/images/Banner_01.jpg'),
    tag: 'GODOT 4.7+ AUTONOMOUS AGENT',
    tagClass: 'cyan',
    title: 'Gamedev AI',
    subtitle: 'O Engenheiro de Software Autônomo para Godot',
    subtitleEn: 'The Autonomous Software Engineer for Godot Engine',
    desc: 'Escreva GDScript moderno, manipule nós na Scene Tree e automatize o desenvolvimento do seu jogo com IA integrada ao editor.',
    descEn: 'Write modern GDScript, manipulate scene tree nodes, and automate game development with integrated editor AI.',
    btnPrimaryText: 'Comece Agora',
    btnPrimaryTextEn: 'Get Started',
    btnPrimaryLink: '/getting-started/installation',
    btnSecondaryText: 'Ver no GitHub',
    btnSecondaryTextEn: 'View on GitHub',
    btnSecondaryLink: 'https://github.com/fredarts/gamedev_ai'
  },
  {
    image: withBase('/images/Banner_02.jpg'),
    tag: 'NOVO • MODEL CONTEXT PROTOCOL',
    tagClass: 'purple',
    title: 'Servidor MCP Nativo',
    titleEn: 'Native MCP Server',
    subtitle: 'Controle o Godot diretamente do Antigravity, Cursor e Claude',
    subtitleEn: 'Control Godot directly from Antigravity, Cursor & Claude',
    desc: 'Ponte local JSON-RPC (127.0.0.1:6543) com mais de 65 ferramentas agentics e inspeção da Scene Tree viva em tempo real.',
    descEn: 'Local JSON-RPC bridge (127.0.0.1:6543) with 65+ agentic tools and live scene tree inspection.',
    btnPrimaryText: 'Guia do MCP',
    btnPrimaryTextEn: 'MCP Guide',
    btnPrimaryLink: '/advanced/mcp-server',
    btnSecondaryText: 'Ver 65 Ferramentas',
    btnSecondaryTextEn: 'All 65 Tools',
    btnSecondaryLink: '/advanced/tools-reference'
  },
  {
    image: withBase('/images/Banner_03.jpg'),
    tag: 'ORQUESTRAÇÃO MULTI-AGENTE',
    tagClass: 'emerald',
    title: 'Pipeline de 4 Estágios & Auto-Cura',
    titleEn: '4-Stage Pipeline & Auto-Healing',
    subtitle: 'Architect ➔ Scene Builder ➔ Coder ➔ QA Tester',
    subtitleEn: 'Architect ➔ Scene Builder ➔ Coder ➔ QA Tester',
    desc: 'Especialistas dedicados trabalhando com memória compartilhada (Blackboard) e auto-correção de testes sem intervenção humana.',
    descEn: 'Dedicated specialist personas with shared memory (Blackboard) and autonomous error healing.',
    btnPrimaryText: 'Como Funciona',
    btnPrimaryTextEn: 'How it Works',
    btnPrimaryLink: '/core-features/agentes-inteligencia',
    btnSecondaryText: 'Comece Agora',
    btnSecondaryTextEn: 'Get Started',
    btnSecondaryLink: '/getting-started/installation'
  },
  {
    image: withBase('/images/Banner_04.jpg'),
    tag: 'CREATIVE SUITE NATIVA',
    tagClass: 'cyan',
    title: 'Shader Studio & Sintetizador SFX',
    titleEn: 'Shader Studio & SFX Synthesizer',
    subtitle: 'Visual e Áudio Procedural Integrados ao Editor',
    subtitleEn: 'Visual Shaders & Procedural Audio Built-in',
    desc: 'Edite shaders GLSL com preview 2D/3D ao vivo e sintetize efeitos sonoros retrô WAV diretamente na cena.',
    descEn: 'Edit GLSL shaders with live 2D/3D viewport previews and synthesize retro WAV audio effects.',
    btnPrimaryText: 'Guia de Interface',
    btnPrimaryTextEn: 'UI Guide',
    btnPrimaryLink: '/advanced/ui-guide',
    btnSecondaryText: 'Explorar Shaders',
    btnSecondaryTextEn: 'Explore Shaders',
    btnSecondaryLink: '/advanced/tools-reference'
  },
  {
    image: withBase('/images/Banner_05.jpg'),
    tag: 'WORLD BUILDING & MASMORRAS',
    tagClass: 'amber',
    title: 'Masmorras BSP & Autotiling',
    titleEn: 'BSP Dungeons & Autotiling',
    subtitle: 'Geração Procedural de Mapas e Terrenos 47-Tile',
    subtitleEn: 'Procedural Level Generation & 47-Tile Autotiles',
    desc: 'Gere masmorras inteiras, configure bitmasks de colisão e pinte matrizes 2D de TileMapLayer com comandos da IA.',
    descEn: 'Generate full dungeons, configure collision bitmasks, and paint TileMapLayer grids with AI.',
    btnPrimaryText: 'Ver 65 Ferramentas',
    btnPrimaryTextEn: 'All 65 Tools',
    btnPrimaryLink: '/advanced/tools-reference',
    btnSecondaryText: 'Comece Agora',
    btnSecondaryTextEn: 'Get Started',
    btnSecondaryLink: '/getting-started/installation'
  },
  {
    image: withBase('/images/Banner_06.jpg'),
    tag: 'SEGURANÇA & DEPURADOR',
    tagClass: 'blue',
    title: 'Diff Seguro & Watch Mode',
    titleEn: 'Safe Visual Diff & Watch Mode',
    subtitle: 'Revisão Lado-a-Lado e Auto-Fix de Falhas',
    subtitleEn: 'Side-by-Side Review & Crash Auto-Fixing',
    desc: 'Revise cada linha antes de aplicar com suporte a Undo/Redo e deixe a IA monitorar o Output console contra erros.',
    descEn: 'Preview every line before applying with Undo/Redo, and let AI monitor console crashes in real time.',
    btnPrimaryText: 'Diff Seguro',
    btnPrimaryTextEn: 'Safe Diff',
    btnPrimaryLink: '/core-features/diff-apply',
    btnSecondaryText: 'Modo Vigiar',
    btnSecondaryTextEn: 'Watch Mode',
    btnSecondaryLink: '/core-features/watch-mode'
  }
]

const currentIndex = ref(0)
const previousIndex = ref(-1)
let timer = null

function goToSlide(index) {
  if (index === currentIndex.value) return
  previousIndex.value = currentIndex.value
  currentIndex.value = index
  resetTimer()

  setTimeout(() => {
    previousIndex.value = -1
  }, 1200)
}

function nextSlide() {
  const next = (currentIndex.value + 1) % slides.length
  goToSlide(next)
}

function prevSlide() {
  const prev = (currentIndex.value - 1 + slides.length) % slides.length
  goToSlide(prev)
}

function resetTimer() {
  if (timer) clearInterval(timer)
  timer = setInterval(nextSlide, 7000)
}

onMounted(() => {
  resetTimer()

  setTimeout(() => {
    const hero = document.querySelector('.VPHero')
    const slider = document.querySelector('.hero-slider-wrapper')
    if (hero && slider) {
      hero.insertBefore(slider, hero.firstChild)
    }
  }, 50)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<template>
  <div class="hero-slider-wrapper">
    <!-- Background Slides with Ken Burns Effect -->
    <div class="slides-bg-container">
      <div 
        v-for="(slide, index) in slides" 
        :key="index"
        class="slide-bg"
        :class="{
          active: index === currentIndex,
          exiting: index === previousIndex
        }"
        :style="{ backgroundImage: `url(${slide.image})` }"
      ></div>
    </div>

    <!-- Dark Vignette Overlay -->
    <div class="slider-vignette"></div>

    <!-- Foreground Dynamic Content Overlay -->
    <div class="hero-content-container">
      
      <!-- Side Navigation Arrows -->
      <button class="nav-arrow prev" @click.stop="prevSlide" aria-label="Slide anterior" title="Slide anterior">
        ‹
      </button>
      <button class="nav-arrow next" @click.stop="nextSlide" aria-label="Próximo slide" title="Próximo slide">
        ›
      </button>

      <!-- Main Slide Text Card -->
      <div 
        v-for="(slide, index) in slides"
        :key="'content-' + index"
        class="slide-text-card"
        :class="{ active: index === currentIndex }"
      >
        <div v-if="index === currentIndex" class="content-inner">
          
          <!-- High-Contrast Badge -->
          <div :class="['slide-tag', 'tag-' + slide.tagClass]">
            <span class="tag-sparkle">✦</span>
            <span class="tag-text">{{ slide.tag }}</span>
          </div>

          <h1 class="slide-main-title">
            {{ isPt ? slide.title : (slide.titleEn || slide.title) }}
          </h1>

          <p class="slide-subtitle">
            {{ isPt ? slide.subtitle : (slide.subtitleEn || slide.subtitle) }}
          </p>

          <p class="slide-desc">
            {{ isPt ? slide.desc : (slide.descEn || slide.desc) }}
          </p>

          <div class="slide-action-row">
            <a :href="withBase(slide.btnPrimaryLink)" class="btn-hero primary">
              {{ isPt ? slide.btnPrimaryText : (slide.btnPrimaryTextEn || slide.btnPrimaryText) }} ➔
            </a>
            <a :href="slide.btnSecondaryLink.startsWith('http') ? slide.btnSecondaryLink : withBase(slide.btnSecondaryLink)" 
               :target="slide.btnSecondaryLink.startsWith('http') ? '_blank' : '_self'" 
               class="btn-hero secondary">
              {{ isPt ? slide.btnSecondaryText : (slide.btnSecondaryTextEn || slide.btnSecondaryText) }}
            </a>
          </div>

        </div>
      </div>

      <!-- Prominent Clickable Pagination Dots ("Bolinhas") -->
      <div class="pagination-bar">
        <button
          v-for="(slide, idx) in slides"
          :key="'dot-' + idx"
          :class="['dot-btn', { active: idx === currentIndex }]"
          :title="isPt ? slide.title : (slide.titleEn || slide.title)"
          @click.stop="goToSlide(idx)"
          :aria-label="`Ir para banner ${idx + 1}`"
        >
          <span class="dot-number">{{ idx + 1 }}</span>
          <span v-if="idx === currentIndex" class="dot-progress-bar"></span>
        </button>
      </div>

    </div>
  </div>
</template>

<style scoped>
.hero-slider-wrapper {
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100%;
  min-height: calc(100vh - 64px);
  max-height: 900px;
  z-index: 5;
  overflow: hidden;
  pointer-events: auto;
}

:global(.VPHero .hero-slider-wrapper) {
  inset: 0 !important;
  width: 100% !important;
  height: 100% !important;
}

/* Hide default VitePress Hero text to avoid duplication with dynamic slider */
:global(.home-page .VPHero .main) {
  opacity: 0 !important;
  pointer-events: none !important;
  height: 0 !important;
  overflow: hidden !important;
}

:global(.home-page .VPHero .image) {
  display: none !important;
}

.slides-bg-container {
  position: absolute;
  inset: 0;
  z-index: 0;
}

.slide-bg {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center;
  opacity: 0;
  transform: scale(1.0);
}

.slide-bg.active {
  opacity: 0.75;
  animation: kenBurnsEnter 7s ease-out forwards;
}

.slide-bg.exiting {
  animation: kenBurnsExit 1.2s ease-in-out forwards;
}

@keyframes kenBurnsEnter {
  0%   { opacity: 0;   transform: scale(1.00); }
  15%  { opacity: 0.75; }
  100% { opacity: 0.75; transform: scale(1.08); }
}

@keyframes kenBurnsExit {
  0%   { opacity: 0.75; transform: scale(1.08); }
  100% { opacity: 0;   transform: scale(1.10); }
}

/* Vignette */
.slider-vignette {
  position: absolute;
  inset: 0;
  background: 
    radial-gradient(ellipse at center, transparent 30%, rgba(10, 12, 18, 0.5) 70%, rgba(10, 12, 18, 0.9) 100%),
    linear-gradient(to bottom, transparent 60%, rgba(14, 16, 24, 0.95) 94%, #161618 100%);
  z-index: 1;
  pointer-events: none;
}

/* Content Container */
.hero-content-container {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 1200px;
  height: 100%;
  min-height: calc(100vh - 64px);
  max-height: 900px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding: 40px 60px 80px;
  text-align: center;
  pointer-events: auto;
}

.slide-text-card {
  width: 100%;
  max-width: 880px;
  display: flex;
  justify-content: center;
  pointer-events: auto;
}

.content-inner {
  animation: slideFadeIn 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  display: flex;
  flex-direction: column;
  align-items: center;
}

@keyframes slideFadeIn {
  0% {
    opacity: 0;
    transform: translateY(20px) scale(0.98);
  }
  100% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* ==========================================================
   HIGH-CONTRAST BADGES
   ========================================================== */
.slide-tag {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  font-weight: 900;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  padding: 8px 20px;
  border-radius: 999px;
  margin-bottom: 22px;
  background: rgba(0, 0, 0, 0.92) !important;
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.8);
}

.tag-sparkle {
  font-size: 1rem;
}

.tag-cyan {
  color: #38bdf8 !important;
  border: 2px solid #00bae3 !important;
  box-shadow: 0 0 20px rgba(0, 186, 227, 0.4), 0 8px 30px rgba(0, 0, 0, 0.8);
}

.tag-purple {
  color: #f0abfc !important;
  border: 2px solid #c084fc !important;
  box-shadow: 0 0 20px rgba(192, 132, 252, 0.4), 0 8px 30px rgba(0, 0, 0, 0.8);
}

.tag-emerald {
  color: #4ade80 !important;
  border: 2px solid #10b981 !important;
  box-shadow: 0 0 20px rgba(16, 185, 129, 0.4), 0 8px 30px rgba(0, 0, 0, 0.8);
}

.tag-amber {
  color: #fde047 !important;
  border: 2px solid #f59e0b !important;
  box-shadow: 0 0 20px rgba(245, 158, 11, 0.4), 0 8px 30px rgba(0, 0, 0, 0.8);
}

.tag-blue {
  color: #93c5fd !important;
  border: 2px solid #3b82f6 !important;
  box-shadow: 0 0 20px rgba(59, 130, 246, 0.4), 0 8px 30px rgba(0, 0, 0, 0.8);
}

.slide-main-title {
  font-size: 3.6rem;
  font-weight: 900;
  color: #ffffff;
  margin: 0 0 16px;
  letter-spacing: -0.03em;
  line-height: 1.15;
  text-shadow: 0 4px 28px rgba(0, 0, 0, 0.9), 0 0 32px rgba(0, 186, 227, 0.35);
}

.slide-subtitle {
  font-size: 1.4rem;
  font-weight: 700;
  color: #f1f5f9;
  margin: 0 0 16px;
  line-height: 1.4;
  text-shadow: 0 2px 16px rgba(0, 0, 0, 0.85);
}

.slide-desc {
  font-size: 1.08rem;
  color: rgba(255, 255, 255, 0.9);
  max-width: 700px;
  margin: 0 0 32px;
  line-height: 1.6;
  text-shadow: 0 2px 12px rgba(0, 0, 0, 0.9);
}

.slide-action-row {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
  justify-content: center;
  pointer-events: auto;
}

.btn-hero {
  padding: 14px 30px;
  border-radius: 999px;
  font-size: 0.95rem;
  font-weight: 800;
  text-decoration: none;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
  cursor: pointer;
  pointer-events: auto;
}

.btn-hero.primary {
  background: #00bae3;
  color: #02202c;
  box-shadow: 0 8px 24px rgba(0, 186, 227, 0.5);
}

.btn-hero.primary:hover {
  background: #38bdf8;
  transform: translateY(-3px) scale(1.04);
  box-shadow: 0 14px 36px rgba(0, 186, 227, 0.7);
}

.btn-hero.secondary {
  background: rgba(20, 25, 38, 0.85);
  backdrop-filter: blur(16px);
  color: #ffffff;
  border: 1.5px solid rgba(255, 255, 255, 0.2);
}

.btn-hero.secondary:hover {
  background: rgba(40, 48, 68, 0.95);
  border-color: rgba(255, 255, 255, 0.4);
  transform: translateY(-3px);
}

/* ==========================================================
   PROMINENT NAVIGATION ARROWS
   ========================================================== */
.nav-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: rgba(10, 14, 22, 0.85);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 2px solid rgba(255, 255, 255, 0.25);
  color: #ffffff;
  font-size: 2.2rem;
  font-weight: 300;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  z-index: 50;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.7);
  pointer-events: auto;
}

.nav-arrow:hover {
  background: #00bae3;
  color: #02202c;
  border-color: #00bae3;
  transform: translateY(-50%) scale(1.15);
  box-shadow: 0 0 30px rgba(0, 186, 227, 0.8);
}

.nav-arrow.prev { left: 24px; }
.nav-arrow.next { right: 24px; }

/* ==========================================================
   CLICKABLE PAGINATION DOTS ("BOLINHAS")
   ========================================================== */
.pagination-bar {
  position: absolute;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 12px;
  z-index: 50;
  background: rgba(8, 10, 16, 0.9);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  padding: 10px 22px;
  border-radius: 999px;
  border: 1.5px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 10px 36px rgba(0, 0, 0, 0.8), 0 0 20px rgba(0, 186, 227, 0.25);
  pointer-events: auto;
}

.dot-btn {
  position: relative;
  width: 14px;
  height: 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.4);
  cursor: pointer;
  padding: 0;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}

.dot-number {
  display: none;
  font-size: 0.7rem;
  font-weight: 800;
  color: #02202c;
  z-index: 2;
}

.dot-btn:hover {
  background: #ffffff;
  transform: scale(1.25);
  box-shadow: 0 0 12px #ffffff;
}

.dot-btn.active {
  width: 44px;
  background: rgba(0, 186, 227, 0.4);
  border: 1.5px solid #00bae3;
  box-shadow: 0 0 16px rgba(0, 186, 227, 0.6);
}

.dot-btn.active .dot-number {
  display: block;
}

.dot-progress-bar {
  position: absolute;
  top: 0;
  left: 0;
  height: 100%;
  width: 100%;
  background: #00bae3;
  animation: fillProgress 7s linear forwards;
}

@keyframes fillProgress {
  0% { width: 0%; }
  100% { width: 100%; }
}

@media (max-width: 768px) {
  .hero-content-container {
    padding: 30px 20px 70px;
  }
  .slide-main-title {
    font-size: 2.2rem;
  }
  .slide-subtitle {
    font-size: 1.1rem;
  }
  .slide-desc {
    font-size: 0.92rem;
  }
  .nav-arrow {
    display: none;
  }
  .pagination-bar {
    bottom: 16px;
    padding: 8px 16px;
    gap: 8px;
  }
}
</style>
