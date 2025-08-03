#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
SERVER_DIR="$PROJECT_NAME/server"

# Afficher un titre formaté
echo -e "${GREEN} - Création du src/controllers/pingController.ts ${NC}"

# Le fichier
cat > "$SERVER_DIR/src/controllers/pingController.ts" << 'EOF'
import { Request, Response } from 'express'

export const pingController = {
  ping: (req: Request, res: Response) => {
    try {
      res.json({
        message: 'pong',
        timestamp: new Date().toISOString(),
        server: 'Express + TypeScript',
        status: 'OK'
      })
    } catch (error) {
      console.error('Erreur dans pingController:', error)
      res.status(500).json({
        error: 'Erreur lors du ping',
        message: error instanceof Error ? error.message : 'Erreur inconnue'
      })
    }
  }
}
EOF