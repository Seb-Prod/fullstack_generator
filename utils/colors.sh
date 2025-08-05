#!/bin/bash

# =============================================================================
# Fichier: utils/colors.sh
# Définition des couleurs et formats pour les scripts
# =============================================================================

# =============================================================================
# COULEURS DE TEXTE STANDARD
# =============================================================================
BLACK='\033[0;30m'




MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
LIGHTYELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTMAGENTA='\033[1;35m'
LIGHTCYAN='\033[1;36m'
LIGHTWHITE='\033[1;37m'

# =============================================================================
# COULEURS D'ARRIÈRE-PLAN
# =============================================================================
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# =============================================================================
# FORMATS DE TEXTE
# =============================================================================
BOLD='\033[1m'
FAINT='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
INVERT='\033[7m'
HIDDEN='\033[8m'

# =============================================================================
# RÉINITIALISATION
# =============================================================================


# =============================================================================
# ALIAS POUR COMPATIBILITÉ (utilisés dans les scripts)
# =============================================================================
GRAY="$DARKGRAY"          # Alias pour GRAY
GREY="$DARKGRAY"          # Alias alternatif

# =============================================================================
# FONCTIONS UTILITAIRES DE COULEURS
# =============================================================================

# Fonction pour colorer un texte
colorize() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${NC}"
}

# Fonctions de raccourci pour les couleurs courantes
print_red() {
    echo -e "${RED}$1${NC}"
}

print_green() {
    echo -e "${GREEN}$1${NC}"
}

print_blue() {
    echo -e "${BLUE}$1${NC}"
}

print_yellow() {
    echo -e "${YELLOW}$1${NC}"
}

print_bold() {
    echo -e "${BOLD}$1${NC}"
}

# Fonction pour afficher du texte avec couleur et format
print_styled() {
    local style="$1"
    local color="$2"
    local text="$3"
    echo -e "${style}${color}${text}${NC}"
}

# =============================================================================
# FONCTIONS DE MESSAGE THÉMATIQUES
# =============================================================================

# Messages de succès
success() {
    echo -e "${GREEN}${BOLD}✅ $1${NC}"
}

# Messages d'erreur
error() {
    echo -e "${RED}${BOLD}❌ $1${NC}" >&2
}

# Messages d'avertissement
warning() {
    echo -e "${YELLOW}${BOLD}⚠️ $1${NC}" >&2
}

# Messages d'information
info() {
    echo -e "${BLUE}${BOLD}ℹ️ $1${NC}"
}

# Messages de debug
debug() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        echo -e "${DARKGRAY}🐛 DEBUG: $1${NC}" >&2
    fi
}

# =============================================================================
# FONCTIONS DE BANNIÈRE ET SÉPARATEURS
# =============================================================================

# Afficher un séparateur
separator() {
    local char="${1:--}"
    local length="${2:-50}"
    local color="${3:-$BLUE}"
    
    printf "${color}"
    printf "%*s\n" "$length" | tr ' ' "$char"
    printf "${NC}"
}

# Afficher un titre encadré
title() {
    local text="$1"
    local color="${2:-$BLUE}"
    
    echo ""
    separator "=" 60 "$color"
    echo -e "${color}${BOLD} $text ${NC}"
    separator "=" 60 "$color"
    echo ""
}

# Afficher un sous-titre
subtitle() {
    local text="$1"
    local color="${2:-$CYAN}"
    
    echo ""
    echo -e "${color}${BOLD}─── $text ───${NC}"
    echo ""
}

print_section_header() {
    local title="$1"
    echo "$(tput setaf 4)$(tput bold)$title$(tput sgr0)"
    echo "--------------------------------------------------------"
}

# =============================================================================
# EXPORT DES VARIABLES POUR LES SOUS-SCRIPTS
# =============================================================================

# Exporter toutes les couleurs pour qu'elles soient disponibles dans les sous-scripts
export BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE
export LIGHTGRAY DARKGRAY LIGHTRED LIGHTGREEN LIGHTYELLOW
export LIGHTBLUE LIGHTMAGENTA LIGHTCYAN LIGHTWHITE
export BG_BLACK BG_RED BG_GREEN BG_YELLOW BG_BLUE BG_MAGENTA BG_CYAN BG_WHITE
export BOLD FAINT ITALIC UNDERLINE BLINK INVERT HIDDEN
export NC GRAY GREY

# =============================================================================
# TEST DES COULEURS (fonction optionnelle)
# =============================================================================

# Fonction pour tester l'affichage des couleurs
test_colors() {
    echo "=== Test des couleurs ==="
    echo ""
    
    echo "Couleurs standard :"
    print_red "● Rouge"
    print_green "● Vert" 
    print_blue "● Bleu"
    print_yellow "● Jaune"
    echo -e "${MAGENTA}● Magenta${NC}"
    echo -e "${CYAN}● Cyan${NC}"
    echo ""
    
    echo "Formats :"
    echo -e "${BOLD}● Gras${NC}"
    echo -e "${UNDERLINE}● Souligné${NC}"
    echo -e "${ITALIC}● Italique${NC}"
    echo ""
    
    echo "Messages thématiques :"
    success "Message de succès"
    error "Message d'erreur"
    warning "Message d'avertissement"
    info "Message d'information"
    debug "Message de debug (si DEBUG=1)"
    echo ""
    
    title "Titre principal"
    subtitle "Sous-titre"
}

# Fonction pour réinitialiser les couleurs du terminal
reset_terminal() {
    echo -e "${NC}"
    tput sgr0 2>/dev/null || true
}