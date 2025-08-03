#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../colors.sh"
PROJECT_NAME="$1"
CLIENT_DIR="$PROJECT_NAME/client"

# Afficher un titre formaté
echo -e "${GREEN} - Création du src/services/apiService.ts ${NC}"

# Le fichier
cat > "$CLIENT_DIR/src/services/apiService.ts" << 'EOF'
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api'

class ApiService {
  private async fetchApi(endpoint: string, options?: RequestInit) {
    const response = await fetch(`${API_URL}${endpoint}`, {
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
      ...options,
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    return response.json()
  }

  async ping(): Promise<string> {
    const response = await this.fetchApi('/ping')
    return response.message || response
  }
}

export const apiService = new ApiService()
EOF