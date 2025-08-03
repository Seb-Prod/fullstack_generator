#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
SERVER_DIR="$PROJECT_NAME/server"

# Afficher un titre formaté
echo -e "${GREEN} - Création du .env.example ${NC}"

# Le fichier
cat > "$SERVER_DIR/.env.example" << 'EOF'
# Configuration du serveur
PORT=5000
NODE_ENV=development
CLIENT_URL=http://localhost:3000

# Configuration de la base de données MySQL
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=mon_projet

# Autres variables (JWT, etc.)
# JWT_SECRET=your-secret-key
# JWT_EXPIRES_IN=7d
EOF
