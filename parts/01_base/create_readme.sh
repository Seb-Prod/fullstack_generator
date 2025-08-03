#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"

# Afficher un titre formaté
echo -e "${GREEN} - Création du README.md ${NC}"

# Le fichier
cat > README.md << EOF
# ${PROJECT_NAME}
Un projet fullstack moderne avec React + TypeScript (frontend) et Express + TypeScript (backend).
## 🚀 Technologies utilisées
### Frontend
- React 18
- TypeScript
- Vite
- CSS Modules
### Backend
- Express
- TypeScript
- MySQL avec Prisma
- Hot reload avec ts-node-dev
## 📦 Installation
1. Installer toutes les dépendances :
\`\`\`bash
npm run install:all
\`\`\`
2. Configurer les variables d'environnement :
\`\`\`bash
cp client/.env.example client/.env
cp server/.env.example server/.env
\`\`\`
3. Éditer les fichiers \`.env\` selon votre configuration.
## 🏃 Démarrage
### Développement (recommandé)
\`\`\`bash
npm run dev
\`\`\`
### Démarrage séparé
#### Frontend (port 3000)
\`\`\`bash
cd client && npm run dev
\`\`\`
#### Backend (port 5000)
\`\`\`bash
cd server && npm run dev
\`\`\`
## 🔗 Endpoints API
- \`GET /api/ping\` - Test de connexion (retourne "pong")
## 🔧 Configuration
### Variables d'environnement
#### Client (\`client/.env\`)
\`\`\`env
VITE_API_URL=http://localhost:5000/api
\`\`\`
#### Server (\`server/.env\`)
\`\`\`env
PORT=5000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=mon_projet
NODE_ENV=development
\`\`\`
EOF
