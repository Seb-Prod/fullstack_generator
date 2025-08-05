#!/bin/bash

# Fonction pour afficher la bannière du script

show_banner() {
    echo -e "${BOLD}${RED}"
    cat << "EOF"
    ┏┓  ┓   ┏┓     ┓
    ┗┓┏┓┣┓━━┃┃┏┓┏┓┏┫
    ┗┛┗ ┗┛  ┣┛┛ ┗┛┗┻
EOF
    echo -e "${NC}"

    print_plain "$BLUE" "Générateur de projet Fullstack TypeScript (Seb-Prod 2025)"

    if [[ "$USER_CWD" != "$(pwd)" ]]; then
        print_plain "$BLUE" "Répertoire de travail : ${USER_CWD}"
    else
        print_plain "$BLUE" "Répertoire de travail : ${USER_CWD} (courant)"
    fi

    echo ""
}