#!/bin/bash
# =============================================================================
# Fichier: parts/02_generate_project.sh
# 
# Description:
#   Ce script est une étape du générateur de projet fullstack. Il est
#   responsable de la création de la structure de répertoires, de
#   l'initialisation de Git et de la création des fichiers de configuration
#   de base pour un nouveau projet.
# 
# Utilisation:
#   Ce script n'est pas destiné à être exécuté seul. Il est appelé par le
#   script principal 'generate-fullstack-project.sh'.
# 
# Arguments (passés par le script principal):
#   $1 - Nom du projet
#   $2 - Répertoire de travail de l'utilisateur
#   $3 - Port du serveur frontend
#   $4 - Port du serveur backend
# =============================================================================

# =============================================================================
# --- Configuration et dépendances ---
# =============================================================================

# Définir le répertoire parent du script
# Ne pas utiliser `dirname` car il ne gère pas les chemins relatifs de manière fiable
PARENT_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"

# Import des utilitaires partagés
source "$PARENT_DIR/utils/bootstrap.sh"

# Récupération et définition des paramètres en lecture seule
readonly PROJECT_NAME="$1"
readonly USER_CWD="$2"
readonly FRONTEND_PORT="$3"
readonly BACKEND_PORT="$4"

# =============================================================================
# --- Fonctions utilitaires ---
# =============================================================================

# validate_parameters()
# Vérifie que les paramètres nécessaires ont été fournis et sont non-vides.
# Affiche un message d'erreur et quitte si un paramètre est manquant.
validate_parameters() {
    clear_lines 1 # Efface la ligne de l'appel de fonction
    local errors=()

    # Vérification de l'existence de chaque paramètre
    [[ -z "$PROJECT_NAME" ]] && errors+=("Nom du projet manquant")
    [[ -z "$USER_CWD" ]] && errors+=("Répertoire utilisateur manquant")
    [[ -z "$FRONTEND_PORT" ]] && errors+=("Port frontend manquant")
    [[ -z "$BACKEND_PORT" ]] && errors+=("Port backend manquant")

    # Si des erreurs ont été trouvées, les afficher et quitter
    if [[ ${#errors[@]} -gt 0 ]]; then
        print_error "❌ Erreurs de paramètres :"
        for err in "${errors[@]}"; do
            echo "   • $err" >&2
        done
        echo "Usage: $0 <project_name> <user_cwd> <frontend_port> <backend_port>" >&2
        exit 1
    fi
}

# create_project_structure()
# Crée l'arborescence des dossiers pour les parties frontend et backend du projet.
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
        "$PROJECT_NAME/scripts"
    )

    # Boucle pour créer chaque répertoire
    for dir in "${directories[@]}"; do
        print_plain "$BLACK" "$dir"
        mkdir -p "$dir"
        sleep 0.05 # Pause pour un meilleur effet visuel
        if [ $? -eq 0 ]; then
            clear_lines 1
        else
            print_error "❌ Impossible de créer : $dir"
        fi
    done

    clear_lines 1 # Nettoyer la dernière ligne vide
    print_success "✅ Structure du projet créée"
}

# setup_git_repository()
# Initialise un dépôt Git dans le nouveau répertoire du projet.
setup_git_repository() {
    print_step_header "🔧 Initialisation de Git"
    #sleep 0.1

    # Accéder au répertoire du projet
    cd "$PROJECT_NAME" || {
        print_error "❌ Impossible d'accéder au répertoire du projet"
        exit 1
    }

    # Initialiser Git en mode silencieux
    if ! git init --quiet &>/dev/null; then
        print_warning "⚠️  Avertissement: Impossible d'initialiser Git"
    fi

    #sleep 0.1
    clear_lines 2 # Nettoyer les lignes de la commande et du message
    print_success "✅ Git initialisé"
}

# set_permissions()
# Modifie les permissions du projet si le script est exécuté avec `sudo`.
set_permissions() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        print_title "🔑 Configuration des permissions"
        chown -R "$SUDO_USER" .
        chmod -R u+w .
        clear_lines 1
        print_success "✅ Permissions configurées"
    fi
}

# create_template_files()
# Appelle un script externe pour générer les fichiers de configuration à partir de templates.
create_template_files() {
    # Exporter les variables pour qu'elles soient disponibles dans le sous-script
    export PROJECT_NAME FRONTEND_PORT BACKEND_PORT

    local create_files_script="$(dirname "$0")/create_project_files.sh"

    if [[ -f "$create_files_script" ]]; then
        if ! bash "$create_files_script" "$PROJECT_NAME" "$FRONTEND_PORT" "$BACKEND_PORT"; then
            print_error "❌ Erreur lors de la création des fichiers templates"
            exit 1
        fi
    else
        print_warning "⚠️  Script de création des fichiers non trouvé: $create_files_script"
    fi
}

# =============================================================================
# --- Fonction principale du script ---
# =============================================================================

# main()
# Orchestre l'exécution des fonctions pour créer la structure du projet.
main() {
    # Validation des paramètres avant de commencer
    validate_parameters

    # Se positionner dans le répertoire de travail de l'utilisateur
    cd "$USER_CWD" || {
        print_error "❌ Impossible d'accéder au répertoire: $USER_CWD"
        exit 1
    }

    # Vérifier si le répertoire du projet existe déjà pour éviter l'écrasement
    if [[ -d "$PROJECT_NAME" ]]; then
        print_error "❌ Le projet '$PROJECT_NAME' existe déjà."
        exit 1
    fi

    # Exécution séquentielle des étapes
    create_project_structure
    setup_git_repository
    set_permissions
    create_template_files

    print_success "🎉 Structure du projet '$PROJECT_NAME' créée avec succès !"
}

# =============================================================================
# --- Point d'entrée du script ---
# =============================================================================

# Exécute la fonction principale avec les arguments passés au script
main "$@"