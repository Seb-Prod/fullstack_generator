#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
SERVER_DIR="$PROJECT_NAME/server"

# Afficher un titre formaté
echo -e "${GREEN} - Création du src/routes/index.ts ${NC}"

# Le fichier
cat > "$SERVER_DIR/src/routes/index.ts" << 'EOF'
import { Router } from 'express'
import { pingController } from '../controllers/pingController'

const router = Router()

// Route de test
router.get('/ping', pingController.ping)

// Ajouter d'autres routes ici
// router.use('/users', userRoutes)
// router.use('/auth', authRoutes)

export default router
EOF