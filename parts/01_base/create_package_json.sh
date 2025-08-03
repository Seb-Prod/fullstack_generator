#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"

# Afficher un titre formaté
echo -e "${GREEN} - Création du package.json ${NC}"

# Le fichier
cat > package.json << EOF
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "Projet fullstack TypeScript avec React et Express",
  "private": true,
  "scripts": {
    "dev": "concurrently \"npm run dev --prefix client\" \"npm run dev --prefix server\"",
    "install:all": "npm install --prefix client && npm install --prefix server",
    "build": "npm run build --prefix client && npm run build --prefix server",
    "clean": "rm -rf client/node_modules server/node_modules client/dist server/dist"
  },
  "devDependencies": {
    "concurrently": "^8.2.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF