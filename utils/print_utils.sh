#!/bin/bash
# =============================================================================
# Utilitaires d'affichage formaté - Système de logging et couleurs
# Seb-Prod 2025
# 
# Description:
#   Fournit un système complet d'affichage formaté avec couleurs ANSI,
#   icônes Unicode et fonctionnalités avancées pour les scripts bash
# 
# Fonctions principales:
#   print_success()        - Message de succès (vert)
#   print_error()          - Message d'erreur (rouge, stderr)
#   print_warning()        - Message d'avertissement (jaune)
#   print_info()           - Message informatif (cyan)
#   print_tips()           - Conseil/astuce (jaune)
#   print_debug()          - Message de debug (bleu)
#   print_step_header()    - En-tête d'étape
#   print_section_header() - En-tête de section avec séparateurs
#   print_plain()          - Affichage avec couleur personnalisée
#   clear_lines()          - Effacement de lignes pour animations
# 
# Variables exportées:
#   RED, GREEN, YELLOW, BLUE, CYAN, BLACK, NC, BOLD - Codes couleur ANSI
# =============================================================================

# =============================================================================
# DÉFINITION DES COULEURS ANSI
# Codes d'échappement pour le formatage terminal
# =============================================================================

readonly RED='\033[0;31m'       # Rouge standard
readonly GREEN='\033[0;32m'     # Vert standard
readonly YELLOW='\033[1;33m'    # Jaune bold
readonly BLUE='\033[0;34m'      # Bleu standard
readonly CYAN='\033[0;36m'      # Cyan standard
readonly BLACK='\033[0;30m'     # Noir standard
readonly BOLD='\033[1m'         # Texte en gras
readonly NC='\033[0m'           # Reset - Pas de couleur

# Couleurs supplémentaires pour usage avancé
readonly MAGENTA='\033[0;35m'   # Magenta
readonly WHITE='\033[1;37m'     # Blanc bold
readonly GRAY='\033[0;37m'      # Gris
readonly DIM='\033[2m'          # Texte atténué

# Couleurs de fond (pour mise en évidence spéciale)
readonly BG_RED='\033[41m'      # Fond rouge
readonly BG_GREEN='\033[42m'    # Fond vert
readonly BG_YELLOW='\033[43m'   # Fond jaune

# =============================================================================
# MESSAGES TYPÉS - INTERFACE PRINCIPALE
# Fonctions d'affichage avec formatage automatique
# =============================================================================

