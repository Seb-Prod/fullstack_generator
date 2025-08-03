#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
CLIENT_DIR="$PROJECT_NAME/client"

# Afficher un titre formaté
echo -e "${GREEN} - Création du vite.config.ts ${NC}"

# Le fichier
cat > "$CLIENT_DIR/vite.config.ts" << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true
  },
  css: {
    modules: {
      localsConvention: 'camelCase'
    }
  }
})
EOF