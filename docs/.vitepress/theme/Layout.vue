<script setup>
import { useData } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import HeroSlider from './components/HeroSlider.vue'
import BentoFeaturesGrid from './components/BentoFeaturesGrid.vue'
import InteractiveShowcase from './components/InteractiveShowcase.vue'
import StatsBanner from './components/StatsBanner.vue'
import PremiumFooter from './components/PremiumFooter.vue'

const { Layout } = DefaultTheme
const { frontmatter, lang } = useData()
</script>

<template>
  <Layout :class="{ 'home-page': frontmatter.layout === 'home' }">
    <template #home-hero-before>
      <HeroSlider v-if="frontmatter.layout === 'home'" :key="lang" />
    </template>

    <template #home-features-after>
      <BentoFeaturesGrid v-if="frontmatter.layout === 'home'" :key="'bento-' + lang" />
      <InteractiveShowcase v-if="frontmatter.layout === 'home'" :key="'showcase-' + lang" />
      <StatsBanner v-if="frontmatter.layout === 'home'" :key="'stats-' + lang" />
    </template>

    <template #layout-bottom>
      <PremiumFooter v-if="frontmatter.layout === 'home'" :key="'footer-' + lang" />
    </template>
  </Layout>
</template>


<style>
/* Esconde o footer e features padrão do VitePress apenas na Home para dar lugar ao Premium */
.home-page .VPFooter, 
.home-page .VPFeatures {
  display: none !important;
}
</style>
