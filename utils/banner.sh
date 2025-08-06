#!/bin/bash
# =============================================================================
# Utilitaire d'affichage - Bannière du générateur de projet
# Seb-Prod 2025
# 
# Description:
#   Affiche la bannière ASCII art et les informations contextuelles du projet
#   Dépend de print_utils.sh pour les fonctions de couleur et d'affichage
# 
# Fonctions:
#   show_banner() - Affiche la bannière complète avec informations contextuelles
# 
# Variables requises:
#   USER_CWD    - Répertoire de travail utilisateur (défini par validate_args.sh)
#   BOLD, RED, NC, BLUE - Variables de couleur (définies par print_utils.sh)
# 
# Dépendances:
#   - print_utils.sh (pour les couleurs et print_plain)
# =============================================================================

# =============================================================================
# FONCTION PRINCIPALE - AFFICHAGE BANNIÈRE
# Affiche la bannière ASCII art et les informations contextuelles
# 
# Globals:
#   USER_CWD - Répertoire de travail utilisateur
#   BOLD, RED, NC, BLUE - Variables de couleur
# 
# Arguments:
#   Aucun
# 
# Returns:
#   0 si succès
# 
# Examples:
#   show_banner
# =============================================================================

show_banner() {
    # Vérification des dépendances critiques
    if [[ -z "${BOLD:-}" || -z "${RED:-}" || -z "${NC:-}" || -z "${BLUE:-}" ]]; then
        echo "⚠️  Variables de couleur non définies - print_utils.sh requis" >&2
        return 1
    fi
    
    if ! command -v print_plain &> /dev/null; then
        echo "⚠️  Fonction print_plain non trouvée - print_utils.sh requis" >&2
        return 1
    fi
    
    # Affichage de la bannière ASCII art
    echo -e "${BOLD}${RED}"
    cat << "EOF"
    ┏┓  ┓   ┏┓     ┓
    ┗┓┏┓┣┓━━┃┃┏┓┏┓┏┫
    ┗┛┗ ┗┛  ┣┛┛ ┗┛┗┻
EOF
    echo -e "${NC}"

    # Informations du projet
    print_plain "$BLUE" "Générateur de projet Fullstack TypeScript (Seb-Prod 2025)"
    
    # Affichage du répertoire de travail avec contexte
    local current_dir
    current_dir="$(pwd)"
    
    if [[ -n "${USER_CWD:-}" ]]; then
        if [[ "$USER_CWD" != "$current_dir" ]]; then
            print_plain "$BLUE" "Répertoire de travail : ${USER_CWD}"
        else
            print_plain "$BLUE" "Répertoire de travail : ${USER_CWD} (courant)"
        fi
    else
        print_plain "$BLUE" "Répertoire de travail : ${current_dir} (par défaut)"
    fi

    echo ""
}

# =============================================================================
# FONCTION UTILITAIRE - BANNIÈRE SIMPLE
# Version simplifiée sans dépendances pour les cas d'urgence
# 
# Arguments:
#   Aucun
# 
# Returns:
#   0 toujours
# =============================================================================

show_banner_fallback() {
    echo "======================================"
    echo "  Seb-Prod - Générateur Fullstack TS"
    echo "======================================"
    echo "Répertoire: ${USER_CWD:-$(pwd)}"
    echo ""
}

# =============================================================================
# FONCTION WRAPPER - AFFICHAGE SÉCURISÉ
# Utilise la bannière principale ou fallback selon les dépendances
# 
# Arguments:
#   Aucun
# 
# Returns:
#   0 toujours
# =============================================================================

display_banner() {
    if show_banner 2>/dev/null; then
        return 0
    else
        echo "⚠️  Affichage bannière simple (dépendances manquantes)" >&2
        show_banner_fallback
        return 0
    fi
}