#!/bin/bash

# =============================================================================
# Fichier: parts/02_generate_project.sh
# =============================================================================


# ==========================
# --- Configuration ---
# ==========================

# Définir PARENT_DIR seulement s'il n'existe pas déjà
if [[ -z "${PARENT_DIR:-}" ]]; then
    PARENT_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
fi

# Import des utilitaires
source "$(dirname "${BASH_SOURCE[0]}")/../utils/bootstrap.sh"

# Récupération des paramètres
readonly PROJECT_NAME="$1"
readonly USER_CWD="$2"
readonly FRONTEND_PORT="$3"
readonly BACKEND_PORT="$4"

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

validate_parameters() {
    clear_lines 1
    local errors=()

    [[ -z "$PROJECT_NAME" ]] && errors+=("Nom du projet manquant")
    [[ -z "$USER_CWD" ]] && errors+=("Répertoire utilisateur manquant")
    [[ -z "$FRONTEND_PORT" ]] && errors+=("Port frontend manquant")
    [[ -z "$BACKEND_PORT" ]] && errors+=("Port backend manquant")

    if [[ ${#errors[@]} -gt 0 ]]; then
        print_error "Erreurs de paramètres :"
        for err in "${errors[@]}"; do
            echo "   • $err" >&2
        done
        echo "Usage: $0 <project_name> <user_cwd> <frontend_port> <backend_port>" >&2
        exit 1
    fi
}

create_project_structure() {
    print_step_header "📁 Création de la structure du projet"

    local directories=(
        "$PROJECT_NAME/client/src/assets"
        "$PROJECT_NAME/client/src/components"
        "$PROJECT_NAME/client/src/context"
        "$PROJECT_NAME/client/src/hooks"
        "$PROJECT_NAME/client/src/layouts"
        "$PROJECT_NAME/client/src/libs"
        "$PROJECT_NAME/client/src/pages"
        "$PROJECT_NAME/client/src/services"
        "$PROJECT_NAME/client/src/types"
        "$PROJECT_NAME/client/src/utils"
        "$PROJECT_NAME/client/public"
        "$PROJECT_NAME/server/src/routes"
        "$PROJECT_NAME/server/src/controllers"
        "$PROJECT_NAME/server/src/services"
        "$PROJECT_NAME/server/prisma"
    )

    for dir in "${directories[@]}"; do
        print_plain "$BLACK" "$dir"
        mkdir -p "$dir"
        sleep 0.1
        if [ $? -eq 0 ]; then
            clear_lines 1
        else
            print_error "❌ Impossible de créer : $dir"
        fi
    done

    clear_lines 1
    print_success "Structure du projet créée"
}

setup_git_repository() {
    print_step_header "🔧 Initialisation de Git"
    sleep 0.1

    cd "$PROJECT_NAME" || {
        print_error "Impossible d'accéder au répertoire du projet"
        exit 1
    }

    if ! git init --quiet &>/dev/null; then
        print_warning "Avertissement: Impossible d'initialiser Git"
    fi

    sleep 0.1
    clear_lines 2
    print_success "Git initialisé"
}

set_permissions() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        print_title "🔑 Configuration des permissions"
        chown -R "$SUDO_USER" .
        chmod -R u+w .
        clear_lines 1
        print_success "Permissions configurées"
    fi
}

create_template_files() {
    # Exporter les variables pour les templates
    export PROJECT_NAME FRONTEND_PORT BACKEND_PORT

    local create_files_script="$(dirname "$0")/create_project_files.sh"

    if [[ -f "$create_files_script" ]]; then
        if ! bash "$create_files_script" "$PROJECT_NAME" "$FRONTEND_PORT" "$BACKEND_PORT"; then
            print_error "Erreur lors de la création des fichiers templates"
            exit 1
        fi
    else
        print_warning "Script de création des fichiers non trouvé: $create_files_script"
    fi
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

main() {
    validate_parameters

    cd "$USER_CWD" || {
        print_error "Impossible d'accéder au répertoire: $USER_CWD"
        exit 1
    }

    if [[ -d "$PROJECT_NAME" ]]; then
        print_error "Le projet '$PROJECT_NAME' existe déjà"
        exit 1
    fi

    create_project_structure
    setup_git_repository
    set_permissions
    create_template_files

    print_success "🎉 Structure du projet '$PROJECT_NAME' créée avec succès !"
}

# =============================================================================
# EXÉCUTION
# =============================================================================

main "$@"