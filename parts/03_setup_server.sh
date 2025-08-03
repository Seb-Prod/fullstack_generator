#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Création de la structure du projet
echo -e "${BLUE}${BOLD}📜 Création des fichiers SERVER...${NC}"

# Création des fichiers CLIENT
bash "$SCRIPT_DIR/03_server/create_package_json.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_tsconfig_json.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_env_example.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_gitignore.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_server_ts.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_app_ts.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_index_ts.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_pingController_ts.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/03_server/create_database_ts.sh" "$PROJECT_NAME"
