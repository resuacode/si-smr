#!/bin/bash
# Configuración de servicios de almacenamiento y backup

echo "========================================="
echo "Configurando servicios de almacenamiento"
echo "========================================="

# Instalar Samba para compartir archivos
apt-get update
apt-get install -y samba samba-common-bin

# Configurar Samba
cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

cat > /etc/samba/smb.conf << 'EOF'
[global]
   workgroup = LABORATORIO
   server string = Servidor de Almacenamiento Lab
   netbios name = STORAGE-LAB
   security = user
   map to guest = bad user
   dns proxy = no
   
   # Configuración de logs
   log file = /var/log/samba/log.%m
   max log size = 1000
   log level = 1

[backup]
   comment = Directorio de Backup del Laboratorio
   path = /srv/backup
   browseable = yes
   guest ok = yes
   read only = no
   create mask = 0777
   directory mask = 0777

[shares]
   comment = Archivos Compartidos
   path = /srv/shares
   browseable = yes
   guest ok = yes
   read only = no
   create mask = 0775
   directory mask = 0775

[admin]
   comment = Archivos de Administración
   path = /srv/admin
   browseable = yes
   valid users = admin, backup
   read only = no
   create mask = 0750
   directory mask = 0750
EOF

# Crear directorios compartidos
mkdir -p /srv/{backup,shares,admin}
chmod 777 /srv/backup
chmod 775 /srv/shares
chmod 750 /srv/admin

# Crear usuarios de Samba
(echo "admin123"; echo "admin123") | smbpasswd -a root
useradd -m backup
(echo "backup123"; echo "backup123") | smbpasswd -a backup

# Crear contenido de ejemplo en los directorios compartidos
cat > /srv/shares/README.txt << 'EOF'
Directorio de archivos compartidos del laboratorio
==================================================

Este directorio contiene archivos de ejemplo para los ejercicios de:
- Análisis forense
- Auditoría de accesos
- Investigación de incidentes

Estructura:
- logs/        - Logs del sistema
- documents/   - Documentos corporativos
- software/    - Software y herramientas
EOF

mkdir -p /srv/shares/{logs,documents,software}

# Crear logs de ejemplo
cat > /srv/shares/logs/access.log << 'EOF'
2024-01-15 08:30:15 [INFO] Usuario 'admin' accedió al sistema desde 192.168.56.11
2024-01-15 09:15:22 [WARNING] Intento de acceso fallido desde 192.168.56.20
2024-01-15 09:16:45 [INFO] Usuario 'backup' inició sesión desde 192.168.56.12
2024-01-15 10:30:10 [ERROR] Fallo en backup automático - disco lleno
2024-01-15 11:20:33 [INFO] Usuario 'admin' descargó archivo 'config.zip'
2024-01-15 14:45:12 [WARNING] Acceso no autorizado detectado en directorio /admin
EOF

cat > /srv/shares/logs/backup.log << 'EOF'
=== Log de Backup - Sistema de Almacenamiento ===

2024-01-14 02:00:01 [INICIO] Backup automático iniciado
2024-01-14 02:15:33 [INFO] Respaldando /srv/shares... OK (2.3GB)
2024-01-14 02:28:45 [INFO] Respaldando /home/usuarios... OK (1.8GB)
2024-01-14 02:35:12 [WARNING] Error en /tmp/cache - omitiendo
2024-01-14 02:45:01 [COMPLETADO] Backup finalizado exitosamente

2024-01-15 02:00:01 [INICIO] Backup automático iniciado
2024-01-15 02:20:15 [ERROR] Fallo al acceder a 192.168.56.11
2024-01-15 02:22:30 [RETRY] Reintentando conexión...
2024-01-15 02:25:45 [INFO] Conexión restablecida
2024-01-15 02:40:22 [COMPLETADO] Backup finalizado con advertencias
EOF

# Crear documentos corporativos de ejemplo
cat > /srv/shares/documents/politicas_seguridad.txt << 'EOF'
POLÍTICAS DE SEGURIDAD CORPORATIVA
==================================

1. GESTIÓN DE CONTRASEÑAS
   - Longitud mínima: 8 caracteres
   - Cambio obligatorio cada 90 días
   - Prohibido reutilizar últimas 5 contraseñas

2. ACCESO AL SISTEMA
   - VPN obligatoria para acceso remoto
   - Autenticación de doble factor en servicios críticos
   - Bloqueo automático tras 3 intentos fallidos

3. BACKUP Y RECUPERACIÓN
   - Backup diario automático a las 02:00
   - Verificación semanal de integridad
   - Pruebas de recuperación mensuales

4. INCIDENT RESPONSE
   - Notificación inmediata de incidentes de seguridad
   - Aislamiento de sistemas comprometidos
   - Análisis forense preservando evidencias

Contacto: security@empresa.local
Versión: 2.1 (Enero 2024)
EOF

cat > /srv/shares/documents/lista_empleados.csv << 'EOF'
nombre,departamento,email,extension,fecha_ingreso
"Juan Pérez","IT","juan.perez@empresa.local","101","2023-01-15"
"María García","RRHH","maria.garcia@empresa.local","102","2022-06-20"
"Carlos López","Ventas","carlos.lopez@empresa.local","103","2023-03-10"
"Ana Martín","Finanzas","ana.martin@empresa.local","104","2021-09-05"
"Luis Rodríguez","IT","luis.rodriguez@empresa.local","105","2023-07-12"
EOF

# Configurar servicio FTP básico
apt-get install -y vsftpd

cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
cat > /etc/vsftpd.conf << 'EOF'
listen=YES
listen_ipv6=NO
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
anon_upload_enable=YES
anon_mkdir_write_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
pasv_enable=Yes
pasv_min_port=10000
pasv_max_port=10100
allow_writeable_chroot=YES
anon_root=/srv/ftp
local_root=/srv/ftp
EOF

# Crear directorio FTP
mkdir -p /srv/ftp/upload
chmod 755 /srv/ftp
chmod 777 /srv/ftp/upload

cat > /srv/ftp/README_FTP.txt << 'EOF'
Servidor FTP del Laboratorio
============================

Acceso anónimo habilitado para ejercicios.

Directorios:
- /upload - Subida de archivos (anónimo)
- Acceso completo con credenciales locales

Usuarios de prueba:
- backup / backup123
- admin / admin123

¡SOLO PARA LABORATORIO!
EOF

# Reiniciar servicios
systemctl restart smbd nmbd
systemctl restart vsftpd
systemctl enable smbd nmbd vsftpd

echo "Servicios de almacenamiento configurados"
