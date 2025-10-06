#!/bin/bash
# Script de test de conectividad del laboratorio SAD v2.0

echo "============================================="
echo "🧪 Test de Conectividad - Laboratorio SAD"
echo "============================================="

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para test de ping
test_ping() {
    local ip=$1
    local name=$2
    
    if ping -c 1 -W 2 $ip &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name ($ip) - Responde a ping"
        return 0
    else
        echo -e "${RED}✗${NC} $name ($ip) - No responde"
        return 1
    fi
}

# Función para test de puerto
test_port() {
    local ip=$1
    local port=$2
    local service=$3
    
    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/$ip/$port" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $service ($ip:$port) - Puerto abierto"
        return 0
    else
        echo -e "${RED}✗${NC} $service ($ip:$port) - Puerto cerrado"
        return 1
    fi
}

# Función para test SSH
test_ssh() {
    local ip=$1
    local name=$2
    
    if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 -o BatchMode=yes vagrant@$ip exit 2>/dev/null; then
        echo -e "${GREEN}✓${NC} SSH $name ($ip) - Accesible"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} SSH $name ($ip) - Requiere contraseña (normal)"
        return 0
    fi
}

echo ""
echo "📡 Test de Conectividad de Red..."
echo "-------------------------------------------"
test_ping 192.168.56.10 "Ubuntu Server"
test_ping 192.168.56.11 "Windows Server"
test_ping 192.168.56.12 "Windows Client"
test_ping 192.168.56.13 "Storage Backup"
test_ping 192.168.56.20 "Kali Security"

echo ""
echo "🔌 Test de Puertos y Servicios..."
echo "-------------------------------------------"

# Ubuntu Server
test_port 192.168.56.10 22 "SSH Ubuntu"
test_port 192.168.56.10 80 "Apache"
test_port 192.168.56.10 3306 "MySQL"

# Windows Server
test_port 192.168.56.11 3389 "RDP Windows Server"
test_port 192.168.56.11 80 "IIS"
test_port 192.168.56.11 445 "SMB Windows Server"

# Windows Client
test_port 192.168.56.12 3389 "RDP Windows Client"

# Storage Backup
test_port 192.168.56.13 22 "SSH Storage"
test_port 192.168.56.13 445 "Samba"
test_port 192.168.56.13 2049 "NFS"

# Kali Security
test_port 192.168.56.20 22 "SSH Kali"

echo ""
echo "🔐 Test de Acceso SSH..."
echo "-------------------------------------------"
test_ssh 192.168.56.10 "Ubuntu Server"
test_ssh 192.168.56.13 "Storage Backup"
test_ssh 192.168.56.20 "Kali Security"

echo ""
echo "============================================="
echo "✅ Test de conectividad completado"
echo "============================================="
echo ""
echo "📋 Comandos de acceso:"
echo "  SSH Ubuntu:  ssh admin@192.168.56.10"
echo "  SSH Kali:    ssh kali@192.168.56.20"
echo "  SSH Storage: ssh backup@192.168.56.13"
echo "  RDP WinSrv:  xfreerdp /u:labadmin /p:Password123! /v:192.168.56.11"
echo "  RDP WinClt:  xfreerdp /u:cliente /p:User123! /v:192.168.56.12"
echo ""
