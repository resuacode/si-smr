#!/bin/bash
# configure-samba.sh - Configurar Samba para compartir archivos

echo "========================="
echo "Configurando Samba"
echo "========================="

# Backup de la configuración original
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Crear nueva configuración de Samba
cat > /etc/samba/smb.conf <<'EOF'
[global]
   workgroup = WORKGROUP
   server string = Storage Backup Server
   security = user
   map to guest = bad user
   dns proxy = no
   
   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   
   # Performance
   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536
   read raw = yes
   write raw = yes
   
   # Security
   client min protocol = SMB2
   client max protocol = SMB3

[backup-shared]
   comment = Shared Backup Storage
   path = /backup/shared
   browseable = yes
   writable = yes
   guest ok = no
   valid users = backup, @backup
   create mask = 0644
   directory mask = 0755
   
[backup-restore]
   comment = Restore Area
   path = /backup/restore
   browseable = yes
   writable = yes
   guest ok = no
   valid users = backup, @backup
   create mask = 0644
   directory mask = 0755

[homes]
   comment = Home Directories
   browseable = no
   writable = yes
   valid users = %S
EOF

# Crear usuario Samba
echo "Configurando usuario Samba..."
# Crear contraseña para usuario backup en Samba
(echo "backup123"; echo "backup123") | smbpasswd -s -a backup

# Verificar configuración
echo "Verificando configuración de Samba..."
testparm -s

# Reiniciar servicios
systemctl restart smbd nmbd
systemctl enable smbd nmbd

# Configurar firewall para Samba
ufw allow samba 2>/dev/null || true

echo "✓ Samba configurado correctamente"
echo "✓ Compartidos disponibles:"
echo "  - //$(hostname -I | cut -d' ' -f1)/backup-shared"
echo "  - //$(hostname -I | cut -d' ' -f1)/backup-restore"
echo "✓ Usuario: backup / Contraseña: backup123"

# Mostrar estado de los servicios
systemctl status smbd --no-pager -l || true