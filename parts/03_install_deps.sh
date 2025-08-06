#!/bin/bash
# =============================================================================
# Fichier: parts/03_install_deps.sh
# 
# Description:
#   Ce script gère l'installation des dépendances npm pour l'ensemble du projet
#   fullstack. Il installe les dépendances à la racine, puis les dépendances
#   spécifiques aux sous-projets 'client' et 'server' en utilisant un script
#   npm dédié. Le script est conçu pour être résilient en cas d'échec
#   temporaire et pour filtrer la sortie de npm afin de ne montrer que les
#   informations pertinentes à l'utilisateur.
# 
# Utilisation:
#   Ce script n'est pas destiné à être exécuté seul. Il est appelé par le
#   script principal 'generate-fullstack-project.sh'.
# 
# Arguments (passés par le script principal):
#   $1 - Nom du projet
# =============================================================================

# Activer le mode strict pour une exécution sécurisée
set -euo pipefail

# =============================================================================
# --- Configuration et dépendances ---
# =============================================================================

# Import des utilitaires partagés
source "$(dirname "${BASH_SOURCE[0]}")/../utils/bootstrap.sh"

# Récupération et définition des paramètres
readonly PROJECT_NAME="$1"
readonly PROJECT_DIR="./$PROJECT_NAME"

# =============================================================================
# --- Fonctions utilitaires ---
# =============================================================================

# filter_npm_output()
# Filtre la sortie de la commande `npm` pour n'afficher que les lignes
# importantes (erreurs, succès) et masquer le bruit (avertissements,
# messages de financement).
filter_npm_output() {
    local count=0
    while IFS= read -r line; do
        # Affiche les erreurs immédiatement
        if echo "$line" | grep -qE "(error|npm ERR|ENOENT|ENOTEMPTY|failed|Failed)"; then
            echo -n "."  # Affiche un point sans retour à la ligne
            sleep 0.05   # (optionnel) ralentir pour lisibilité
        else
            # Affiche un point toutes les 3 lignes pour ne pas en afficher trop
            ((count++))
            if (( count % 3 == 0 )); then
                echo -n "."  # Affiche un point sans retour à la ligne
                sleep 0.05   # (optionnel) ralentir pour lisibilité
            fi
        fi
    done
    echo ""
}

# install_with_retry()
# Exécute une commande d'installation et tente de la relancer en cas d'échec.
# Affiche des messages clairs sur le statut de l'installation.
install_with_retry() {
    local command="$1"
    local label="$2"

    if eval "$command" 2>&1 | filter_npm_output; then
        clear_lines 2
        print_success "$label réussi"
    else
        clear_lines 2
        print_warning "$label échoué une première fois. Nouvelle tentative..."
        sleep 1
        if eval "$command" 2>&1 | filter_npm_output; then
            clear_lines 2
            print_success "$label réussi à la 2ᵉ tentative ✅"
        else
            clear_lines 2
            print_error "$label échoué après deux tentatives ❌"
            return 1
        fi
    fi
}

# =============================================================================
# --- Fonction principale du script ---
# =============================================================================

# main()
# Orchestre l'installation des dépendances.
main() {
    # 1. Validation de l'environnement
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_error "Le dossier du projet n'existe pas : $PROJECT_DIR"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    
    if [[ ! -f "package.json" ]]; then
        print_error "Aucun package.json trouvé à la racine du projet"
        exit 1
    fi

    # 2. Installation des dépendances racine
    print_info "📦 Installation des dépendances (racine)..."
    install_with_retry "npm install --no-fund" "Installation des dépendances racine"

    # 3. Installation des dépendances client et serveur
    # Vérifie l'existence du script `install:all` avant de l'exécuter
    if [[ "$(jq -r '.scripts["install:all"] // empty' package.json)" != "" ]]; then
        print_info "📦 Installation des dépendances client et serveur..."
        install_with_retry "npm run install:all --no-fund" "Installation client et serveur"
    else
        print_warning "Script npm 'install:all' introuvable dans package.json. Les dépendances des sous-projets ne seront pas installées."
    fi

    print_success "🎉 Installation des dépendances terminée"
    
}

# =============================================================================
# --- Point d'entrée du script ---
# =============================================================================

# Exécute la fonction principale
main "$@"