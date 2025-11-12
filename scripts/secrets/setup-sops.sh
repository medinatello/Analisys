#!/bin/bash

# ============================================
# Setup Inicial de SOPS + Age
# ============================================

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BLUE}🔐 Setup SOPS + Age para Encriptación de Secretos${RESET}"
echo ""

# Verificar si SOPS está instalado
if ! command -v sops &> /dev/null; then
    echo -e "${YELLOW}📦 Instalando SOPS...${RESET}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sops
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        wget https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
        chmod +x sops-v3.8.1.linux.amd64
        sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
    else
        echo -e "${RED}❌ OS no soportado. Instalar manualmente: https://github.com/getsops/sops${RESET}"
        exit 1
    fi
fi

# Verificar si Age está instalado
if ! command -v age &> /dev/null; then
    echo -e "${YELLOW}📦 Instalando Age...${RESET}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install age
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        wget https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz
        tar xzf age-v1.1.1-linux-amd64.tar.gz
        sudo mv age/age age/age-keygen /usr/local/bin/
    fi
fi

echo -e "${GREEN}✓ SOPS y Age instalados${RESET}"
echo ""

# Generar clave Age si no existe
AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
mkdir -p "$HOME/.config/sops/age"

if [ -f "$AGE_KEY_FILE" ]; then
    echo -e "${YELLOW}⚠️  Clave Age ya existe: $AGE_KEY_FILE${RESET}"
else
    echo -e "${YELLOW}🔑 Generando nueva clave Age...${RESET}"
    age-keygen -o "$AGE_KEY_FILE"
    echo -e "${GREEN}✓ Clave generada: $AGE_KEY_FILE${RESET}"
fi

echo ""
echo -e "${BLUE}📋 Tu clave pública Age:${RESET}"
grep "public key:" "$AGE_KEY_FILE"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${RESET}"
echo -e "1. Guarda tu clave PRIVADA en lugar seguro: $AGE_KEY_FILE"
echo -e "2. Comparte tu clave PÚBLICA con el equipo para .sops.yaml"
echo -e "3. NUNCA commitees tu clave privada"
echo ""
echo -e "${GREEN}✅ Setup completo${RESET}"
echo -e "${BLUE}💡 Siguiente paso:${RESET} Actualizar .sops.yaml con tu clave pública"
