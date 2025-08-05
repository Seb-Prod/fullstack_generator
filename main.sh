#!/bin/bash

# =============================================================================
# Script principal - Générateur de projet Fullstack TypeScript
# Seb-Prod 2025
# =============================================================================

set -euo pipefail  # Mode strict : arrêt sur erreur, variables non définies, échec de pipe

# =============================================================================
# CONFIGURATION ET VALIDATION
# =============================================================================

clear  # Nettoyer le terminal

# Répertoire du script
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Vérification et chargement des utilitaires
UTILS=(
  "banner.sh"
  "validate_args.sh"
  "clean_error.sh"
  "execute_step.sh"
  "print_utils.sh"
  "prompt_utils.sh"
)

for file in "${UTILS[@]}"; do
  path="$SCRIPT_DIR/utils/$file"
  if [[ ! -f "$path" ]]; then
    echo -e "\033[0;31m❌ Fichier manquant : $path\033[0m" >&2
    exit 1
  fi
  source "$path"
done

# Appel à la validation des arguments (définit USER_CWD)
set_working_dir "$@"
cd "$USER_CWD"

# Nettoyage en cas d'erreur
trap cleanup_on_error EXIT ERR

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

main() {
  show_banner

  print_section_header "[Étape 1] 🔧 Configuration du projet"

  local config_script="$SCRIPT_DIR/parts/01_ask_project_informations.sh"
  if [[ -f "$config_script" ]]; then
    source "$config_script"
    print_success "Étape 1 terminée avec succès"
  else
    print_error "Script de configuration non trouvé : $config_script"
    exit 1
  fi

  # Vérification des variables
  if [[ -z "${PROJECT_NAME:-}" || -z "${FRONTEND_PORT:-}" || -z "${BACKEND_PORT:-}" ]]; then
    print_error "Variables du projet non définies (PROJECT_NAME, FRONTEND_PORT, BACKEND_PORT)"
    exit 1
  fi

  # Étape 2 : Génération de la structure du projet
  execute_step "2" "Génération de la structure" \
    "$SCRIPT_DIR/parts/02_generate_project.sh" \
    "$PROJECT_NAME" "$USER_CWD" "$FRONTEND_PORT" "$BACKEND_PORT"

  # Étape finale
  print_section_header "[✅] Projet généré avec succès"
  print_success "📁 Le projet ${PROJECT_NAME} est prêt dans : ${USER_CWD}/${PROJECT_NAME}"
}

# Exécuter main uniquement si ce script est le point d’entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi