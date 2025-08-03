#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

PROJECT_NAME="$1"

echo -e "${GREEN} ${BOLD}✅ Projet ${PROJECT_NAME} créé avec succès !${NC}"
echo -e "${BLUE} ${BOLD}📁 Structure créée dans: $(pwd)/$PROJECT_NAME${NC}"
echo ""
echo -e "${GREEN} ${BOLD}🚀 Étapes suivantes :${NC}"
echo -e "1. ${BLUE}cd $PROJECT_NAME && npm run install:all${NC}"
echo -e "2. ${BLUE}npm run dev${NC}"
echo ""
echo -e "${GREEN} ${BOLD}📖 Ports :${NC}"
echo -e "• Frontend: ${BLUE}http://localhost:3000${NC}"
echo -e "• Backend:  ${BLUE}http://localhost:5000${NC}"