# Message de succès avec icône verte
print_success() {
    [[ $# -eq 0 ]] && { echo "Usage: print_success <message>" >&2; return 1; }
    echo -e "${GREEN}✅ $1${NC}"
}

# Message d'erreur avec icône rouge (stderr)
print_error() {
    [[ $# -eq 0 ]] && { echo "Usage: print_error <message>" >&2; return 1; }
    echo -e "${RED}❌ $1${NC}" >&2
}

# Message d'avertissement avec icône jaune
print_warning() {
    [[ $# -eq 0 ]] && { echo "Usage: print_warning <message>" >&2; return 1; }
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Message informatif avec icône cyan
print_info() {
    [[ $# -eq 0 ]] && { echo "Usage: print_info <message>" >&2; return 1; }
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Message de conseil avec icône ampoule
print_tips() {
    [[ $# -eq 0 ]] && { echo "Usage: print_tips <message>" >&2; return 1; }
    echo -e "${YELLOW}💡 $1${NC}"
}

# Message de debug avec icône mégaphone
print_debug() {
    [[ $# -eq 0 ]] && { echo "Usage: print_debug <message>" >&2; return 1; }
    echo -e "\n${BLUE}📢 $1${NC}"
}

# En-tête d'étape simple
print_step_header() {
    [[ $# -eq 0 ]] && { echo "Usage: print_step_header <message>" >&2; return 1; }
    echo -e "\n${BLUE}$1${NC}"
}

# En-tête de section avec séparateurs visuels
print_section_header() {
    [[ $# -eq 0 ]] && { echo "Usage: print_section_header <message>" >&2; return 1; }
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# =============================================================================
# FONCTIONS D'AFFICHAGE AVANCÉES
# Utilitaires pour formatage personnalisé et animations
# =============================================================================

# Affichage avec couleur personnalisée
# Usage: print_plain "$RED" "Mon message"
print_plain() {
    [[ $# -ne 2 ]] && { echo "Usage: print_plain <color> <message>" >&2; return 1; }
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Affichage centré avec largeur spécifiée
print_centered() {
    [[ $# -lt 1 || $# -gt 2 ]] && { echo "Usage: print_centered <message> [width]" >&2; return 1; }
    local message="$1"
    local width="${2:-80}"
    local padding=$(( (width - ${#message}) / 2 ))
    printf "%*s%s\n" $padding "" "$message"
}

# Effacement de lignes avec délai optionnel
# Usage: clear_lines <nombre_de_lignes> [délai_en_secondes]
clear_lines() {
    [[ $# -eq 0 ]] && { echo "Usage: clear_lines <lines> [delay]" >&2; return 1; }
    local lines="$1"
    local delay="${2:-0}"
    
    # Validation du nombre de lignes
    [[ ! "$lines" =~ ^[0-9]+$ ]] && { 
        echo "Erreur: Nombre de lignes invalide: $lines" >&2
        return 1
    }
    
    [[ "$delay" != "0" ]] && sleep "$delay"
    
    for ((i=0; i<lines; i++)); do
        echo -ne "\033[1A\033[2K"  # Remonter d'une ligne et l'effacer
    done
}

# =============================================================================
# FONCTIONS UTILITAIRES SPÉCIALISÉES
# Outils pour cas d'usage spécifiques
# =============================================================================

# Affichage de progression avec barre
print_progress() {
    [[ $# -ne 3 ]] && { echo "Usage: print_progress <current> <total> <message>" >&2; return 1; }
    local current="$1"
    local total="$2"
    local message="$3"
    local percent=$((current * 100 / total))
    local bar_length=30
    local filled=$((current * bar_length / total))
    
    printf "\r${CYAN}[%-${bar_length}s] %d%% %s${NC}" \
        "$(printf "%${filled}s" | tr ' ' '=')" \
        "$percent" \
        "$message"
}

# Message de confirmation avec choix oui/non
print_confirm() {
    [[ $# -eq 0 ]] && { echo "Usage: print_confirm <message>" >&2; return 1; }
    echo -e "${YELLOW}❓ $1 ${BOLD}(o/N)${NC}"
}

# Séparateur visuel personnalisable
print_separator() {
    local char="${1:-=}"
    local length="${2:-50}"
    local color="${3:-$BLUE}"
    
    printf "${color}"
    for ((i=0; i<length; i++)); do
        printf "%s" "$char"
    done
    printf "${NC}\n"
}

# =============================================================================
# FONCTIONS DE VALIDATION
# Vérification de l'environnement terminal
# =============================================================================

# Vérification du support des couleurs
supports_color() {
    [[ -t 1 && -n "${TERM:-}" && "$TERM" != "dumb" ]]
}

# =============================================================================
# INITIALISATION AUTOMATIQUE
# Configuration selon l'environnement
# =============================================================================

# Auto-détection et configuration lors du chargement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script exécuté directement - mode test
    echo "=== Test des fonctions d'affichage ==="
    disable_colors_if_needed
    
    print_success "Message de succès"
    print_error "Message d'erreur"
    print_warning "Message d'avertissement"
    print_info "Message informatif"
    print_tips "Conseil utile"
    print_debug "Message de debug"
    print_section_header "[Test] Section de test"
    print_plain "$MAGENTA" "Message avec couleur personnalisée"
    print_separator "-" 40 "$GREEN"
    print_confirm "Continuer le test ?"
fi