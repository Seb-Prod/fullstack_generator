#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Création de la structure du projet
echo -e "${BLUE}${BOLD}📜 Création des fichiers CLIENT...${NC}"

# Création des fichiers CLIENT
bash "$SCRIPT_DIR/02_client/create_package_json.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_vite_config_ts.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_tsconfig_json.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_index_html.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_env_example.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_gitignore.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_main_tsx.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_app_tsx.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_app_module_css.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_apiService_ts.sh" "$PROJECT_NAME"
bash "$SCRIPT_DIR/02_client/create_tsconfig_node_json.sh" "$PROJECT_NAME"
