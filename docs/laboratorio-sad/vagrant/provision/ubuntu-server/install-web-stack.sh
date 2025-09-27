#!/bin/bash
# install-web-stack.sh - Completar LAMP stack en Ubuntu Server

echo "=================================="
echo "Instalando LAMP Stack completo"
echo "=================================="

# MySQL/MariaDB
echo "Instalando MariaDB..."
apt-get install -y mariadb-server mariadb-client

# Configurar MariaDB
systemctl enable mariadb
systemctl start mariadb

# Configuración básica de seguridad MySQL
mysql -e "CREATE USER 'labuser'@'localhost' IDENTIFIED BY 'labpass123';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'labuser'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"

# Apache2 (además de Nginx ya instalado)
echo "Instalando Apache2..."
apt-get install -y apache2

# PHP y módulos
echo "Instalando PHP y módulos..."
apt-get install -y php php-mysql php-apache2 php-curl php-json php-zip php-gd php-mbstring php-xml

# Habilitar módulos Apache
a2enmod php8.1
a2enmod rewrite
a2enmod ssl

# FTP Server (para ejercicios de seguridad)
echo "Instalando FTP Server..."
apt-get install -y vsftpd

# Configurar FTP básico
cat > /etc/vsftpd.conf << 'EOF'
listen=YES
local_enable=YES
write_enable=YES
anonymous_enable=YES
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_root=/var/ftp/anonymous
EOF

# Crear directorio FTP anónimo
mkdir -p /var/ftp/anonymous
chown ftp:ftp /var/ftp/anonymous

# Habilitar servicios
systemctl enable apache2
systemctl enable vsftpd
systemctl start apache2
systemctl start vsftpd

echo "LAMP Stack instalado completamente"