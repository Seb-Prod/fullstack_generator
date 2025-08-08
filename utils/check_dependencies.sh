#!/bin/bash
# =============================================================================
# VÉRIFICATION DES DÉPENDANCES
# =============================================================================
check_dependencies() {
    local missing_tools=()

    # Vérifie Node.js
    if ! command -v node >/dev/null 2>&1; then
        missing_tools+=("Node.js (https://nodejs.org/)")
    else
        node_major_version=$(node -v | sed -E 's/^v([0-9]+).*/\1/')
        if ((node_major_version < 18)); then
            echo -e "\033[0;31m❌ Node.js doit être en version 18 ou supérieure (actuel : $(node -v))\033[0m"
            exit 1
        fi
    fi

    # Vérifie npm
    if ! command -v npm >/dev/null 2>&1; then
        missing_tools+=("npm (installé avec Node.js)")
    fi

    # Vérifie Git
    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("Git (https://git-scm.com/)")
    fi

    # Vérifie Bash
    if [[ -z "$BASH_VERSION" ]]; then
        missing_tools+=("Bash (https://www.gnu.org/software/bash/)")
    fi

    # Si un outil est manquant
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "\033[0;31m❌ Les outils suivants sont manquants :\033[0m"
        for tool in "${missing_tools[@]}"; do
            echo "   - $tool"
        done
        echo -e "\nVeuillez les installer avant de relancer le script."
        exit 1
    fi
}
