#!/bin/bash
set -euo pipefail

# =============================================================================
# Étape 3 - Installation des dépendances (racine, client, serveur)
# =============================================================================

# Import des utilitaires
source "$(dirname "${BASH_SOURCE[0]}")/../utils/bootstrap.sh"

PROJECT_NAME="$1"
PROJECT_DIR="./$PROJECT_NAME"

if [[ ! -d "$PROJECT_DIR" ]]; then
    print_error "Le dossier du projet n'existe pas : $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

if [[ ! -f "package.json" ]]; then
    print_error "Aucun package.json trouvé à la racine du projet"
    exit 1
fi

print_info "Installation des dépendances (racine)..."

# Fonction pour filtrer les messages npm
filter_npm_output() {
    while IFS= read -r line; do
        # Garder les erreurs et messages importants
        if echo "$line" | grep -qE "(error|npm ERR|ENOENT|ENOTEMPTY|failed|Failed|added.*packages|audited.*packages|found.*vulnerabilities)"; then
            echo "$line"
        # Masquer certains warnings non critiques
        elif echo "$line" | grep -qE "(warn deprecated|warn cleanup|looking for funding|npm fund|no longer supported)"; then
            continue
        # Afficher les autres lignes courtes utiles
        elif [[ ${#line} -lt 80 ]] && ! echo "$line" | grep -qE "(warn|deprecated)"; then
            echo "$line"
        fi
    done
}

# Installation racine
npm install --no-fund 2>&1 | filter_npm_output

# Installation client + backend (présumé via un script custom)
if [[ -f "package.json" && "$(jq -r '.scripts["install:all"]' package.json)" != "null" ]]; then
    print_info "Installation des dépendances client et serveur..."
    npm run install:all --no-fund 2>&1 | filter_npm_output
else
    print_warning "Script npm 'install:all' introuvable dans package.json"
fi

print_success "Installation des dépendances terminée"