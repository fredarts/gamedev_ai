<script setup>
import { useData } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import HeroSlider from './components/HeroSlider.vue'
import FeatureShowcase from './components/FeatureShowcase.vue'
import PremiumFooter from './components/PremiumFooter.vue'
import FeaturesHeader from './components/FeaturesHeader.vue'
import ModernFeatures from './components/ModernFeatures.vue'

const { Layout } = DefaultTheme
const { frontmatter, lang } = useData()
</script>

<template>
  <Layout :class="{ 'home-page': frontmatter.layout === 'home' }">
    <template #home-hero-before>
      <HeroSlider v-if="frontmatter.layout === 'home'" :key="lang" />
    </template>

    <template #home-features-before>
      <FeaturesHeader v-if="frontmatter.layout === 'home'" :key="lang" />
    </template>

    <template #home-features-after>
      <ModernFeatures v-if="frontmatter.layout === 'home'" :key="lang" />
      <FeatureShowcase v-if="frontmatter.layout === 'home'" :key="lang" />
    </template>

    <template #layout-bottom>
      <PremiumFooter v-if="frontmatter.layout === 'home'" :key="lang" />
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
