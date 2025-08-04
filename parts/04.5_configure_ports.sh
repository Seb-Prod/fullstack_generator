#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"
FRONTEND_PORT="${FRONTEND_PORT:-3000}"
BACKEND_PORT="${BACKEND_PORT:-5000}"

echo -e "${BLUE} ${BOLD}🔧 Configuration des ports...${NC}"
cd "$PROJECT_NAME"

# Configuration du port frontend dans vite.config.ts
if [[ "$FRONTEND_PORT" != "3000" ]]; then
    echo -e " - Configuration du port frontend: $FRONTEND_PORT"
    sed -i.bak "s/port: 3000/port: $FRONTEND_PORT/g" client/vite.config.ts 2>/dev/null || true
    rm -f client/vite.config.ts.bak 2>/dev/null || true
fi

# Configuration du port backend dans le serveur
if [[ "$BACKEND_PORT" != "5000" ]]; then
    echo -e " - Configuration du port backend: $BACKEND_PORT"
    # Modifier le fichier server.ts
    sed -i.bak "s/PORT || 5000/PORT || $BACKEND_PORT/g" server/src/server.ts 2>/dev/null || true
    sed -i.bak "s/port 5000/port $BACKEND_PORT/g" server/src/server.ts 2>/dev/null || true
    rm -f server/src/server.ts.bak 2>/dev/null || true
    
    # Modifier le fichier .env.example du serveur
    sed -i.bak "s/PORT=5000/PORT=$BACKEND_PORT/g" server/.env.example 2>/dev/null || true
    rm -f server/.env.example.bak 2>/dev/null || true
fi

# Configuration de l'URL API dans le client
if [[ "$BACKEND_PORT" != "5000" ]]; then
    echo -e " - Configuration de l'URL API dans le client"
    sed -i.bak "s/localhost:5000/localhost:$BACKEND_PORT/g" client/src/services/apiService.ts 2>/dev/null || true
    sed -i.bak "s/localhost:5000/localhost:$BACKEND_PORT/g" client/.env.example 2>/dev/null || true
    rm -f client/src/services/apiService.ts.bak client/.env.example.bak 2>/dev/null || true
fi

# Mise à jour du package.json racine pour les scripts de développement
if [[ "$FRONTEND_PORT" != "3000" ]] || [[ "$BACKEND_PORT" != "5000" ]]; then
    echo -e " - Configuration des scripts de développement"
    # Ici vous pouvez ajouter d'autres configurations si nécessaire
fi

echo -e "${GREEN}✅ Configuration des ports terminée${NC}"