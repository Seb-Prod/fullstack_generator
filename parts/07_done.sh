#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"

echo ""
echo -e "${GREEN} ${BOLD}✅ Projet ${PROJECT_NAME} créé avec succès !${NC}"
echo -e "${BLUE} ${BOLD}📁 Structure créée dans: $(pwd)/$PROJECT_NAME${NC}"
echo ""
echo -e "${GREEN} ${BOLD}🚀 Étapes suivantes :${NC}"
echo -e "1. ${BLUE}cd $PROJECT_NAME${NC}"
echo -e "2. ${BLUE}npm run dev${NC}"
echo ""
echo -e "${GREEN} ${BOLD}📖 Ports :${NC}"
echo -e "• Frontend: ${BLUE}http://localhost:${FRONTEND_PORT:-3000}${NC}"
echo -e "• Backend:  ${BLUE}http://localhost:${BACKEND_PORT:-5000}${NC}"
echo ""

# Demander si on lance le projet
echo -e "${YELLOW}${BOLD}🚀 Voulez-vous lancer le projet maintenant ? (y/N)${NC}"
read -r -p "   " LAUNCH_PROJECT

case "$LAUNCH_PROJECT" in
    [yY]|[yY][eE][sS]|[oO]|[oO][uU][iI])
        echo ""
        echo -e "${GREEN}🚀 Lancement du projet...${NC}"
        cd "$PROJECT_NAME"
        npm run dev
        ;;
    *)
        echo ""
        echo -e "${BLUE}👋 Projet prêt ! Vous pouvez le lancer plus tard avec :${NC}"
        echo -e "   ${BOLD}cd $PROJECT_NAME && npm run dev${NC}"
        echo ""
        ;;
esac