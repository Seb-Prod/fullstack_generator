#!/bin/bash
# =============================================================================
# Utilitaire d'exécution - Orchestrateur d'étapes de génération
# Seb-Prod 2025
#
# Description:
#   Orchestre l'exécution séquentielle des étapes de génération de projet.
#   Fournit une interface unifiée avec gestion d'erreurs, logging et monitoring.
#
# Fonctions:
#   execute_step()           - Exécute une étape avec gestion complète
#   execute_step_with_retry() - Exécute avec possibilité de retry
#   validate_step_params()   - Valide les paramètres d'une étape
#   log_step_execution()     - Log détaillé de l'exécution
#
# Variables d'environnement:
#   STEP_TIMEOUT    - Timeout par étape en secondes (défaut: 300)
#   STEP_LOG_DIR    - Répertoire des logs (défaut: /tmp/seb-prod-logs)
#   ENABLE_RETRY    - Active les retry automatiques (défaut: true)
#
# Dépendances:
#   - print_utils.sh (pour l'affichage formaté)
#   - banner.sh (pour show_banner)
# =============================================================================

# =============================================================================
# CONFIGURATION GLOBALE
# =============================================================================

# Répertoire de logs pour debug
readonly LOG_DIR="${STEP_LOG_DIR:-/tmp/seb-prod-logs}"

# Activation des retry par défaut
readonly ENABLE_RETRY="${ENABLE_RETRY:-true}"

# Compteurs globaux pour statistiques
TOTAL_STEPS_EXECUTED=0
TOTAL_STEPS_FAILED=0
TOTAL_EXECUTION_TIME=0

# =============================================================================
# FONCTION PRINCIPALE - EXÉCUTION D'ÉTAPE
# Exécute une étape avec gestion complète des erreurs et monitoring
#
# Arguments:
#   $1 - Numéro de l'étape
#   $2 - Nom de l'étape
#   $3 - Chemin du script à exécuter
#   $@ - Arguments à passer au script
#
# Returns:
#   0 si succès, 1-255 selon l'erreur
#
# Examples:
#   execute_step "1" "Configuration" "config.sh" "param1" "param2"
# =============================================================================

execute_step() {
    # Validation des paramètres obligatoires
    if ! validate_step_params "$@"; then
        return 1
    fi

    local step_number="$1"
    local step_name="$2"
    local script_path="$3"
    shift 3
    local args=("$@")

    # Initialisation
    local start_time
    start_time=$(date +%s)
    local step_id="step_${step_number}_$(date +%s)"
    local log_file="$LOG_DIR/${step_id}.log"

    # Préparation de l'environnement
    ensure_log_directory
    clear
    show_banner

    print_section_header "[Étape $step_number] 🔧 $step_name"

    # Information de debug si demandée
    if [[ "${DEBUG:-false}" == "true" ]]; then
        print_debug "Script: $script_path"
        print_debug "Arguments: ${args[*]}"
        print_debug "Log: $log_file"
    fi

    # Vérification de l'existence du script
    if [[ ! -f "$script_path" ]]; then
        print_error "Script non trouvé : $script_path"
        log_step_execution "$step_number" "$step_name" "SCRIPT_NOT_FOUND" 0
        return 2
    fi

    # Vérification des permissions d'exécution
    if [[ ! -x "$script_path" ]]; then
        print_warning "Script non exécutable, tentative de correction..."
        if ! chmod +x "$script_path" 2>/dev/null; then
            print_error "Impossible de rendre le script exécutable : $script_path"
            return 3
        fi
    fi

    # Execution avec logging
    local exit_code=0
    local execution_output

    print_info "Démarrage de l'étape $step_number..."

    # Exécution avec capture des sorties
    if bash "$script_path" "${args[@]}" 2>&1 | tee "$log_file"; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))

        # Succès
        print_success "Étape $step_number : $step_name terminée avec succès (${duration}s)"
        log_step_execution "$step_number" "$step_name" "SUCCESS" "$duration"

        # Mise à jour des statistiques
        ((TOTAL_STEPS_EXECUTED++))
        ((TOTAL_EXECUTION_TIME += duration))

        # Sauvegarde des logs de succès si demandé
        if [[ "${KEEP_SUCCESS_LOGS:-false}" == "true" ]]; then
            echo "$execution_output" >"$log_file"
        fi

    else
        exit_code=$?
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))

        # Gestion des différents types d'erreurs
        case $exit_code in
        130)
            print_error "Interruption utilisateur - Étape $step_number : $step_name"
            log_step_execution "$step_number" "$step_name" "INTERRUPTED" "$duration"
            ;;
        *)
            print_error "Erreur pendant l'étape $step_number : $step_name (code: $exit_code)"
            log_step_execution "$step_number" "$step_name" "ERROR_$exit_code" "$duration"
            ;;
        esac

        # Sauvegarde des logs d'erreur
        {
            echo "=== ERREUR ÉTAPE $step_number : $step_name ==="
            echo "Script: $script_path"
            echo "Arguments: ${args[*]}"
            echo "Code de sortie: $exit_code"
            echo "Durée: ${duration}s"
            echo "Timestamp: $(date)"
            echo "=== OUTPUT ==="
            echo "$execution_output"
        } >"$log_file"

        # Mise à jour des statistiques
        ((TOTAL_STEPS_EXECUTED++))
        ((TOTAL_STEPS_FAILED++))
        ((TOTAL_EXECUTION_TIME += duration))

        # Affichage des détails d'erreur si mode verbose
        if [[ "${VERBOSE:-false}" == "true" ]]; then
            print_debug "Logs d'erreur sauvegardés dans : $log_file"
            if [[ -n "$execution_output" ]]; then
                print_debug "Dernières lignes de sortie :"
                echo "$execution_output" | tail -5 | while read -r line; do
                    print_plain "$RED" "  $line"
                done
            fi
        fi
    fi

    return $exit_code
}

