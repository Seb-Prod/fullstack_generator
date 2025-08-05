#!/bin/bash

execute_step() {
    clear
    show_banner
    local step_number="$1"
    local step_name="$2"
    local script_path="$3"
    shift 3
    local args=("$@")

    print_section_header "[Étape $step_number] 🔧 $step_name"

    if [[ ! -f "$script_path" ]]; then
        print_warning "⚠️ Script non trouvé : $script_path"
        return 1
    fi

    if bash "$script_path" "${args[@]}"; then
        print_success "✅ Étape $step_number : $step_name terminée avec succès"
    else
        print_error "❌ Erreur pendant l'étape $step_number : $step_name"
        return 1
    fi
}