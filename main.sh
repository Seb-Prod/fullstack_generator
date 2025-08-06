#!/bin/bash
# =============================================================================
# Script principal - Générateur de projet Fullstack TypeScript
# Seb-Prod 2025
#
# Description:
#   Génère automatiquement un projet fullstack TypeScript avec :
#   - Frontend (React/Next.js)
#   - Backend (Node.js/Express)
#   - Base de données (Prisma)
#   - Configuration complète de développement
#
# Usage:
#   ./generate-fullstack-project.sh [DIRECTORY]
#
# Arguments:
#   DIRECTORY (optionnel) - Répertoire où créer le projet (défaut: répertoire courant)
#
# Exemples:
#   ./generate-fullstack-project.sh                    # Génère dans le répertoire courant
#   ./generate-fullstack-project.sh /path/to/projects  # Génère dans le répertoire spécifié
#
# Variables d'environnement utilisées:
#   PROJECT_NAME    - Nom du projet (demandé interactivement)
#   FRONTEND_PORT   - Port du serveur frontend (demandé interactivement)
#   BACKEND_PORT    - Port du serveur backend (demandé interactivement)
#   USER_CWD        - Répertoire de travail (défini automatiquement)
#
# Dépendances:
#   - Node.js >= 18
#   - npm ou yarn
#   - Git
# =============================================================================

set -euo pipefail # Mode strict : arrêt sur erreur, variables non définies, échec de pipe

# =============================================================================
# CONFIGURATION ET CONSTANTES
# =============================================================================

# Répertoire du script (readonly pour éviter les modifications accidentelles)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Liste des utilitaires requis
UTILS=(
  "banner.sh"
  "validate_args.sh"
  "clean_error.sh"
  "execute_step.sh"
  "print_utils.sh"
  "prompt_utils.sh"
)

# Variables globales (définies par les scripts inclus)
# PROJECT_NAME=""      # Nom du projet (défini dans 01_ask_project_informations.sh)
# FRONTEND_PORT=""     # Port du serveur frontend
# BACKEND_PORT=""      # Port du serveur backend
# USER_CWD=""          # Répertoire de travail utilisateur

# =============================================================================
# CHARGEMENT DES UTILITAIRES
# Vérifie l'existence et charge tous les scripts utilitaires nécessaires
# =============================================================================

clear # Nettoyer le terminal

for file in "${UTILS[@]}"; do
  path="$SCRIPT_DIR/utils/$file"
  if [[ ! -f "$path" ]]; then
    echo -e "\033[0;31m❌ Fichier manquant : $path\033[0m" >&2
    exit 1
  fi
  source "$path"
done

# =============================================================================
# INITIALISATION ET VALIDATION
# =============================================================================

# Validation des arguments et définition du répertoire de travail
set_working_dir "$@"
cd "$USER_CWD"

# Configuration de la gestion d'erreurs
trap cleanup_on_error EXIT ERR

# =============================================================================
# FONCTION PRINCIPALE
# Orchestre la génération complète du projet fullstack
#
# Globals:
#   PROJECT_NAME - Nom du projet à créer
#   FRONTEND_PORT - Port du serveur frontend
#   BACKEND_PORT - Port du serveur backend
#   USER_CWD - Répertoire de travail utilisateur
#   SCRIPT_DIR - Répertoire du script principal
#
# Arguments:
#   $@ - Arguments passés au script
#
# Returns:
#   0 si succès, 1 en cas d'erreur
# =============================================================================

main() {
  show_banner

  # Étape 1 : Configuration interactive du projet
  # - Collecte le nom du projet, les ports frontend/backend
  # - Valide les paramètres saisis par l'utilisateur
  print_section_header "[Étape 1] 🔧 Configuration du projet"

  local config_script="$SCRIPT_DIR/parts/01_ask_project_informations.sh"
  if [[ -f "$config_script" ]]; then
    source "$config_script"
    print_success "Étape 1 terminée avec succès"
  else
    print_error "Script de configuration non trouvé : $config_script"
    exit 1
  fi

  # Validation des variables critiques définies par le script de configuration
  if [[ -z "${PROJECT_NAME:-}" || -z "${FRONTEND_PORT:-}" || -z "${BACKEND_PORT:-}" ]]; then
    print_error "Variables du projet non définies (PROJECT_NAME, FRONTEND_PORT, BACKEND_PORT)"
    exit 1
  fi

  # Étape 2 : Génération de la structure du projet
  # - Crée l'arborescence des dossiers
  # - Génère les fichiers de configuration
  execute_step "2" "Génération de la structure" \
    "$SCRIPT_DIR/parts/02_generate_project.sh" \
    "$PROJECT_NAME" "$USER_CWD" "$FRONTEND_PORT" "$BACKEND_PORT"

  # Étape 3 : Installation des dépendances
  # - Installe les packages npm pour le frontend et backend
  # - Configure les outils de développement
  execute_step "3" "Installation des dépendances" \
    "$SCRIPT_DIR/parts/03_install_deps.sh" \
    "$PROJECT_NAME" "$USER_CWD" "$FRONTEND_PORT" "$BACKEND_PORT"

  # Étape 4 : Configuration de Prisma
  # - Initialise la base de données
  # - Génère les modèles Prisma
  # - Lance les migrations initiales
  execute_step "4" "Traitement de Prisma" \
    "$SCRIPT_DIR/parts/04_handle_prisma.sh" \
    "$PROJECT_NAME" "$USER_CWD" "$FRONTEND_PORT" "$BACKEND_PORT"

  # Étape 5 (hors orchestrateur) : Finalisation
  clear
  show_banner
  print_section_header "[Étape 5] ✅ Message de fin"

  DONE_SCRIPT="$SCRIPT_DIR/parts/05_done.sh"

  if [[ -f "$DONE_SCRIPT" ]]; then
    bash "$DONE_SCRIPT" "$PROJECT_NAME" "$FRONTEND_PORT" "$BACKEND_PORT"
  else
    print_error "Script de fin non trouvé : $DONE_SCRIPT"
    exit 1
  fi
}

# =============================================================================
# POINT D'ENTRÉE
# Exécute la fonction principale uniquement si ce script est appelé directement
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
