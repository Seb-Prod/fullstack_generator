#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Création de la structure du projet
echo -e "${BLUE}${BOLD}📁 Création de la structure du projet"

# Création des dossiers
mkdir -p "$PROJECT_NAME"/{client/{src/{components,services},public},server/src/{routes,controllers,services}}
cd "$PROJECT_NAME"

# Initialisation de Git
echo -e "${BLUE}${BOLD}🔧 Initialisation de Git${NC}"
git init --quiet &>/dev/null

# Création des fichiers de base
echo -e "${BLUE}${BOLD}📜 Création des fichiers de base...${NC}"
bash "$SCRIPT_DIR/01_base/create_package_json.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/01_base/create_gitignore.sh"
bash "$SCRIPT_DIR/01_base/create_readme.sh" "$PROJECT_NAME"