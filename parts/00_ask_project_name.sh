#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

# Fonction de validation
validate_project_name() {
    local name="$1"
    [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]] && [[ ${#name} -ge 3 ]] && [[ ! -d "$name" ]]
}

# Saisie avec validation et possibilité de quitter
while true; do
    echo -e "${BLACK}${BOLD}💡 Entrez le nom du projet (par défaut: mon-projet-fullstack) :${NC}"
    echo -e "${YELLOW}   Tapez 'q' ou 'quit' pour quitter${NC}"
    read -r PROJECT_NAME
    
    # Vérifier si l'utilisateur veut quitter
    if [[ "$PROJECT_NAME" == "q" ]] || [[ "$PROJECT_NAME" == "quit" ]] || [[ "$PROJECT_NAME" == "exit" ]]; then
        echo -e "${YELLOW}👋 Annulation du script...${NC}"
        exit 0
    fi
    
    # Utiliser la valeur par défaut si vide
    PROJECT_NAME=${PROJECT_NAME:-mon-projet-fullstack}
    
    if validate_project_name "$PROJECT_NAME"; then
        echo -e "${BLUE}${BOLD}🚀 Nom du projet : ${GREEN}$PROJECT_NAME${NC}"
        break
    else
        echo -e "${RED}❌ Nom invalide ou dossier existant${NC}"
        echo
    fi
done

# Exporter la variable pour les autres scripts
export PROJECT_NAME