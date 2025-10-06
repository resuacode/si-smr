#!/bin/bash
# Instalación de servicios básicos en Ubuntu Server

echo "================================"
echo "Instalando servicios en Ubuntu"
echo "================================"

# Herramientas básicas de red y sistema
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    iotop \
    net-tools \
    tcpdump \
    nmap \
    tree \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Docker (para ejercicios de contenedores)
echo "Instalando Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Habilitar Docker al arranque
systemctl enable docker
systemctl start docker

# Permitir docker sin sudo al usuario vagrant
usermod -aG docker vagrant

# Nginx para ejercicios web
apt-get install -y nginx
systemctl enable nginx

# Servicios de red adicionales
apt-get install -y openssh-server fail2ban ufw

echo "Servicios instalados correctamente"
