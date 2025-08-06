#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/bootstrap.sh"

PROJECT_NAME="$1"
FRONTEND_PORT="$2"
BACKEND_PORT="$3"

print_success "Projet ${BOLD}${PROJECT_NAME}${NC} créé avec succès !"
print_info "📁 Structure disponible dans : $(pwd)/$PROJECT_NAME"

echo ""
print_success "🚀 Étapes suivantes :"
print_plain "$BLUE" "1. cd $PROJECT_NAME"
print_plain "$BLUE" "2. npm run dev"

echo ""
print_success "📖 Ports par défaut :"
print_plain "$BLUE" "• Frontend : http://localhost:${FRONTEND_PORT:-3000}"
print_plain "$BLUE" "• Backend  : http://localhost:${BACKEND_PORT:-5000}"

echo ""
print_warning "🚀 Voulez-vous lancer le projet maintenant ? (y/N)"
read -r -p "   " LAUNCH_PROJECT

case "$LAUNCH_PROJECT" in
    [yY]|[yY][eE][sS]|[oO]|[oO][uU][iI])
        clear
        show_banner
        print_info "Lancement du projet..."

        cd "$PROJECT_NAME"
        (
          trap - EXIT ERR
          npm run dev
        )
        exit 1
        ;;
    *)
        echo ""
        print_info "👋 Projet prêt ! Vous pouvez le lancer plus tard"
        ;;
esac