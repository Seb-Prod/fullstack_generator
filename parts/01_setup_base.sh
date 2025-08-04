#!/bin/bash
set -e
# SCRIPT_DIR pointe vers l'emplacement des scripts dans le bundle
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

# Récupérer le nom du projet et le répertoire utilisateur (passés par main.sh)
PROJECT_NAME="$1"
USER_CWD="$2"

# Se déplacer dans le répertoire de l'utilisateur pour y créer le projet
cd "$USER_CWD"

# Création de la structure du projet
echo -e "${BLUE}${BOLD}📁 Création de la structure du projet"

# Création des dossiers
mkdir -p "$PROJECT_NAME"/{client/{src/{components,services},public},server/src/{routes,controllers,services}}

# Afficher le chemin complet du projet créé
echo -e "${GREEN}✅ Projet '$PROJECT_NAME' créé dans le répertoire : ${CYAN}$(pwd)/$PROJECT_NAME${NC}"

# Se déplacer dans le nouveau répertoire du projet pour les étapes suivantes
cd "$PROJECT_NAME"

# Initialisation de Git
echo -e "${BLUE}${BOLD}🔧 Initialisation de Git${NC}"
git init --quiet &>/dev/null

# Création des fichiers de base
echo -e "${BLUE}${BOLD}📜 Création des fichiers de base...${NC}"
# Les chemins des sous-scripts sont corrects car ils pointent
# vers SCRIPT_DIR, le bon emplacement dans le bundle de l'application
bash "$SCRIPT_DIR/01_base/create_package_json.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/01_base/create_gitignore.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/01_base/create_readme.sh" "$PROJECT_NAME"