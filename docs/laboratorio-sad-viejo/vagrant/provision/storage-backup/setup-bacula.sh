#!/bin/bash
# setup-bacula.sh - Configurar Bacula para backups empresariales

echo "========================="
echo "Configurando Bacula"
echo "========================="

# Instalar Bacula
echo "Instalando Bacula..."
DEBIAN_FRONTEND=noninteractive apt install -y bacula-server bacula-client bacula-common-mysql mysql-server

# Configurar MySQL para Bacula
echo "Configurando MySQL para Bacula..."
systemctl start mysql
systemctl enable mysql

# Crear base de datos y usuario para Bacula
mysql -e "CREATE DATABASE IF NOT EXISTS bacula;"
mysql -e "CREATE USER IF NOT EXISTS 'bacula'@'localhost' IDENTIFIED BY 'bacula123';"
mysql -e "GRANT ALL PRIVILEGES ON bacula.* TO 'bacula'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Configurar esquema de base de datos de Bacula
echo "Configurando esquema de base de datos..."
/usr/share/bacula-common/make_mysql_tables

# Configurar Bacula Director
echo "Configurando Bacula Director..."
cat > /etc/bacula/bacula-dir.conf <<'EOF'
Director {
  Name = backup-dir
  DIRport = 9101
  QueryFile = "/etc/bacula/scripts/query.sql"
  WorkingDirectory = "/var/lib/bacula"
  PidDirectory = "/run/bacula"
  Maximum Concurrent Jobs = 10
  Password = "bacula123"
  Messages = Daemon
  DirAddress = 192.168.56.13
}

Job {
  Name = "BackupClient1"
  Type = Backup
  Level = Incremental
  Client = backup-fd
  FileSet = "Full Set"
  Schedule = "WeeklyCycle"
  Storage = File1
  Messages = Standard
  Pool = File
  SpoolAttributes = yes
  Priority = 10
  Write Bootstrap = "/var/lib/bacula/%c.bsr"
}

Job {
  Name = "RestoreFiles"
  Type = Restore
  Client = backup-fd
  Storage = File1
  FileSet = "Full Set"
  Pool = File
  Messages = Standard
  Where = /bacula-restore
}

FileSet {
  Name = "Full Set"
  Include {
    Options {
      signature = MD5
    }
    File = /backup/shared
    File = /home
  }
  Exclude {
    File = /var/lib/bacula
    File = /nonexistant/path/to/file/archive/dir
    File = /proc
    File = /tmp
    File = /sys
    File = /.journal
    File = /.fsck
  }
}

Schedule {
  Name = "WeeklyCycle"
  Run = Full 1st sun at 23:05
  Run = Differential 2nd-5th sun at 23:05
  Run = Incremental mon-sat at 23:05
}

Client {
  Name = backup-fd
  Address = localhost
  FDPort = 9102
  Catalog = MyCatalog
  Password = "bacula123"
  File Retention = 60 days
  Job Retention = 6 months
  AutoPrune = yes
}

Storage {
  Name = File1
  Address = 192.168.56.13
  SDPort = 9103
  Password = "bacula123"
  Device = FileChgr1
  Media Type = File1
  Maximum Concurrent Jobs = 10
}

Catalog {
  Name = MyCatalog
  dbname = "bacula"; DB Address = "localhost"; dbuser = "bacula"; dbpassword = "bacula123"
}

Messages {
  Name = Standard
  mailcommand = "/usr/sbin/bsmtp -h localhost -f \"\\(Bacula\\) \\<%r\\>\" -s \"Bacula: %t %e of %c %l\" %r"
  operatorcommand = "/usr/sbin/bsmtp -h localhost -f \"\\(Bacula\\) \\<%r\\>\" -s \"Bacula: Intervention needed for %j\" %r"
  mail = root = all, !skipped
  operator = root = mount
  console = all, !skipped, !saved
  append = "/var/log/bacula/bacula.log" = all, !skipped
  catalog = all
}

Messages {
  Name = Daemon
  mailcommand = "/usr/sbin/bsmtp -h localhost -f \"\\(Bacula\\) \\<%r\\>\" -s \"Bacula daemon message\" %r"
  mail = root = all, !skipped
  console = all, !skipped, !saved
  append = "/var/log/bacula/bacula.log" = all, !skipped
}

