<script setup>
import { useData } from 'vitepress'
const { frontmatter } = useData()
</script>

<template>
  <div v-if="frontmatter.modern_header" class="features-header reveal">
    <div class="header-container">
      <h2 class="title">{{ frontmatter.modern_header.title }}</h2>
      <p class="description">{{ frontmatter.modern_header.description }}</p>
      <div class="divider"></div>
    </div>
  </div>
</template>

<style scoped>
.features-header {
  padding: 100px 24px 40px;
  text-align: center;
  background: var(--vp-c-bg);
}

.header-container {
  max-width: 900px;
  margin: 0 auto;
}

.title {
  font-size: 3.5rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  line-height: 1.1;
  background: linear-gradient(to bottom, #fff 30%, rgba(255, 255, 255, 0.4));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 24px;
}

.description {
  font-size: 1.25rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  max-width: 700px;
  margin: 0 auto 40px;
}

.divider {
  width: 60px;
  height: 4px;
  background: #00bae3;
  margin: 0 auto;
  border-radius: 2px;
  box-shadow: 0 0 15px rgba(0, 186, 227, 0.4);
}

@media (max-width: 768px) {
  .title { font-size: 2.5rem; }
  .description { font-size: 1.1rem; }
}
</style>
