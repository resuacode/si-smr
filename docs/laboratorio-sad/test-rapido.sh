#!/bin/bash
# Test rápido del laboratorio

echo "🧪 Test Rápido del Laboratorio SAD"
echo "==================================="

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test función
test_vm() {
    local name=$1
    local ip=$2
    
    if ping -c 1 -W 2 $ip &>/dev/null; then
        echo -e "${GREEN}✓${NC} $name ($ip) - OK"
        return 0
    else
        echo -e "${RED}✗${NC} $name ($ip) - FALLO"
        return 1
    fi
}

echo ""
echo "📡 Test de Conectividad:"
test_vm "Ubuntu Server" 192.168.56.10
test_vm "Windows Server" 192.168.56.11
test_vm "Windows Client" 192.168.56.12
test_vm "Storage Backup" 192.168.56.13
test_vm "Kali Security" 192.168.56.20

echo ""
echo "🌐 Test de Servicios Web:"
if curl -s -I http://192.168.56.10 | grep -q "200 OK"; then
    echo -e "${GREEN}✓${NC} Apache (Ubuntu) - OK"
else
    echo -e "${RED}✗${NC} Apache (Ubuntu) - FALLO"
fi

if curl -s -I http://192.168.56.11 | grep -q "200"; then
    echo -e "${GREEN}✓${NC} IIS (Windows) - OK"
else
    echo -e "${RED}✗${NC} IIS (Windows) - FALLO"
fi

echo ""
echo "📋 Estado de VMs:"
vagrant status

echo ""
echo "✅ Test completado"
