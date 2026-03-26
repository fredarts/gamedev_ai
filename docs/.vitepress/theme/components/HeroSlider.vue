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
const previousIndex = ref(-1)
let timer

function advance() {
  previousIndex.value = currentIndex.value
  currentIndex.value = (currentIndex.value + 1) % images.length

  // Limpa o "exiting" após a animação de saída terminar (1.5s = duração do fade)
  setTimeout(() => {
    previousIndex.value = -1
  }, 1500)
}

onMounted(() => {
  timer = setInterval(advance, 6000)

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
      :class="{
        active: index === currentIndex,
        exiting: index === previousIndex
      }"
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
  transform: scale(1.0);
  /* Sem transition aqui — tudo é controlado por @keyframes para evitar snap */
}

/* Slide entrando: zoom lento por toda a duração do intervalo */
.slide.active {
  opacity: 0.7;
  animation: kenBurnsEnter 6s ease-out forwards;
}

/* Slide saindo: continua o zoom E faz fade out juntos, SEM voltar ao tamanho original */
.slide.exiting {
  animation: kenBurnsExit 1.5s ease-in-out forwards;
}

@keyframes kenBurnsEnter {
  0%   { opacity: 0;   transform: scale(1.00); }
  15%  { opacity: 0.7; }
  100% { opacity: 0.7; transform: scale(1.10); }
}

@keyframes kenBurnsExit {
  /* Começa do fim exato da animação de enter para evitar snap */
  0%   { opacity: 0.7; transform: scale(1.10); }
  100% { opacity: 0;   transform: scale(1.125); }
}
</style>
