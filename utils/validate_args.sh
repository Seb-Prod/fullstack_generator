# Fichier: utils/validate_args.sh
# Fonctions de validation des arguments et du répertoire de travail

# Définir le répertoire de travail
set_working_dir() {
    if [[ $# -gt 1 ]]; then
        echo "Usage: $0 [répertoire_de_travail]" >&2
        echo "Exemple: $0 /home/user/projets" >&2
        echo "Si aucun répertoire n'est spécifié, le répertoire courant sera utilisé" >&2
        exit 1
    fi

    readonly USER_CWD="${1:-$(pwd)}"
    readonly INITIAL_DIR="$(pwd)"

    # Vérifier que le répertoire de travail existe et est accessible
    if [[ ! -d "$USER_CWD" ]]; then
        echo "Erreur: Le répertoire '$USER_CWD' n'existe pas." >&2
        exit 1
    fi

    if [[ ! -w "$USER_CWD" ]]; then
        echo "Erreur: Pas de permission d'écriture dans '$USER_CWD'." >&2
        exit 1
    fi
}