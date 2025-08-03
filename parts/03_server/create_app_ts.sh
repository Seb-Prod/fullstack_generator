#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
SERVER_DIR="$PROJECT_NAME/server"

# Afficher un titre formaté
echo -e "${GREEN} - Création du src/app.ts ${NC}"

# Le fichier
cat > "$SERVER_DIR/src/app.ts" << 'EOF'
import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import routes from './routes'

dotenv.config()

const app = express()

// Middlewares
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true
}))

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Routes
app.use('/api', routes)

// Route de base
app.get('/', (req, res) => {
  res.json({ 
    message: 'API Backend démarrée avec succès !',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  })
})

// Gestion des erreurs 404
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route non trouvée',
    path: req.originalUrl
  })
})

// Gestion globale des erreurs
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Erreur globale:', err)
  res.status(500).json({
    error: 'Erreur interne du serveur',
    message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  })
})

export default app
EOF