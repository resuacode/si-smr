#!/bin/bash
# Script común para actualizar sistema en todas las VMs Linux

echo "===================="
echo "Actualizando sistema"
echo "===================="

# Actualizar lista de paquetes
apt-get update

# Actualizar sistema completo
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Limpiar cache de paquetes
apt-get autoremove -y
apt-get autoclean

echo "Sistema actualizado correctamente"
