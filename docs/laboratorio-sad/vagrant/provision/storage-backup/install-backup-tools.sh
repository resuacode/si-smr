#!/bin/bash
# install-backup-tools.sh - Instalar herramientas de backup para Debian

echo "=================================="
echo "Instalando herramientas de backup"
echo "=================================="

# Actualizar sistema
apt update

# Instalar herramientas básicas de backup
echo "Instalando rsync, tar, gzip..."
apt install -y rsync tar gzip bzip2 xz-utils

# Instalar Samba para compartir archivos
echo "Instalando Samba..."
apt install -y samba samba-common-bin

# Instalar NFS para compartir archivos
echo "Instalando NFS Server..."
apt install -y nfs-kernel-server

# Instalar herramientas de monitorización
echo "Instalando herramientas de monitorización..."
apt install -y htop iotop tree ncdu

# Instalar herramientas de red
echo "Instalando herramientas de red..."
apt install -y net-tools wget curl openssh-server

# Instalar duplicity para backups cifrados
echo "Instalando Duplicity..."
apt install -y duplicity

# Instalar herramientas de compresión avanzada
echo "Instalando herramientas de compresión..."
apt install -y p7zip-full zip unzip

# Crear usuario backup si no existe
if ! id "backup" &>/dev/null; then
    useradd -m -s /bin/bash backup
    echo "backup:backup123" | chpasswd
    usermod -aG sudo backup
    echo "✓ Usuario backup creado"
fi

# Crear estructura de directorios
echo "Creando estructura de directorios..."
mkdir -p /backup/{daily,weekly,monthly,restore}
mkdir -p /backup/shared/{users,projects,temp}
chown -R backup:backup /backup

# Configurar permisos
chmod 755 /backup
chmod 755 /backup/shared
chmod 1777 /backup/shared/temp  # Sticky bit para directorio temporal

# Habilitar servicios
systemctl enable ssh
systemctl start ssh

echo "✓ Herramientas de backup instaladas correctamente"
echo "✓ Usuario backup configurado"
echo "✓ Estructura de directorios creada"
echo "✓ SSH habilitado"

# Mostrar información del sistema
echo ""
echo "=== Información del sistema ==="
df -h
echo ""
echo "=== Servicios activos ==="
systemctl is-active ssh samba nmbd || true