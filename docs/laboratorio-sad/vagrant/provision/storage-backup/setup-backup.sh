#!/bin/bash
# Configuración de servicios de backup y monitoreo

echo "===================================="
echo "Configurando servicios de backup"
echo "===================================="

# Instalar herramientas de backup
apt-get update
apt-get install -y rsync rclone duplicity

# Crear directorios de backup
mkdir -p /backup/{daily,weekly,monthly,logs}
chmod 755 /backup
chmod 755 /backup/*

# Script de backup diario
cat > /usr/local/bin/backup_daily.sh << 'EOF'
#!/bin/bash
# Script de backup diario

LOG_FILE="/backup/logs/daily_$(date +%Y%m%d).log"
BACKUP_DIR="/backup/daily/$(date +%Y%m%d)"

echo "=== Backup Diario - $(date) ===" >> $LOG_FILE

# Crear directorio de backup del día
mkdir -p $BACKUP_DIR

# Backup de archivos compartidos
echo "$(date): Iniciando backup de archivos compartidos..." >> $LOG_FILE
rsync -av /srv/shares/ $BACKUP_DIR/shares/ >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "$(date): Backup de shares completado exitosamente" >> $LOG_FILE
else
    echo "$(date): ERROR en backup de shares" >> $LOG_FILE
fi

# Backup de configuraciones del sistema
echo "$(date): Respaldando configuraciones del sistema..." >> $LOG_FILE
tar -czf $BACKUP_DIR/config_sistema.tar.gz /etc/samba /etc/vsftpd.conf /etc/passwd /etc/group 2>> $LOG_FILE

# Backup de logs del sistema
echo "$(date): Respaldando logs del sistema..." >> $LOG_FILE
tar -czf $BACKUP_DIR/logs_sistema.tar.gz /var/log 2>> $LOG_FILE

# Limpieza de backups antiguos (mantener 7 días)
find /backup/daily -type d -name "20*" -mtime +7 -exec rm -rf {} \; 2>/dev/null

echo "$(date): Backup diario completado" >> $LOG_FILE
echo "=======================================" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/backup_daily.sh

# Script de backup semanal
cat > /usr/local/bin/backup_weekly.sh << 'EOF'
#!/bin/bash
# Script de backup semanal

LOG_FILE="/backup/logs/weekly_$(date +%Y_semana_%U).log"
BACKUP_DIR="/backup/weekly/$(date +%Y_semana_%U)"

echo "=== Backup Semanal - $(date) ===" >> $LOG_FILE

mkdir -p $BACKUP_DIR

# Backup completo del servidor
echo "$(date): Iniciando backup completo..." >> $LOG_FILE
tar -czf $BACKUP_DIR/servidor_completo.tar.gz \
    --exclude=/proc \
    --exclude=/sys \
    --exclude=/dev \
    --exclude=/tmp \
    --exclude=/backup \
    / >> $LOG_FILE 2>&1

# Verificar integridad del backup
echo "$(date): Verificando integridad..." >> $LOG_FILE
tar -tzf $BACKUP_DIR/servidor_completo.tar.gz > /dev/null 2>> $LOG_FILE

if [ $? -eq 0 ]; then
    echo "$(date): Backup semanal completado y verificado" >> $LOG_FILE
else
    echo "$(date): ERROR en verificación del backup semanal" >> $LOG_FILE
fi

# Limpieza (mantener 4 semanas)
find /backup/weekly -type d -name "20*" -mtime +28 -exec rm -rf {} \; 2>/dev/null

echo "=======================================" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/backup_weekly.sh

# Configurar cron jobs
cat > /etc/cron.d/backup_laboratorio << 'EOF'
# Backup diario a las 2:00 AM
0 2 * * * root /usr/local/bin/backup_daily.sh

# Backup semanal los domingos a las 3:00 AM
0 3 * * 0 root /usr/local/bin/backup_weekly.sh

# Limpieza de logs antiguos
0 1 * * * root find /backup/logs -name "*.log" -mtime +30 -delete
EOF

# Instalar y configurar herramientas de monitoreo
apt-get install -y htop iotop nethogs

# Script de monitoreo del sistema
cat > /usr/local/bin/monitor_sistema.sh << 'EOF'
#!/bin/bash
# Script de monitoreo del sistema

LOG_FILE="/backup/logs/monitor_$(date +%Y%m%d).log"

echo "=== Monitoreo del Sistema - $(date) ===" >> $LOG_FILE

# Estado del disco
echo "--- Uso del disco ---" >> $LOG_FILE
df -h >> $LOG_FILE

# Memoria
echo "--- Uso de memoria ---" >> $LOG_FILE
free -h >> $LOG_FILE

# Procesos que más consumen CPU
echo "--- Top procesos CPU ---" >> $LOG_FILE
ps aux --sort=-%cpu | head -10 >> $LOG_FILE

# Procesos que más consumen memoria
echo "--- Top procesos Memoria ---" >> $LOG_FILE
ps aux --sort=-%mem | head -10 >> $LOG_FILE

# Estado de servicios críticos
echo "--- Estado de servicios ---" >> $LOG_FILE
systemctl status smbd >> $LOG_FILE 2>&1
systemctl status vsftpd >> $LOG_FILE 2>&1

# Conexiones de red activas
echo "--- Conexiones de red ---" >> $LOG_FILE
netstat -tuln >> $LOG_FILE

echo "=======================================" >> $LOG_FILE
EOF

chmod +x /usr/local/bin/monitor_sistema.sh

# Agregar monitoreo cada hora
echo "0 * * * * root /usr/local/bin/monitor_sistema.sh" >> /etc/cron.d/backup_laboratorio

# Crear script de diagnóstico
cat > /usr/local/bin/diagnostico_backup.sh << 'EOF'
#!/bin/bash
# Script de diagnóstico del sistema de backup

echo "======================================="
echo "   DIAGNÓSTICO SISTEMA DE BACKUP"
echo "======================================="

echo "📁 Espacio en disco:"
df -h /backup

echo ""
echo "📋 Últimos backups:"
ls -la /backup/daily/ | tail -5
echo ""
ls -la /backup/weekly/ | tail -3

echo ""
echo "📊 Estado de servicios:"
systemctl status smbd --no-pager -l
echo ""
systemctl status vsftpd --no-pager -l

echo ""
echo "🔍 Último backup diario:"
ls -la /backup/daily/$(date +%Y%m%d) 2>/dev/null || echo "No hay backup de hoy"

echo ""
echo "📝 Últimas líneas del log de backup:"
tail -10 /backup/logs/daily_$(date +%Y%m%d).log 2>/dev/null || echo "No hay log de hoy"

echo ""
echo "🌐 Conexiones activas a servicios de archivos:"
netstat -an | grep -E ":21|:445|:139"

echo ""
echo "======================================="
EOF

chmod +x /usr/local/bin/diagnostico_backup.sh

# Ejecutar backup inicial
/usr/local/bin/backup_daily.sh

echo "Sistema de backup y monitoreo configurado"
