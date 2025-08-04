#!/bin/bash
set -e
clear

# Obtenir le chemin absolu du répertoire où se trouvent les scripts.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Récupérer le répertoire de travail de l'utilisateur (passé par le lanceur).
USER_CWD="$1"

# IMPORTANT : Sauvegarder le répertoire initial AVANT de changer
INITIAL_DIR="$(pwd)"

# Chargement des couleurs
source "$SCRIPT_DIR/colors.sh"

# Bannière ASCII
echo -e "${BOLD} ${RED}"
cat << "EOF"
    ┏┓  ┓   ┏┓     ┓
    ┗┓┏┓┣┓━━┃┃┏┓┏┓┏┫
    ┗┛┗ ┗┛  ┣┛┛ ┗┛┗┻
EOF
echo -e "${NC}"

# Sous-titre
echo -e "${BLUE} ${BOLD}🚀 Script de création de projet Fullstack TypeScript${NC}"
echo -e "${BLUE} ${BOLD}   Seb-Prod 2025"
echo -e ""

# Afficher les informations AVANT de changer de répertoire
echo -e "${GREEN}Répertoire d'où l'app a été lancée : ${CYAN}$INITIAL_DIR${NC}"
echo -e "${GREEN}Répertoire de travail cible : ${CYAN}$USER_CWD${NC}"
echo -e "${GREEN}Répertoire des scripts : ${CYAN}$SCRIPT_DIR${NC}"

# ⭐ MODIFICATION IMPORTANTE : Se déplacer dans le répertoire de l'utilisateur.
# Toutes les commandes de création de fichiers seront exécutées ici.
cd "$USER_CWD"
echo -e "${GREEN}✅ Changement vers le répertoire cible effectué${NC}"
echo -e ""

# 0 - Demander le nom du projet
source "$SCRIPT_DIR/parts/00_ask_project_name.sh"

# Les scripts suivants s'exécutent dans le répertoire de l'utilisateur.
# On leur passe le nom du projet et le SCRIPT_DIR pour qu'ils puissent trouver
# leurs propres ressources à l'intérieur du bundle.

# 1 - Base du projet
bash "$SCRIPT_DIR/01_setup_base.sh" "$PROJECT_NAME" "$USER_CWD"

# 2 - Client React
bash "$SCRIPT_DIR/02_setup_client.sh" "$PROJECT_NAME" "$USER_CWD"

# 3 - Serveur Express
bash "$SCRIPT_DIR/03_setup_server.sh" "$PROJECT_NAME" "$USER_CWD"

# 4 - Copie des fichiers .env
bash "$SCRIPT_DIR/04_copy_env.sh" "$PROJECT_NAME" "$USER_CWD"

# 4.5 - Configuration des ports personnalisés
bash "$SCRIPT_DIR/04.5_configure_ports.sh" "$PROJECT_NAME" "$USER_CWD"

# 5 - Installation des dépendances
bash "$SCRIPT_DIR/05_install_deps.sh" "$PROJECT_NAME" "$USER_CWD"

# 6 - Gestion Prisma
bash "$SCRIPT_DIR/06_handle_prisma.sh" "$PROJECT_NAME" "$USER_CWD"

# 7 - Message final et choix de lancement
bash "$SCRIPT_DIR/07_done.sh" "$PROJECT_NAME" "$USER_CWD"