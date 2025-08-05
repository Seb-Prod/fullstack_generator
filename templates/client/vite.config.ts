import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: {{ FRONTEND_PORT }},
    host: true
  },
  css: {
    modules: {
      localsConvention: 'camelCase'
    }
  }
})
