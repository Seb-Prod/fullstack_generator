#!/bin/bash

# =============================================================================
# Script: parts/01_ask_project_informations.sh
# Générateur de projet Fullstack TypeScript - Collecte des informations
# Seb-Prod 2025
# 
# Description:
#   Collecte de manière interactive les informations nécessaires à la création
#   d'un projet fullstack TypeScript :
#   - Nom du projet (avec validation de format et unicité)
#   - Port du serveur frontend (avec vérification de disponibilité)
#   - Port du serveur backend (avec vérification de disponibilité et unicité)
# 
# Variables exportées:
#   PROJECT_NAME   - Nom du projet validé
#   FRONTEND_PORT  - Port du serveur frontend disponible
#   BACKEND_PORT   - Port du serveur backend disponible (différent du frontend)
# 
# Dépendances:
#   - lsof (pour vérifier la disponibilité des ports)
#   - Fonctions utilitaires : print_*, prompt_*, clear_lines
# 
# Variables d'environnement:
#   DEBUG - Si défini à "1", affiche les variables exportées
# =============================================================================

# =============================================================================
# CONSTANTES DE VALIDATION
# =============================================================================

readonly MIN_PORT=1024              # Port minimum autorisé (évite les ports système)
readonly MAX_PORT=65535             # Port maximum autorisé
readonly MIN_PROJECT_NAME_LENGTH=3  # Longueur minimale du nom de projet
readonly MAX_VALIDATION_ATTEMPTS=3  # Nombre maximum de tentatives par champ

# =============================================================================
# FONCTIONS DE VALIDATION
# Valident les entrées utilisateur selon des critères stricts
# =============================================================================

# Valide le nom du projet
# - Doit commencer par une lettre
# - Contenir uniquement lettres, chiffres, tirets et underscores
# - Avoir au moins 3 caractères
# - Ne pas correspondre à un dossier existant
#
# Arguments:
#   $1 - Nom du projet à valider
# Returns:
#   0 si valide, 1 si invalide
validate_project_name() {
    local name="$1"
    
    # Vérification du format : doit commencer par une lettre, 3+ caractères
    if ! [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]{2,}$ ]]; then
        return 1
    fi
    
    # Vérification que le dossier n'existe pas déjà
    if [[ -d "$name" ]]; then
        return 1
    fi
    
    return 0
}

# Valide un numéro de port
# - Doit être un nombre entier
# - Dans la plage 1024-65535
# - Ne pas être déjà utilisé par un autre processus
#
# Arguments:
#   $1 - Numéro de port à valider
# Returns:
#   0 si valide, 1 si invalide
validate_port() {
    local port="$1"
    
    # Vérification que c'est un nombre
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    
    # Vérification de la plage de ports autorisée
    if (( port < MIN_PORT || port > MAX_PORT )); then
        return 1
    fi
    
    # Vérification que le port n'est pas déjà utilisé
    if lsof -i ":$port" >/dev/null 2>&1; then
        return 1
    fi
    
    return 0
}

# Valide que deux ports sont différents
#
# Arguments:
#   $1 - Premier port
#   $2 - Deuxième port
# Returns:
#   0 si différents, 1 si identiques
validate_different_ports() {
    [[ "$1" != "$2" ]]
}

# =============================================================================
# FONCTIONS D'AFFICHAGE ET INTERFACE UTILISATEUR
# =============================================================================

# Affiche un récapitulatif du projet configuré
# Utilise les variables globales PROJECT_NAME, FRONTEND_PORT, BACKEND_PORT
show_project_summary() {
    clear_lines 5
    print_plain "$GREEN" "📋 Récapitulatif du projet :"
    print_plain "$BLUE" "   📁 Nom      : $PROJECT_NAME"
    print_plain "$BLUE" "   🌐 Frontend : http://localhost:$FRONTEND_PORT"
    print_plain "$BLUE" "   ⚙️  Backend  : http://localhost:$BACKEND_PORT"
    echo ""
}

# Affiche les conseils de validation pour guider l'utilisateur
show_validation_tips() {
    print_tips "Conseils de saisie :"
    print_plain "$YELLOW" "   • Nom du projet : doit commencer par une lettre (${MIN_PROJECT_NAME_LENGTH}+ caractères)"
    print_plain "$YELLOW" "   • Ports : doivent être entre $MIN_PORT et $MAX_PORT"
    print_plain "$YELLOW" "   • Vérifiez que les ports ne sont pas déjà utilisés"
    print_plain "$YELLOW" "   • Les deux ports doivent être différents"
    echo ""
}

# Affiche des exemples de noms de projet valides
show_project_name_examples() {
    print_info "Exemples de noms valides :"
    print_plain "$CYAN" "   • mon-app-web, MyProject, todo-app-v2"
    echo ""
}

# Affiche des suggestions de ports couramment utilisés
show_port_suggestions() {
    local port_type="$1"  # "frontend" ou "backend"
    
    case "$port_type" in
        "frontend")
            print_info "Ports frontend courants : 3000, 3001, 8080, 8081"
            ;;
        "backend")
            print_info "Ports backend courants : 5000, 8000, 3001, 4000"
            ;;
    esac
    echo ""
}

