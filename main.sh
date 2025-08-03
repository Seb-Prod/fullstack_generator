#!/bin/bash
set -e
clear

# Chargement des couleurs
source "$(dirname "$0")/colors.sh"

# Bannière ASCII
echo -e "${BOLD} ${RED}"
cat << "EOF"
    ┏┓  ┓   ┏┓     ┓
    ┗┓┏┓┣┓━━┃┃┏┓┏┓┏┫
    ┗┛┗ ┗┛  ┣┛┛ ┗┛┗┻
EOF
echo -e "${NC}"

# Souts-titre
echo -e "${BLUE} ${BOLD}🚀 Script de création de projet Fullstack TypeScript${NC}"
echo -e "${BLUE} ${BOLD}   Seb-Prod 2025"
echo -e ""          
# 0 - Demander le nom du projet
source "$(dirname "$0")/parts/00_ask_project_name.sh"

# 1 - Base du projet
bash "$(dirname "$0")/parts/01_setup_base.sh" "$PROJECT_NAME"

# 2 - Client React
bash "$(dirname "$0")/parts/02_setup_client.sh" "$PROJECT_NAME"

# 3 - Serveur Express
bash "$(dirname "$0")/parts/03_setup_server.sh" "$PROJECT_NAME"

# 4 - Copie des fichiers .env
bash "$(dirname "$0")/parts/04_copy_env.sh" "$PROJECT_NAME"

# 5 - Message final
bash "$(dirname "$0")/parts/05_done.sh" "$PROJECT_NAME"