#!/bin/bash
# =============================================================================
# Utilitaire de validation - Arguments et répertoire de travail
# Seb-Prod 2025
# 
# Description:
#   Valide les arguments du script et définit le répertoire de travail.
#   Effectue les vérifications de sécurité et d'accessibilité nécessaires.
# 
# Fonctions:
#   set_working_dir()     - Définit et valide le répertoire de travail
#   validate_directory()  - Valide un répertoire spécifique
#   show_usage()         - Affiche l'aide d'utilisation
# 
# Variables exportées:
#   USER_CWD     - Répertoire de travail validé (readonly)
#   INITIAL_DIR  - Répertoire initial de lancement (readonly)
# 
# Dépendances:
#   - print_utils.sh (optionnel, pour messages formatés)
# =============================================================================

# =============================================================================
# FONCTION PRINCIPALE - DÉFINITION DU RÉPERTOIRE DE TRAVAIL
# Valide les arguments et définit le répertoire de travail sécurisé
# 
# Arguments:
#   $1 (optionnel) - Répertoire de travail cible
# 
# Returns:
#   0 si succès, 1 en cas d'erreur
# 
# Examples:
#   set_working_dir                    # Utilise le répertoire courant
#   set_working_dir "/path/to/project" # Utilise le répertoire spécifié
#   set_working_dir "~/projects"       # Résout le chemin utilisateur
# =============================================================================

