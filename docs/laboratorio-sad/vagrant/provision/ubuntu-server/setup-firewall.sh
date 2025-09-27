#!/bin/bash
# Configuración básica del firewall UFW

echo "======================"
echo "Configurando firewall"
echo "======================"

# Restablecer UFW a configuración por defecto
ufw --force reset

# Políticas por defecto
ufw default deny incoming
ufw default allow outgoing

# Permitir SSH
ufw allow ssh

# Permitir HTTP y HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Permitir ping (ICMP)
ufw allow in on any to any proto icmp

# Permitir tráfico interno de la red del laboratorio
ufw allow from 192.168.100.0/24

# Habilitar UFW
ufw --force enable

# Mostrar estado
ufw status verbose

echo "Firewall configurado correctamente"
