<template>
  <div id="app-root">
    <MealPlanner v-if="page === 'meal'" />
    <Converter   v-else-if="page === 'convert'" />
    <ShoppingList v-else-if="page === 'shop'" />
    <BottomNav v-model="page" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import BottomNav    from './components/BottomNav.vue'
import MealPlanner  from './pages/MealPlanner.vue'
import Converter    from './pages/Converter.vue'
import ShoppingList from './pages/ShoppingList.vue'

const page = ref('meal')
</script>

<style scoped>
#app-root {
  height: 100dvh;
  display: flex;
  flex-direction: column;
}
</style>
