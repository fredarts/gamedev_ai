<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { withBase } from 'vitepress'

const images = [
  withBase('/images/Banner_01.jpg'),
  withBase('/images/Banner_02.jpg'),
  withBase('/images/Banner_03.jpg'),
  withBase('/images/Banner_04.jpg'),
  withBase('/images/Banner_05.jpg'),
  withBase('/images/Banner_06.jpg')
]

const currentIndex = ref(0)
let timer

onMounted(() => {
  timer = setInterval(() => {
    currentIndex.value = (currentIndex.value + 1) % images.length
  }, 6000)

  // Mover elemento para dentro de .VPHero para ancoragem perfeita
  setTimeout(() => {
    const hero = document.querySelector('.VPHero')
    const slider = document.querySelector('.hero-slider-wrapper')
    if (hero && slider) {
      hero.insertBefore(slider, hero.firstChild)
    }
  }, 50)
})

onUnmounted(() => {
  clearInterval(timer)
})
</script>

<template>
  <div class="hero-slider-wrapper">
    <div 
      v-for="(img, index) in images" 
      :key="index"
      class="slide"
      :class="{ active: index === currentIndex }"
      :style="{ backgroundImage: `url(${img})` }"
    ></div>
  </div>
</template>

<style scoped>
.hero-slider-wrapper {
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 1072px;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
}

:global(.VPHero .hero-slider-wrapper) {
  inset: 0 !important;
  width: 100% !important;
  height: 100% !important;
}

.slide {
  position: absolute;
  inset: 0;
  background-size: cover;
  background-position: center;
  opacity: 0;
  transition: opacity 1.5s ease-in-out;
  transform: scale(1.0);
}

.slide.active {
  opacity: 0.7; /* Mantém contraste em relação a máscara shadow do banner */
  animation: kenBurns 12s ease-out forwards;
}

@keyframes kenBurns {
  0% { transform: scale(1.0); }
  100% { transform: scale(1.1); }
}
</style>
