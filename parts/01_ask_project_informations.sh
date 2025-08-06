#!/bin/bash

# =============================================================================
# Fichier: parts/01_ask_project_informations.sh
# Collecte des informations nécessaires à la création du projet
# =============================================================================

# =============================================================================
# FONCTIONS DE VALIDATION
# =============================================================================

validate_project_name() {
    local name="$1"
    if ! [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]{2,}$ ]]; then
        return 1
    fi
    if [[ -d "$name" ]]; then
        return 1
    fi
    return 0
}

validate_port() {
    local port="$1"
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    if (( port < 1024 || port > 65535 )); then
        return 1
    fi
    if lsof -i ":$port" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

validate_different_ports() {
    [[ "$1" != "$2" ]]
}

# =============================================================================
# FONCTIONS D'AFFICHAGE
# =============================================================================

show_project_summary() {
    clear_lines 5
    print_plain "$GREEN" "📋 Récapitulatif du projet :"
    print_plain "$BLUE" "   📁 Nom      : $PROJECT_NAME"
    print_plain "$BLUE" "   🌐 Frontend : http://localhost:$FRONTEND_PORT"
    print_plain "$BLUE" "   ⚙️  Backend  : http://localhost:$BACKEND_PORT"
    echo ""
}

show_validation_tips() {
    print_warning "💡 Conseils :"
    print_plain "$YELLOW" "   • Le nom doit commencer par une lettre (3+ caractères)"
    print_plain "$YELLOW" "   • Les ports doivent être entre 1024 et 65535"
    print_plain "$YELLOW" "   • Vérifiez que les ports ne sont pas déjà utilisés"
    echo ""
}

# =============================================================================
# COLLECTE DES INFORMATIONS
# =============================================================================

collect_project_info() {
    local attempts=0

    show_validation_tips

    # === NOM DU PROJET ===
    while true; do
        prompt_input "💡 Nom du projet" "mon-projet-fullstack" validate_project_name "Nom invalide ou dossier existant" 3
        PROJECT_NAME="$PROMPT_RESULT"

        if validate_project_name "$PROJECT_NAME"; then
            break
        fi
    done

    # === PORT FRONTEND ===
    while true; do
        prompt_input "🌐 Port pour le frontend" "3000" validate_port "Port invalide ou déjà utilisé" 3
        FRONTEND_PORT="$PROMPT_RESULT"

        if validate_port "$FRONTEND_PORT"; then
            break
        fi
    done

    # === PORT BACKEND ===-
    while true; do
        prompt_input "⚙️  Port pour le backend" "5000" validate_port "Port invalide ou déjà utilisé"
        BACKEND_PORT="$PROMPT_RESULT"

        if ! validate_port "$BACKEND_PORT"; then
            clear_lines 3
            continue
        fi

        if ! validate_different_ports "$FRONTEND_PORT" "$BACKEND_PORT"; then
            print_error "Le port backend doit être différent du port frontend ($FRONTEND_PORT)"
            clear_lines 4 1.5
            continue
        fi

        break
    done
}

# =============================================================================
# CONFIRMATION ET EXPORT
# =============================================================================

confirm_and_export() {
    show_project_summary

    export PROJECT_NAME
    export FRONTEND_PORT  
    export BACKEND_PORT

    prompt_continue "Voulez-vous lancer la création du projet ?"

    print_success "🚀 Démarrage de la création du projet..."
    clear_lines 3
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

main() {
    collect_project_info
    confirm_and_export

    if [[ "${DEBUG:-}" == "1" ]]; then
        print_info "Variables exportées :"
        print_info "  PROJECT_NAME=$PROJECT_NAME"
        print_info "  FRONTEND_PORT=$FRONTEND_PORT"
        print_info "  BACKEND_PORT=$BACKEND_PORT"
    fi
}

# =============================================================================
# EXÉCUTION
# =============================================================================

main "$@"