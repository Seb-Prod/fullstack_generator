#!/bin/bash

# =============================================================================
# Fonctions utilitaires pour l'affichage formaté
# Seb-Prod 2025
# =============================================================================

# Couleurs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'
readonly BLACK='\033[0;30m'

# -----------------------------------------------------------------------------
# Messages génériques
# -----------------------------------------------------------------------------

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}" >&2
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

print_debug() {
  echo -e "\n${BLUE}📢  $1${NC}"
}

print_step_header() {
  echo -e "\n${BLUE}$1${NC}"
}

print_section_header() {
  echo -e "\n${BLUE}========================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================${NC}\n"
}

print_plain() {
  local color="$1"
  local message="$2"
  echo -e "${color}${message}${NC}"
}

clear_lines() {
    local lines="$1"
    local time="${2:-0}"
    sleep "$time"
    for ((i=0; i<lines; i++)); do
        echo -ne "\033[1A\033[2K"  # Remonter d'une ligne et l'effacer
    done
}