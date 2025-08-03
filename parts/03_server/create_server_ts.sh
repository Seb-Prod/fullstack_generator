#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
SERVER_DIR="$PROJECT_NAME/server"

# Afficher un titre formaté
echo -e "${GREEN} - Création du src/server.ts ${NC}"

# Le fichier
cat > "$SERVER_DIR/src/server.ts" << 'EOF'
import app from './app'
import dotenv from 'dotenv'

dotenv.config()

const PORT = process.env.PORT || 5000

app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur le port ${PORT}`)
  console.log(`📍 API disponible sur http://localhost:${PORT}/api`)
})
EOF