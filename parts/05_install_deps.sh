#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"

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

echo -e "${BLUE}📦 Installation des dépendances...${NC}"
cd "$PROJECT_NAME"

# Installation du package.json racine
npm install --no-fund 2>&1 | filter_npm_output

# Installation des dépendances client et serveur
npm run install:all --no-fund 2>&1 | filter_npm_output

echo -e "${GREEN}✅ Installation des dépendances terminée${NC}"