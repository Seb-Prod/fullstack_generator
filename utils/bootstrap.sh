#!/bin/bash

# Définir PARENT_DIR si non défini (remonte au dossier racine du projet)
if [[ -z "${PARENT_DIR:-}" ]]; then
  PARENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# Import des utilitaires (une seule fois)
source "$PARENT_DIR/utils/print_utils.sh"
source "$PARENT_DIR/utils/template_engine.sh"
source "$PARENT_DIR/utils/banner.sh"

