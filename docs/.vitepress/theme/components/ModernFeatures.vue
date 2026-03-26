<script setup>
import { useData } from 'vitepress'
import { onMounted } from 'vue'

const { frontmatter } = useData()

onMounted(() => {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('active-reveal')
      }
    })
  }, { threshold: 0.1 })

  document.querySelectorAll('.modern-feature-card').forEach(el => observer.observe(el))
})
</script>

<template>
  <div class="modern-features-grid">
    <div class="modern-features-container">
      <div class="items">
        <div v-for="feature in frontmatter.features" :key="feature.title" class="modern-feature-card reveal">
          <div class="box">
            <div class="card-header">
              <span v-if="feature.tag" :class="['tag-badge', feature.tag.toLowerCase()]">
                {{ feature.tag }}
              </span>
            </div>
            <h3 class="title">{{ feature.title }}</h3>
            <p class="details">{{ feature.details }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.modern-features-grid {
  background: var(--vp-c-bg);
  padding: 0 24px 100px;
  width: 100%;
  display: flex;
  justify-content: center;
}

.modern-features-container {
  width: 100%;
  max-width: 1152px;
  margin: 0 auto;
}

.items {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.modern-feature-card {
  height: 100%;
}

.box {
  background: rgba(40, 40, 44, 0.4);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-top: 1px solid rgba(255, 255, 255, 0.12);
  padding: 32px;
  border-radius: 20px;
  height: 100%;
  transition: all 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.4);
}

.modern-feature-card:hover .box {
  transform: translateY(-8px) scale(1.02);
  background: rgba(50, 50, 55, 0.55);
  border-color: rgba(0, 186, 227, 0.3);
  box-shadow: 0 20px 48px rgba(0, 0, 0, 0.6), 0 0 32px rgba(0, 186, 227, 0.1);
}

.card-header {
  margin-bottom: 20px;
}

.tag-badge {
  font-size: 0.7rem;
  font-weight: 800;
  padding: 4px 10px;
  border-radius: 6px;
  letter-spacing: 0.05em;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.tag-badge.core { color: #00bae3; border-color: rgba(0, 186, 227, 0.3); background: rgba(0, 186, 227, 0.1); }
.tag-badge.safe { color: #10b981; border-color: rgba(16, 185, 129, 0.3); background: rgba(16, 185, 129, 0.1); }
.tag-badge.engine { color: #f59e0b; border-color: rgba(245, 158, 11, 0.3); background: rgba(245, 158, 11, 0.1); }
.tag-badge.smart { color: #f43f5e; border-color: rgba(244, 63, 94, 0.3); background: rgba(244, 63, 94, 0.1); }

.title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #fff;
  margin-bottom: 12px;
}

.details {
  font-size: 0.95rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
}

@media (max-width: 960px) {
  .items { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 640px) {
  .items { grid-template-columns: 1fr; }
}
</style>
