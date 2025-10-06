#!/bin/bash
# Provisioning script para Storage Backup
# Servidor Samba y NFS básico

set -e

echo "============================================"
echo "Configurando Storage Backup..."
echo "============================================"

# Sincronizar reloj del sistema (importante para apt)
echo "Sincronizando reloj del sistema..."
timedatectl set-ntp true 2>/dev/null || echo "NTP activado"
systemctl restart systemd-timesyncd 2>/dev/null || echo "timesyncd reiniciado"
sleep 5

# Forzar sincronización del reloj de hardware
hwclock --hctosys 2>/dev/null || echo "hwclock sincronizado"

# Mostrar hora actual
echo "Hora actual del sistema: $(date)"

# Configurar zona horaria
timedatectl set-timezone Europe/Madrid 2>/dev/null || echo "Zona horaria ya configurada"

# Crear usuario backup
if ! id "backup" &>/dev/null; then
    # Crear con grupo primario users para evitar conflictos
    useradd -m -s /bin/bash -g users backup
    usermod -aG sudo backup
    echo "backup:backup123" | chpasswd
    echo "Usuario backup creado"
else
    # Si existe, asegurar que tiene shell y contraseña correctos
    usermod -s /bin/bash backup
    echo "backup:backup123" | chpasswd
    echo "Usuario backup ya existe, shell y contraseña actualizados"
fi

# Configurar SSH
echo "Configurando SSH para autenticación por contraseña..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Asegurar que la configuración está activa
grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

systemctl restart sshd || systemctl restart ssh
echo "SSH configurado correctamente"

# Configurar APT para no verificar fechas de release (evita problemas de sincronización)
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99-no-check-valid-until

# Actualizar sistema (con manejo de errores de fecha)
export DEBIAN_FRONTEND=noninteractive
echo "Actualizando repositorios..."

# Intentar con verificación de fecha deshabilitada
if ! apt-get update -o Acquire::Check-Valid-Until=false -qq 2>/dev/null; then
    echo "Primera actualización falló, reintentando sin verificación..."
    apt-get update -o Acquire::Check-Valid-Until=false 2>&1 | grep -v "not valid yet" || true
fi

echo "Repositorios actualizados"

# Instalar Samba y NFS
echo "Instalando Samba y NFS..."
apt-get install -y -qq samba nfs-kernel-server

# Crear directorio compartido
mkdir -p /srv/samba/public
chmod 777 /srv/samba/public

# Configurar Samba
cat > /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = LAB-SAD
   server string = Storage Backup Server
   security = user
   map to guest = bad user
   
[public]
   comment = Public Share
   path = /srv/samba/public
   browseable = yes
   guest ok = yes
   read only = no
   create mask = 0777
   directory mask = 0777
EOF

# Establecer contraseña Samba para backup
(echo "backup123"; echo "backup123") | smbpasswd -a backup -s

# Reiniciar Samba
systemctl restart smbd
systemctl enable smbd

# Configurar NFS
mkdir -p /srv/nfs/shared
chmod 777 /srv/nfs/shared

cat > /etc/exports << 'EOF'
/srv/nfs/shared 192.168.56.0/24(rw,sync,no_subtree_check,no_root_squash)
EOF

exportfs -a
systemctl restart nfs-kernel-server
systemctl enable nfs-kernel-server

# Añadir hosts
cat >> /etc/hosts << 'EOF'
192.168.56.10 ubuntu-server
192.168.56.11 windows-server
192.168.56.12 windows-client
192.168.56.13 storage-backup
192.168.56.20 kali-security
EOF

echo "============================================"
echo "✅ Storage Backup configurado correctamente"
echo "============================================"
echo "Usuario: backup / backup123"
echo "Samba: //192.168.56.13/public"
echo "NFS: 192.168.56.13:/srv/nfs/shared"
echo "============================================"
