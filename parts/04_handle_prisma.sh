#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/../utils/bootstrap.sh"

PROJECT_NAME="$1"
PROJECT_DIR="./$PROJECT_NAME"

# Fonction pour filtrer les messages npm
filter_npm_output() {
    while IFS= read -r line; do
        # Garder les erreurs et messages importants
        if echo "$line" | grep -qE "(error|Error|ERROR|npm ERR|ENOENT|ENOTEMPTY|failed|Failed|✅|added.*packages|audited.*packages|found.*vulnerabilities)"; then
            echo "$line"
        # Masquer les warnings spécifiques
        elif echo "$line" | grep -qE "(warn deprecated|warn cleanup|looking for funding|npm fund|Use.*instead|no longer supported|version is no longer supported)"; then
            continue
        # Garder les autres messages courts et utiles
        elif [[ ${#line} -lt 80 ]] && ! echo "$line" | grep -qE "(warn|deprecated)"; then
            echo "$line"
        fi
    done
}

cd "$PROJECT_NAME"

# Vérifier si Prisma a des problèmes et le régénérer si nécessaire
set +e
cd server
npx prisma generate --silent > /dev/null 2>&1
PRISMA_STATUS=$?
set -e

if [ $PRISMA_STATUS -ne 0 ]; then
    print_warning "Prisma a rencontré un problème. Tentative de régénération des engines..."
    npx prisma generate 2>&1 | filter_npm_output
    print_success "Prisma régénéré avec succès"
fi

cd ..