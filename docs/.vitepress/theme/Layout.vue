<script setup>
import { useData } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import HeroSlider from './components/HeroSlider.vue'

const { Layout } = DefaultTheme
const { frontmatter } = useData()
</script>

<template>
  <Layout>
    <template #home-hero-before>
      <HeroSlider v-if="frontmatter.layout === 'home'" />
    </template>
  </Layout>
</template>
