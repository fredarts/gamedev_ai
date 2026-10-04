<script setup>
import { onMounted } from 'vue'

onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active-reveal')
      }
    })
  }, { threshold: 0.1 })

  document.querySelectorAll('.stats-reveal').forEach(el => observer.observe(el))
})
</script>

<template>
  <section class="stats-banner-section">
    <div class="stats-container stats-reveal">
      <div class="stat-item">
        <div class="stat-number glow-cyan">65+</div>
        <div class="stat-label">Ferramentas Agentics</div>
        <div class="stat-sub">Scripts, Nós, Masmorras, Shaders e SFX</div>
      </div>
      
      <div class="stat-divider"></div>

      <div class="stat-item">
        <div class="stat-number glow-purple">25</div>
        <div class="stat-label">Habilidades Especializadas</div>
        <div class="stat-sub">Arquitetura, Multiplayer e UI/UX</div>
      </div>

      <div class="stat-divider"></div>

      <div class="stat-item">
        <div class="stat-number glow-emerald">11</div>
        <div class="stat-label">Idiomas Suportados</div>
        <div class="stat-sub">Interface e documentação global</div>
      </div>

      <div class="stat-divider"></div>

      <div class="stat-item">
        <div class="stat-number glow-amber">100%</div>
        <div class="stat-label">Local e Privado</div>
        <div class="stat-sub">Roda com Ollama e LM Studio offline</div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.stats-banner-section {
  padding: 40px 24px 80px;
  display: flex;
  justify-content: center;
  position: relative;
}

.stats-container {
  width: 100%;
  max-width: 1180px;
  background: radial-gradient(120% 120% at 50% 0%, rgba(30, 35, 48, 0.6) 0%, rgba(14, 16, 24, 0.75) 100%);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-top: 1px solid rgba(255, 255, 255, 0.16);
  border-radius: 24px;
  padding: 36px 40px;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  align-items: center;
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.45);
}

.stat-item {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.stat-number {
  font-size: 2.8rem;
  font-weight: 800;
  line-height: 1;
  margin-bottom: 8px;
  letter-spacing: -0.03em;
}

.glow-cyan { color: #00bae3; text-shadow: 0 0 24px rgba(0, 186, 227, 0.35); }
.glow-purple { color: #c084fc; text-shadow: 0 0 24px rgba(192, 132, 252, 0.35); }
.glow-emerald { color: #34d399; text-shadow: 0 0 24px rgba(52, 211, 153, 0.35); }
.glow-amber { color: #fbbf24; text-shadow: 0 0 24px rgba(251, 191, 36, 0.35); }

.stat-label {
  font-size: 1rem;
  font-weight: 700;
  color: #ffffff;
  margin-bottom: 4px;
}

.stat-sub {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  line-height: 1.4;
}

.stat-divider {
  display: none;
}

.stats-reveal {
  opacity: 0;
  transform: translateY(20px);
  transition: all 0.7s cubic-bezier(0.16, 1, 0.3, 1);
}

.stats-reveal.active-reveal {
  opacity: 1;
  transform: translateY(0);
}

@media (max-width: 900px) {
  .stats-container {
    grid-template-columns: repeat(2, 1fr);
    gap: 32px;
  }
}

@media (max-width: 520px) {
  .stats-container {
    grid-template-columns: 1fr;
    padding: 30px 20px;
  }
}
</style>
