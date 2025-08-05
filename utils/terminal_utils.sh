#!/bin/bash

# ========================================
# UTILITAIRES TERMINAL
# ========================================

# Fonction pour effacer les lignes précédentes
clear_lines() {
    local lines="$1"
    local time="${2:-0}"
    sleep "$time"
    for ((i=0; i<lines; i++)); do
        echo -ne "\033[1A\033[2K"  # Remonter d'une ligne et l'effacer
    done
}

# Fonction pour effacer l'écran et repositionner le curseur
clear_screen() {
    echo -ne "\033[2J\033[H"
}

# Fonction pour sauvegarder la position du curseur
save_cursor() {
    echo -ne "\033[s"
}

# Fonction pour restaurer la position du curseur
restore_cursor() {
    echo -ne "\033[u"
}

# Fonction pour masquer le curseur
hide_cursor() {
    echo -ne "\033[?25l"
}

# Fonction pour afficher le curseur
show_cursor() {
    echo -ne "\033[?25h"
}

# Fonction pour déplacer le curseur à une position spécifique
move_cursor() {
    local row="$1"
    local col="$2"
    echo -ne "\033[${row};${col}H"
}

replace_line_above() {
    local lines_up="$1"
    local new_text="$2"

    save_cursor
    # Remonter d'un nombre de lignes spécifié
    for ((i=0; i<lines_up; i++)); do
        echo -ne "\033[1A"
    done
    # Effacer la ligne entière à la nouvelle position
    echo -ne "\033[2K"
    # Afficher le nouveau texte
    echo -e "$new_text"
    restore_cursor
}

#!/bin/bash

# Couleur de texte
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
LIGHTYELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTMAGENTA='\033[1;35m'
LIGHTCYAN='\033[1;36m'
LIGHTWHITE='\033[1;37m'

# Format de texte
BOLD='\033[1m'
FAINT='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
INVERT='\033[7m'
HIDDEN='\033[8m'

# Reset texte
NC='\033[0m'

# Messages de succès
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Messages d'erreur
error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# Messages d'avertissement
warning() {
    echo -e "${YELLOW}⚠️ $1${NC}" >&2
}

# Messages d'information
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Message titre
print_section_header() {
    local title="$1"
    echo "$(tput setaf 4)$(tput bold)$title$(tput sgr0)"
    echo "--------------------------------------------------------"
}

prompt_input() {
    local prompt="$1"
    local default="$2"
    local validator="$3"
    local error_msg="$4"
    local value
    while true; do
        printf "${BLACK}${BOLD}%s (par défaut: %s) :${NC}\n" "$prompt" "$default" >&2
        echo -e "${YELLOW}   Tapez 'q' pour quitter${NC}" >&2
        read -r value
        if [[ "$value" =~ ^(q|quit|exit)$ ]]; then
            echo -e "${YELLOW}👋 Annulation...${NC}" >&2
            exit 0
        fi
        value=${value:-$default}

        if $validator "$value"; then
            PROMPT_RESULT="$value"
            return 0
        else
            error "$error_msg${NC}" >&2
            clear_lines 4 2.5
        fi
    done
}

prompt_continue() {
    local prompt="$1"
    local answer

    while true; do
        printf "${BLACK}${BOLD}%s${NC}\n" "$prompt" >&2
        printf "${YELLOW}   (Y/n)${NC} " >&2
        read -r answer
        
        # Utiliser 'y' comme valeur par défaut si l'entrée est vide.
        answer=${answer:-y}

        case "$answer" in
            [yY]|[oO])
                # L'utilisateur a dit oui, on continue.
                return 0
                ;;
            [nN])
                # L'utilisateur a dit non, on quitte le script.
                echo -e "${YELLOW}👋 Annulation de l'opération...${NC}" >&2
                exit 0
                ;;
            *)
                # Entrée invalide, on affiche un message d'erreur et on recommence.
                echo -e "${RED}❌ Réponse invalide. Veuillez répondre par 'y' ou 'n'.${NC}" >&2
                sleep 1.5
                clear_lines 4
                ;;
        esac
    done
}