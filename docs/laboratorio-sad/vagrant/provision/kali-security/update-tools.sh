#!/bin/bash
# Actualización y configuración de herramientas en Kali Linux

echo "==============================="
echo "Actualizando herramientas Kali"
echo "==============================="

# Actualizar lista de paquetes
apt-get update

# Actualizar herramientas de Kali
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Instalar herramientas adicionales útiles para el laboratorio
apt-get install -y \
    exploitdb \
    searchsploit \
    gobuster \
    dirb \
    nikto \
    sqlmap \
    john \
    hashcat \
    hydra \
    aircrack-ng \
    recon-ng \
    theharvester \
    whatweb \
    enum4linux \
    smbclient \
    nbtscan \
    onesixtyone \
    snmp-mibs-downloader

# Herramientas de análisis de red
apt-get install -y \
    wireshark \
    tshark \
    tcpdump \
    netcat-traditional \
    socat \
    proxychains4

# Herramientas de desarrollo
apt-get install -y \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget

# Configurar wireshark para ejecutar sin sudo
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common
usermod -aG wireshark kali

# Actualizar base de datos de exploits
searchsploit -u

echo "Herramientas de Kali actualizadas"
