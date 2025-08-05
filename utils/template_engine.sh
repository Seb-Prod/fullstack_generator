#!/bin/bash

# Fichier : utils/template_engine.sh

# ==========================
# --- Configuration ---
# ==========================

# Définir PARENT_DIR seulement s'il n'existe pas déjà
if [[ -z "${PARENT_DIR:-}" ]]; then
    readonly PARENT_DIR="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
fi

# =============================================================================
# --- Fonctions utilitaires ---
# =============================================================================

# Crée un fichier à partir d'un template simple (sans substitution de variables)
# Arguments :
#   $1 : Chemin relatif du template dans le répertoire 'templates/'
#   $2 : Chemin de destination du fichier
create_from_template() {
    local template_path="$1"      
    local destination="$2"        
    
    mkdir -p "$(dirname "$destination")"
    
    local full_template_path="$PARENT_DIR/templates/$template_path"
    
    if [[ ! -f "$full_template_path" ]]; then
        #echo -e "${RED}❌ Template non trouvé: $full_template_path${NC}" >&2
        return 1
    fi
    
    cp "$full_template_path" "$destination"
    
    if [[ $? -eq 0 ]]; then
        return 0
    else
        #echo -e "${RED}  ❌ Échec de la création du fichier : $destination${NC}" >&2
        return 1
    fi
}

# Crée un fichier à partir d'un template et remplace les variables.
# Arguments :
#   $1 : Chemin relatif du template dans le répertoire 'templates/'
#   $2 : Chemin de destination du fichier
#   $3 : Une chaîne de caractères contenant les paires "placeholder=valeur" à substituer.
process_template() {
    local template_path="$1"
    local destination="$2"
    local variables="$3"

    mkdir -p "$(dirname "$destination")"

    local full_template_path="$PARENT_DIR/templates/$template_path"

    if [[ ! -f "$full_template_path" ]]; then
        #echo -e "${RED}❌ Template non trouvé: $full_template_path${NC}" >&2
        return 1
    fi

    # Copie le template vers la destination
    cp "$full_template_path" "$destination"

    if [[ $? -ne 0 ]]; then
        #echo -e "${RED}❌ Échec de la copie du template pour traitement : $destination${NC}" >&2
        return 1
    fi

    # Déterminer la syntaxe de sed en fonction de l'OS
    local sed_i_option=""
    if [[ "$(uname)" == "Darwin" ]]; then
        sed_i_option="-i ''" # macOS (BSD sed)
    else
        sed_i_option="-i"    # Linux (GNU sed)
    fi

    # Boucle sur les variables pour les substituer
    local IFS=' '
    for var_pair in $variables; do
        local placeholder=$(echo "$var_pair" | cut -d'=' -f1)
        local value=$(echo "$var_pair" | cut -d'=' -f2)
        
        # Exécuter la commande sed
        # Utiliser eval pour permettre l'expansion de la variable sed_i_option
        eval "sed $sed_i_option 's|{{ $placeholder }}|$value|g' \"$destination\""
    done
    
    #echo -e "${GREEN}  ✅ Fichier traité et créé : $destination${NC}"
    return 0
}

# =============================================================================
# --- Exécution ---
# =============================================================================

# Pas d'exécution directe. Le script est conçu pour être sourcé.