#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
CLIENT_DIR="$PROJECT_NAME/client"

# Afficher un titre formaté
echo -e "${GREEN} - Création du .env.example ${NC}"

# Le fichier
cat > "$CLIENT_DIR/.env.example" << 'EOF'
VITE_API_URL=http://localhost:8000/api
EOF