set_working_dir() {
    # Validation du nombre d'arguments
    if [[ $# -gt 1 ]]; then
        show_usage
        return 1
    fi

    # Définition du répertoire cible avec résolution du chemin
    local target_dir="${1:-$(pwd)}"
    
    # Expansion du tilde (~) si présent
    target_dir="${target_dir/#\~/$HOME}"
    
    # Résolution du chemin absolu (gère les chemins relatifs)
    if ! target_dir="$(realpath "$target_dir" 2>/dev/null)"; then
        print_error_safe "Impossible de résoudre le chemin : '$1'"
        return 1
    fi

    # Validation complète du répertoire
    if ! validate_directory "$target_dir"; then
        return 1
    fi

    # Définition des variables globales (readonly pour sécurité)
    readonly USER_CWD="$target_dir"
    readonly INITIAL_DIR="$(pwd)"

    # Message de confirmation si print_utils disponible
    if command -v print_success &>/dev/null; then
        print_success "Répertoire de travail configuré : $USER_CWD"
    fi

    return 0
}

# =============================================================================
# FONCTION DE VALIDATION - RÉPERTOIRE SPÉCIFIQUE
# Effectue toutes les vérifications nécessaires sur un répertoire
# 
# Arguments:
#   $1 - Chemin du répertoire à valider
# 
# Returns:
#   0 si valide, 1 sinon
# =============================================================================

validate_directory() {
    [[ $# -ne 1 ]] && { 
        print_error_safe "validate_directory: argument manquant"
        return 1 
    }

    local dir="$1"

    # Vérification 1 : Le chemin existe
    if [[ ! -e "$dir" ]]; then
        print_error_safe "Le répertoire '$dir' n'existe pas"
        return 1
    fi

    # Vérification 2 : C'est bien un répertoire (pas un fichier)
    if [[ ! -d "$dir" ]]; then
        print_error_safe "'$dir' n'est pas un répertoire"
        return 1
    fi

    # Vérification 3 : Répertoire accessible en lecture
    if [[ ! -r "$dir" ]]; then
        print_error_safe "Pas de permission de lecture pour '$dir'"
        return 1
    fi

    # Vérification 4 : Répertoire accessible en écriture
    if [[ ! -w "$dir" ]]; then
        print_error_safe "Pas de permission d'écriture pour '$dir'"
        return 1
    fi

    # Vérification 5 : Répertoire accessible en exécution (traversable)
    if [[ ! -x "$dir" ]]; then
        print_error_safe "Pas de permission d'exécution pour '$dir'"
        return 1
    fi

    # Vérification 6 : Espace disque disponible (au moins 100MB)
    local available_space
    if available_space=$(df "$dir" 2>/dev/null | awk 'NR==2 {print $4}'); then
        # Conversion en MB (les valeurs df sont en KB sur la plupart des systèmes)
        local available_mb=$((available_space / 1024))
        if [[ $available_mb -lt 100 ]]; then
            print_warning_safe "Espace disque faible : ${available_mb}MB disponibles dans '$dir'"
        fi
    fi

    return 0
}

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

# Affichage de l'aide d'utilisation
show_usage() {
    cat << EOF
Usage: $(basename "${BASH_SOURCE[1]:-$0}") [RÉPERTOIRE]

Description:
  Configure le répertoire de travail pour la génération de projet.
  
Arguments:
  RÉPERTOIRE    Répertoire cible (optionnel)
                Défaut: répertoire courant
                
Exemples:
  $(basename "${BASH_SOURCE[1]:-$0}")                        # Répertoire courant
  $(basename "${BASH_SOURCE[1]:-$0}") /home/user/projets     # Répertoire spécifique
  $(basename "${BASH_SOURCE[1]:-$0}") ~/projets              # Avec expansion ~
  $(basename "${BASH_SOURCE[1]:-$0}") ../parent              # Chemin relatif

Prérequis:
  - Répertoire accessible en lecture, écriture et exécution
  - Au moins 100MB d'espace disque disponible (recommandé)
EOF
}

# Messages d'erreur sécurisés (sans dépendance print_utils)
print_error_safe() {
    if command -v print_error &>/dev/null; then
        print_error "$1"
    else
        echo "❌ Erreur: $1" >&2
    fi
}

# Messages d'avertissement sécurisés
print_warning_safe() {
    if command -v print_warning &>/dev/null; then
        print_warning "$1"
    else
        echo "⚠️  Avertissement: $1" >&2
    fi
}

# =============================================================================
# FONCTION DE NETTOYAGE
# Restaure le répertoire initial en cas d'erreur
# =============================================================================

restore_initial_directory() {
    if [[ -n "${INITIAL_DIR:-}" && -d "$INITIAL_DIR" ]]; then
        cd "$INITIAL_DIR" || {
            echo "⚠️  Impossible de retourner au répertoire initial: $INITIAL_DIR" >&2
            return 1
        }
    fi
}

# =============================================================================
# FONCTIONS DE VALIDATION ÉTENDUES
# Pour cas d'usage spécifiques
# =============================================================================

# Validation d'un répertoire pour création de projet
validate_project_directory() {
    [[ $# -ne 1 ]] && return 1
    
    local dir="$1"
    
    # Validation de base
    validate_directory "$dir" || return 1
    
    # Vérifications spécifiques aux projets
    
    # Le répertoire ne doit pas contenir de projet existant
    if [[ -f "$dir/package.json" ]] || [[ -f "$dir/pom.xml" ]] || [[ -f "$dir/Cargo.toml" ]]; then
        print_warning_safe "Le répertoire '$dir' semble déjà contenir un projet"
        return 1
    fi
    
    # Vérification des outils requis
    local missing_tools=()
    command -v node >/dev/null || missing_tools+=("Node.js")
    command -v npm >/dev/null || missing_tools+=("npm")
    command -v git >/dev/null || missing_tools+=("git")
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_error_safe "Outils manquants : ${missing_tools[*]}"
        return 1
    fi
    
    return 0
}

# =============================================================================
# MODE TEST (si exécuté directement)
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Test de validation des arguments ==="
    
    # Test 1: Répertoire courant
    echo "Test 1: Répertoire courant"
    if set_working_dir; then
        echo "✅ USER_CWD: $USER_CWD"
        echo "✅ INITIAL_DIR: $INITIAL_DIR"
    else
        echo "❌ Échec du test 1"
    fi
    
    # Test 2: Répertoire invalide
    echo -e "\nTest 2: Répertoire invalide"
    if set_working_dir "/répertoire/inexistant" 2>/dev/null; then
        echo "❌ Le test aurait dû échouer"
    else
        echo "✅ Validation d'erreur correcte"
    fi
    
    # Test 3: Aide
    echo -e "\nTest 3: Affichage de l'aide"
    set_working_dir "arg1" "arg2" 2>/dev/null || echo "✅ Usage affiché correctement"
fi