#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../colors.sh"

# Fonction de validation du nom de projet
validate_project_name() {
    local name="$1"
    [[ "$name" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]] && [[ ${#name} -ge 3 ]] && [[ ! -d "$name" ]]
}

# Fonction de validation des ports
validate_port() {
    local port="$1"
    # Vérifier que c'est un nombre entre 1024 et 65535
    if [[ "$port" =~ ^[0-9]+$ ]] && [[ $port -ge 1024 ]] && [[ $port -le 65535 ]]; then
        # Vérifier que le port n'est pas déjà utilisé
        if ! lsof -i ":$port" >/dev/null 2>&1; then
            return 0
        else
            echo -e "${YELLOW}⚠️ Le port $port est déjà utilisé${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Port invalide (doit être entre 1024 et 65535)${NC}"
        return 1
    fi
}

# === SAISIE DU NOM DU PROJET ===
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

echo ""

# === SAISIE DU PORT FRONTEND ===
while true; do
    echo -e "${BLACK}${BOLD}🌐 Port pour le frontend (par défaut: 3000) :${NC}"
    echo -e "${YELLOW}   Tapez 'q' pour quitter${NC}"
    read -r FRONTEND_PORT
    
    # Vérifier si l'utilisateur veut quitter
    if [[ "$FRONTEND_PORT" == "q" ]] || [[ "$FRONTEND_PORT" == "quit" ]]; then
        echo -e "${YELLOW}👋 Annulation du script...${NC}"
        exit 0
    fi
    
    # Utiliser la valeur par défaut si vide
    FRONTEND_PORT=${FRONTEND_PORT:-3000}
    
    if validate_port "$FRONTEND_PORT"; then
        echo -e "${BLUE}${BOLD}🌐 Port frontend : ${GREEN}$FRONTEND_PORT${NC}"
        break
    else
        echo
    fi
done

echo ""

# === SAISIE DU PORT BACKEND ===
while true; do
    echo -e "${BLACK}${BOLD}⚙️ Port pour le backend (par défaut: 5000) :${NC}"
    echo -e "${YELLOW}   Tapez 'q' pour quitter${NC}"
    read -r BACKEND_PORT
    
    # Vérifier si l'utilisateur veut quitter
    if [[ "$BACKEND_PORT" == "q" ]] || [[ "$BACKEND_PORT" == "quit" ]]; then
        echo -e "${YELLOW}👋 Annulation du script...${NC}"
        exit 0
    fi
    
    # Utiliser la valeur par défaut si vide
    BACKEND_PORT=${BACKEND_PORT:-5000}
    
    if validate_port "$BACKEND_PORT"; then
        # Vérifier que les ports sont différents
        if [[ "$BACKEND_PORT" == "$FRONTEND_PORT" ]]; then
            echo -e "${RED}❌ Le port backend doit être différent du port frontend${NC}"
            echo
            continue
        fi
        echo -e "${BLUE}${BOLD}⚙️ Port backend : ${GREEN}$BACKEND_PORT${NC}"
        break
    else
        echo
    fi
done

echo ""

# Confirmation
echo -e "${GREEN}${BOLD}📋 Récapitulatif :${NC}"
echo -e "   📁 Projet : ${BLUE}${BOLD}$PROJECT_NAME${NC}"
echo -e "   🌐 Frontend : ${BLUE}${BOLD}http://localhost:$FRONTEND_PORT${NC}"
echo -e "   ⚙️ Backend : ${BLUE}${BOLD}http://localhost:$BACKEND_PORT${NC}"
echo ""

# Exporter les variables pour les autres scripts
export PROJECT_NAME
export FRONTEND_PORT
export BACKEND_PORT