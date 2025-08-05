#!/bin/bash

# Gestion des erreurs et nettoyage

cleanup_on_error() {
    local exit_code=$?

    if [[ $exit_code -ne 0 && -n "${PROJECT_NAME:-}" ]]; then
        echo -e "${RED}${BOLD}❌ Erreur détectée ! Nettoyage en cours...${NC}" >&2

        if [[ -d "$PROJECT_NAME" ]]; then
            echo -e "${YELLOW}🧹 Suppression du projet incomplet : $PROJECT_NAME${NC}"
            rm -rf "$PROJECT_NAME"
        fi

        echo -e "${RED}💥 Création du projet annulée.${NC}" >&2
    fi

    # Retourner au répertoire initial
    cd "$INITIAL_DIR" 2>/dev/null || true

    exit $exit_code
}