import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'
import './styles/tokens.css'

const app = createApp(App)
const pinia = createPinia()
app.use(pinia)

import { useSessionStore } from './stores/session'
const session = useSessionStore()
session.init()

app.use(router)
app.mount('#app')