Pool {
  Name = File
  Pool Type = Backup
  Recycle = yes
  AutoPrune = yes
  Volume Retention = 365 days
  Maximum Volume Bytes = 50G
  Maximum Volumes = 100
  Label Format = "Vol-"
}

Pool {
  Name = Scratch
  Pool Type = Backup
}
EOF

# Configurar Bacula Storage Daemon
echo "Configurando Bacula Storage Daemon..."
cat > /etc/bacula/bacula-sd.conf <<'EOF'
Storage {
  Name = backup-sd
  SDPort = 9103
  WorkingDirectory = "/var/lib/bacula"
  Pid Directory = "/run/bacula"
  Plugin Directory = "/usr/lib/bacula"
  Maximum Concurrent Jobs = 20
  SDAddress = 192.168.56.13
}

Director {
  Name = backup-dir
  Password = "bacula123"
}

Director {
  Name = backup-mon
  Password = "bacula123"
  Monitor = yes
}

Device {
  Name = FileChgr1
  Media Type = File1
  Archive Device = /backup/bacula
  LabelMedia = yes
  Random Access = Yes
  AutomaticMount = yes
  RemovableMedia = no
  AlwaysOpen = no
  Maximum Concurrent Jobs = 5
}

Messages {
  Name = Standard
  director = backup-dir = all
}
EOF

# Configurar Bacula File Daemon
echo "Configurando Bacula File Daemon..."
cat > /etc/bacula/bacula-fd.conf <<'EOF'
Director {
  Name = backup-dir
  Password = "bacula123"
}

Director {
  Name = backup-mon
  Password = "bacula123"
  Monitor = yes
}

FileDaemon {
  Name = backup-fd
  FDport = 9102
  WorkingDirectory = /var/lib/bacula
  Pid Directory = /run/bacula
  Plugin Directory = /usr/lib/bacula
  Maximum Concurrent Jobs = 20
  FDAddress = 192.168.56.13
}

Messages {
  Name = Standard
  director = backup-dir = all, !skipped, !restored
}
EOF

# Crear directorio para almacenamiento de Bacula
mkdir -p /backup/bacula
chown bacula:bacula /backup/bacula
chmod 755 /backup/bacula

# Crear directorio de logs
mkdir -p /var/log/bacula
chown bacula:bacula /var/log/bacula

# Configurar permisos
chown -R bacula:bacula /etc/bacula
chmod 640 /etc/bacula/bacula-dir.conf
chmod 640 /etc/bacula/bacula-sd.conf
chmod 640 /etc/bacula/bacula-fd.conf

# Habilitar y iniciar servicios
systemctl enable bacula-director
systemctl enable bacula-sd
systemctl enable bacula-fd

systemctl start bacula-director
systemctl start bacula-sd
systemctl start bacula-fd

# Crear scripts útiles
mkdir -p /home/backup/bacula-scripts

cat > /home/backup/bacula-scripts/backup-status.sh <<'EOF'
#!/bin/bash
echo "=== Estado de Bacula ==="
systemctl status bacula-director --no-pager
systemctl status bacula-sd --no-pager  
systemctl status bacula-fd --no-pager

echo -e "\n=== Últimos trabajos ==="
echo "list jobs" | bconsole

echo -e "\n=== Estado de volúmenes ==="
echo "list volumes" | bconsole
EOF

cat > /home/backup/bacula-scripts/run-backup.sh <<'EOF'
#!/bin/bash
echo "=== Ejecutando backup manual ==="
echo "run job=BackupClient1 yes" | bconsole
EOF

chmod +x /home/backup/bacula-scripts/*.sh
chown -R backup:backup /home/backup/bacula-scripts

echo "✓ Bacula configurado correctamente"
echo "✓ Director: 192.168.56.13:9101"
echo "✓ Storage: 192.168.56.13:9103"  
echo "✓ File Daemon: 192.168.56.13:9102"
echo "✓ Almacenamiento: /backup/bacula"
echo "✓ Scripts útiles en: /home/backup/bacula-scripts/"

# Mostrar estado de servicios
systemctl status bacula-director --no-pager -l || true