# =============================================================================
# COLLECTE DES INFORMATIONS UTILISATEUR
# Processus interactif de saisie avec validation en temps réel
# =============================================================================

# Collecte toutes les informations nécessaires au projet
# Définit les variables globales : PROJECT_NAME, FRONTEND_PORT, BACKEND_PORT
collect_project_info() {
    local attempts=0
    
    show_validation_tips
    
    # === COLLECTE DU NOM DU PROJET ===
    show_project_name_examples
    
    while true; do
        prompt_input "💡 Nom du projet" "mon-projet-fullstack" validate_project_name \
                    "❌ Nom invalide ou dossier existant" $MAX_VALIDATION_ATTEMPTS
        PROJECT_NAME="$PROMPT_RESULT"
        
        if validate_project_name "$PROJECT_NAME"; then
            clear_lines 3
            print_success "Nom du projet validé : $PROJECT_NAME"
            echo ""
            break
        fi
        
        # Si on arrive ici, c'est que la validation a échoué
        show_project_name_examples
    done
    
    # === COLLECTE DU PORT FRONTEND ===
    show_port_suggestions "frontend"
    
    while true; do
        prompt_input "🌐 Port pour le frontend" "3000" validate_port \
                    "❌ Port invalide ou déjà utilisé (plage: $MIN_PORT-$MAX_PORT)" $MAX_VALIDATION_ATTEMPTS
        FRONTEND_PORT="$PROMPT_RESULT"
        
        if validate_port "$FRONTEND_PORT"; then
            clear_lines 3
            print_success "Port frontend validé : $FRONTEND_PORT"
            echo ""
            break
        fi
        
        # Réafficher les suggestions en cas d'échec
        show_port_suggestions "frontend"
    done
    
    # === COLLECTE DU PORT BACKEND ===
    show_port_suggestions "backend"
    
    while true; do
        prompt_input "⚙️  Port pour le backend" "5000" validate_port \
                    "❌ Port invalide ou déjà utilisé"
        BACKEND_PORT="$PROMPT_RESULT"
        
        # Validation du format et disponibilité du port
        if ! validate_port "$BACKEND_PORT"; then
            clear_lines 3
            show_port_suggestions "backend"
            continue
        fi
        
        # Validation que les ports sont différents
        if ! validate_different_ports "$FRONTEND_PORT" "$BACKEND_PORT"; then
            print_error "Le port backend doit être différent du port frontend ($FRONTEND_PORT)"
            clear_lines 4 1.5
            show_port_suggestions "backend"
            continue
        fi
        clear_lines 3
        print_success "Port backend validé : $BACKEND_PORT"
        echo ""
        break
    done
}

# =============================================================================
# CONFIRMATION ET EXPORT DES VARIABLES
# =============================================================================

# Affiche le récapitulatif final et demande confirmation
# Exporte les variables pour les scripts suivants
confirm_and_export() {
    print_section_header "📋 Confirmation de la configuration"
    show_project_summary
    
    # Export des variables pour les autres scripts
    export PROJECT_NAME
    export FRONTEND_PORT  
    export BACKEND_PORT
    
    # Demande de confirmation finale
    prompt_continue "🚀 Voulez-vous lancer la création du projet avec cette configuration ?"
    
    print_success "🚀 Configuration validée ! Démarrage de la création du projet..."
    clear_lines 3
}

# =============================================================================
# FONCTIONS DE DEBUG ET DIAGNOSTIC
# =============================================================================

# Affiche les variables exportées si le mode debug est activé
show_debug_info() {
    if [[ "${DEBUG:-}" == "1" ]]; then
        print_section_header "🔍 Informations de debug"
        print_info "Variables exportées :"
        print_info "  PROJECT_NAME='$PROJECT_NAME'"
        print_info "  FRONTEND_PORT='$FRONTEND_PORT'"
        print_info "  BACKEND_PORT='$BACKEND_PORT'"
        print_info "  Working directory: $(pwd)"
        echo ""
    fi
}

# Vérifie les prérequis système nécessaires
check_prerequisites() {
    local missing_deps=()
    
    # Vérification de lsof pour la validation des ports
    if ! command -v lsof >/dev/null 2>&1; then
        missing_deps+=("lsof")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_warning "⚠️  Dépendances manquantes détectées :"
        for dep in "${missing_deps[@]}"; do
            print_plain "$YELLOW" "   • $dep"
        done
        print_info "La validation des ports pourrait être imprécise."
        echo ""
    fi
}

# =============================================================================
# FONCTION PRINCIPALE
# Orchestre le processus complet de collecte d'informations
# =============================================================================

main() {
    # Vérification des prérequis
    check_prerequisites
    
    # Collecte interactive des informations
    collect_project_info
    
    # Confirmation et export des variables
    confirm_and_export
    
    # Affichage des informations de debug si activé
    show_debug_info
}

# =============================================================================
# POINT D'ENTRÉE
# =============================================================================

# Exécution de la fonction principale avec tous les arguments
main "$@"