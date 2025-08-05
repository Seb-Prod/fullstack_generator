#!/bin/bash

# =============================================================================
# Utilitaires d'interaction terminal
# =============================================================================

prompt_input() {
    local prompt="$1"
    local default="$2"
    local validator="$3"
    local error_msg="$4"
    local value

    while true; do
        print_plain "$BLACK" "${prompt} (par défaut: $default) :"
        print_warning "   Tapez 'q' pour quitter"

        read -r value
        if [[ "$value" =~ ^(q|quit|exit)$ ]]; then
            clear
            show_banner
            print_warning "👋 Annulation..."
            exit 0
        fi

        value=${value:-$default}

        if $validator "$value"; then
            PROMPT_RESULT="$value"
            clear_lines 3
            return 0
        else
            print_error "$error_msg"
            clear_lines 4 0.5
        fi
    done
}

prompt_continue() {
    local prompt="$1"
    local answer

    while true; do
        print_plain "$BLACK" "${BOLD}${prompt}"
        print_warning "   (Y/n) "
        read -r answer

        answer=${answer:-y}  # par défaut : oui

        case "$answer" in
            [yY]|[oO])
                return 0
                ;;
            [nN])
                print_warning "👋 Annulation de l'opération..."
                exit 0
                ;;
            *)
                print_error "Réponse invalide. Veuillez répondre par 'y' ou 'n'."
                sleep 1.5
                clear_lines 4
                ;;
        esac
    done
}