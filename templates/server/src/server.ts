import app from './app'
import dotenv from 'dotenv'

dotenv.config()

const PORT = process.env.PORT || {{ BACKEND_PORT }}

app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`)
  console.log(`📍 API disponible sur http://localhost:${PORT}/api`)
})