# =============================================================================
# FONCTION AVANCÉE - EXÉCUTION AVEC RETRY
# Exécute une étape avec possibilité de retry automatique
# =============================================================================

execute_step_with_retry() {
    [[ $# -lt 3 ]] && {
        print_error "execute_step_with_retry: arguments manquants"
        return 1
    }

    local max_retries="${MAX_RETRIES:-3}"
    local retry_delay="${RETRY_DELAY:-5}"
    local attempt=1

    while [[ $attempt -le $max_retries ]]; do
        if [[ $attempt -gt 1 ]]; then
            print_warning "Tentative $attempt/$max_retries après échec..."
            sleep "$retry_delay"
        fi

        if execute_step "$@"; then
            [[ $attempt -gt 1 ]] && print_success "Succès après $attempt tentative(s)"
            return 0
        fi

        ((attempt++))
    done

    print_error "Échec définitif après $max_retries tentatives"
    return 1
}

# =============================================================================
# FONCTIONS UTILITAIRES
# =============================================================================

# Validation des paramètres d'entrée
validate_step_params() {
    if [[ $# -lt 3 ]]; then
        print_error "Usage: execute_step <numéro> <nom> <script> [args...]"
        print_info "Exemple: execute_step \"1\" \"Configuration\" \"config.sh\" \"param1\""
        return 1
    fi

    local step_number="$1"
    local step_name="$2"
    local script_path="$3"

    # Validation du numéro d'étape
    if [[ ! "$step_number" =~ ^[0-9]+$ ]]; then
        print_error "Numéro d'étape invalide : '$step_number' (doit être numérique)"
        return 1
    fi

    # Validation du nom d'étape
    if [[ -z "$step_name" || ${#step_name} -gt 50 ]]; then
        print_error "Nom d'étape invalide : trop long (max 50 caractères)"
        return 1
    fi

    # Validation du chemin du script
    if [[ -z "$script_path" ]]; then
        print_error "Chemin du script requis"
        return 1
    fi

    return 0
}

# Création du répertoire de logs si nécessaire
ensure_log_directory() {
    if [[ ! -d "$LOG_DIR" ]]; then
        if ! mkdir -p "$LOG_DIR" 2>/dev/null; then
            print_warning "Impossible de créer le répertoire de logs : $LOG_DIR"
            return 1
        fi
    fi
}

# Logging détaillé de l'exécution
log_step_execution() {
    local step_number="$1"
    local step_name="$2"
    local status="$3"
    local duration="$4"

    local log_entry
    log_entry="$(date '+%Y-%m-%d %H:%M:%S') | STEP_${step_number} | ${status} | ${duration}s | ${step_name}"

    # Log dans fichier principal si possible
    local main_log="$LOG_DIR/execution.log"
    if ensure_log_directory; then
        echo "$log_entry" >>"$main_log" 2>/dev/null || true
    fi
}

# =============================================================================
# FONCTIONS DE MONITORING
# =============================================================================

# Affichage des statistiques d'exécution
show_execution_stats() {
    if [[ $TOTAL_STEPS_EXECUTED -gt 0 ]]; then
        print_section_header "📊 Statistiques d'exécution"
        print_info "Étapes exécutées : $TOTAL_STEPS_EXECUTED"
        print_info "Étapes échouées : $TOTAL_STEPS_FAILED"
        print_info "Taux de succès : $(((TOTAL_STEPS_EXECUTED - TOTAL_STEPS_FAILED) * 100 / TOTAL_STEPS_EXECUTED))%"
        print_info "Temps total : ${TOTAL_EXECUTION_TIME}s"

        if [[ $TOTAL_STEPS_FAILED -gt 0 ]]; then
            print_warning "Consultez les logs dans : $LOG_DIR"
        fi
    fi
}

# Nettoyage des logs anciens
cleanup_old_logs() {
    local days="${1:-7}"
    if [[ -d "$LOG_DIR" ]]; then
        find "$LOG_DIR" -name "*.log" -mtime +$days -delete 2>/dev/null || true
        print_info "Logs de plus de $days jours supprimés"
    fi
}

# =============================================================================
# GESTION DES SIGNAUX
# =============================================================================

# Gestion propre de l'interruption
handle_interrupt() {
    print_warning "\nInterruption détectée - Nettoyage en cours..."
    show_execution_stats
    exit 130
}

# Installation du gestionnaire de signal
trap handle_interrupt INT TERM

# =============================================================================
# MODE TEST
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== Test d'exécution d'étapes ==="

    # Test avec script factice
    cat >/tmp/test_step.sh <<'EOF'
#!/bin/bash
echo "Test step executed with args: $*"
sleep 1
exit 0
EOF
    chmod +x /tmp/test_step.sh

    # Test d'exécution normale
    execute_step "1" "Test Step" "/tmp/test_step.sh" "arg1" "arg2"

    # Affichage des stats
    show_execution_stats

    # Nettoyage
    rm -f /tmp/test_step.sh
fi
