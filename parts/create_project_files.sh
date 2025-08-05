#!/bin/bash

# ==============================================================================
# Script de création de structure de projet Full-Stack
# Génère automatiquement les fichiers client/serveur à partir de templates
# ==============================================================================

set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Import des utilitaires
source "$PARENT_DIR/utils/colors.sh"
source "$PARENT_DIR/utils/terminal_utils.sh"
source "$PARENT_DIR/utils/template_engine.sh"

# Paramètres du projet
readonly PROJECT_NAME="${1:-}"
readonly FRONTEND_PORT="${2:-3000}"
readonly BACKEND_PORT="${3:-5000}"

# ==============================================================================
# FONCTIONS UTILITAIRES
# ==============================================================================

print_section_header() {
    local title="$1"
    echo "$(tput setaf 4)$(tput bold)$title$(tput sgr0)"
    echo "--------------------------------------------------------"
}

print_success() {
    local message="$1"
    echo "$(tput setaf 2)$(tput bold)✨ $message$(tput sgr0)"
}

# Fonction pour créer des fichiers sans substitution
create_simple_files() {
    local template_dir="$1"
    local section_name="$2"
    shift 2
    local files=("$@")
    
    local success_count=0
    local total_count=${#files[@]}
    
    echo "$(tput setaf 7)📁 Traitement de $total_count fichier(s) pour $section_name...$(tput sgr0)"
    
    for file in "${files[@]}"; do
        local source_path="$template_dir/$file"
        local dest_path=""
        # Vérifie si le répertoire de template est "root"
        if [[ "$template_dir" == "root" ]]; then
            dest_path="$file"
        else
            dest_path="$template_dir/$file"
        fi
        
        # Print the file path and use `printf` to keep the cursor on the same line
        printf "   Creating: %s..." "$dest_path"
        sleep 0.5
        if create_from_template "$source_path" "$dest_path"; then
            printf "\r   Creating: %s... OK\n" "$dest_path"
            ((success_count++))
        else
            printf "\r   Creating: %s... FAILED\n" "$dest_path"
            echo "$(tput setaf 1)Erreur lors de la copie du fichier$(tput sgr0)"
            echo "Source: $source_path"
            echo "Destination: $dest_path"
            exit 1
        fi
        sleep 0.1
    done
    
    #echo "$(tput setaf 2)📊 $success_count/$total_count fichiers copiés avec succès$(tput sgr0)"
}

# Fonction pour créer des fichiers avec substitution
create_processed_files() {
    # --------------------------------------------------------------------------
    # Arguments
    # $1: template_dir (e.g., "client", "server")
    # $2: section_name (e.g., "client React/Vite")
    # $3: variables (key=value pairs for substitution)
    # $@: list of filenames
    # --------------------------------------------------------------------------
    
    local template_dir="$1"
    local section_name="$2"
    local variables="$3"
    shift 3
    local files=("$@")

    local success_count=0
    local total_count=${#files[@]}

    echo "$(tput setaf 7)📝 Traitement de $total_count fichier(s) pour $section_name avec variables...$(tput sgr0)"
    
    for file in "${files[@]}"; do
        local source_path="$template_dir/$file"
        local dest_path=""
        
        # Determine the destination path based on the template directory
        if [[ "$template_dir" == "root" ]]; then
            dest_path="$file"
        else
            dest_path="$template_dir/$file"
        fi
        
        # Print the file path and use `printf` to keep the cursor on the same line
        printf "   Creating: %s..." "$dest_path"
        sleep 0.5
        # Call the template engine function to process and create the file
        if process_template "$source_path" "$dest_path" "$variables"; then
            printf "\r   Creating: %s... OK\n" "$dest_path"
            ((success_count++))
        else
            printf "\r   Creating: %s... FAILED\n" "$dest_path"
            echo "$(tput setaf 1)Erreur lors du traitement du fichier$(tput sgr0)"
            echo "Source: $source_path"
            echo "Destination: $dest_path"
            exit 1
        fi
        
        # Add a short delay for better user experience
        sleep 0.1
    done

    # Display a summary of the operation
    #echo "$(tput setaf 2)📊 $success_count/$total_count fichiers traités avec succès$(tput sgr0)"
}


# ==============================================================================
# DÉFINITION DES FICHIERS À COPIER ET À TRAITER
# ==============================================================================

# Fichiers racine à copier
declare -ra ROOT_FILES_SIMPLE=(
    ".gitignore"
)

# Fichiers racine à traiter avec variables
declare -ra ROOT_FILES_PROCESSED=(
    "package.json"
    "README.md"
)

# Fichiers client à copier
declare -ra CLIENT_FILES_SIMPLE=(
    ".env.example"
    ".gitignore"
    "index.html"
    "package.json"
    "tsconfig.json"
    "tsconfig.node.json"
    "src/App.module.css"
    "src/App.tsx"
    "src/main.tsx"
    "src/vite-env.d.ts"
)

# Fichiers client à traiter avec variables
declare -ra CLIENT_FILES_PROCESSED=(
    ".env"
    "vite.config.ts"
    "src/services/apiService.ts"
)

# Fichiers serveur à copier
declare -ra SERVER_FILES_SIMPLE=(
    ".env.example"
    ".gitignore"
    "package.json"
    "tsconfig.json"
    "prisma/schema.prisma"
    "src/controllers/pingController.ts"
    "src/routes/index.ts"
    "src/services/database.ts"
)

# Fichiers serveur à traiter avec variables
declare -ra SERVER_FILES_PROCESSED=(
    ".env"
    "src/app.ts"
    "src/server.ts"
)

# ==============================================================================
# FONCTIONS DE CRÉATION
# ==============================================================================

create_root_files() {
    #print_section_header "📂 Création des fichiers racine du projet"
    create_simple_files "root" "fichiers racine" "${ROOT_FILES_SIMPLE[@]}"
    create_processed_files "root" "fichiers racine" "PROJECT_NAME=$PROJECT_NAME FRONTEND_PORT=$FRONTEND_PORT BACKEND_PORT=$BACKEND_PORT" "${ROOT_FILES_PROCESSED[@]}"
    #print_success "Fichiers racine créés !"
}

create_client_files() {
    #print_section_header "💻 Création des fichiers du client (Frontend)"
    create_simple_files "client" "client React/Vite" "${CLIENT_FILES_SIMPLE[@]}"
    create_processed_files "client" "client React/Vite" "PROJECT_NAME=$PROJECT_NAME FRONTEND_PORT=$FRONTEND_PORT BACKEND_PORT=$BACKEND_PORT" "${CLIENT_FILES_PROCESSED[@]}"
    #print_success "Fichiers client créés !"
}

create_server_files() {
    #print_section_header "🖥️  Création des fichiers du serveur (Backend)"
    create_simple_files "server" "serveur Node.js/Express" "${SERVER_FILES_SIMPLE[@]}"
    create_processed_files "server" "serveur Node.js/Express" "PROJECT_NAME=$PROJECT_NAME BACKEND_PORT=$BACKEND_PORT" "${SERVER_FILES_PROCESSED[@]}"
    #print_success "Fichiers serveur créés !"
}

# ==============================================================================
# FONCTION PRINCIPALE
# ==============================================================================

main() {
    # Création des différentes parties du projet
    create_root_files
    create_client_files
    create_server_files
    
    # Message de fin
    echo "$(tput setaf 2)$(tput bold)🎉 SUCCÈS !$(tput sgr0)"
    echo "$(tput setaf 2)La structure du projet '$PROJECT_NAME' a été créée avec succès !$(tput sgr0)"
}

# ==============================================================================
# EXÉCUTION
# ==============================================================================

main "$@"