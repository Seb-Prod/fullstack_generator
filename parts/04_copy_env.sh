#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Création de la structure du projet
echo -e "${BLUE}${BOLD}🔧 Copie des fichiers .env...${NC}"

# Copie des fichiers .env
cp "$PROJECT_NAME/client/.env.example" "$PROJECT_NAME/client/.env"
cp "$PROJECT_NAME/server/.env.example" "$PROJECT_NAME/server/.env"