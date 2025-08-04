#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
CLIENT_DIR="$PROJECT_NAME/client"

# Afficher un titre formaté
echo -e "${GREEN} - Création du tsconfig.node.json ${NC}"

# Le fichier
cat > "$CLIENT_DIR/tsconfig.node.json" << 'EOF'
{
  "compilerOptions": {
    "composite": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
EOF