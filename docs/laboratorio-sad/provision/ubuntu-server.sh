#!/bin/bash
# Provisioning script para Ubuntu Server
# Configuración mínima pero funcional

set -e

echo "============================================"
echo "Configurando Ubuntu Server..."
echo "============================================"

# Configurar zona horaria
timedatectl set-timezone Europe/Madrid 2>/dev/null || echo "Zona horaria ya configurada"

# Configurar teclado español (solo si está disponible)
if [ -f /etc/default/keyboard ]; then
    sed -i 's/XKBLAYOUT=.*/XKBLAYOUT="es"/' /etc/default/keyboard
    echo "Teclado configurado a español"
fi

# Actualizar sistema (sin preguntas)
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# Instalar servicios básicos
echo "Instalando Apache2, MySQL, PHP..."
apt-get install -y -qq apache2 mysql-server php libapache2-mod-php php-mysql

# Crear usuario admin (evitar conflicto con grupo admin preexistente)
if ! id "admin" &>/dev/null; then
    # Crear usuario especificando grupo primario explícitamente
    useradd -m -s /bin/bash -g users admin
    usermod -aG sudo admin
    echo "admin:adminSAD2024!" | chpasswd
    echo "Usuario admin creado"
else
    echo "Usuario admin ya existe"
fi

# Configurar SSH para acceso con contraseña
echo "Configurando SSH para autenticación por contraseña..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Asegurar que la configuración está activa
grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

systemctl restart sshd || systemctl restart ssh
echo "SSH configurado correctamente"

# Desactivar firewall inicialmente
ufw --force disable || echo "UFW no disponible"

# Configurar Apache
systemctl enable apache2
systemctl start apache2

# Crear página de bienvenida
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Ubuntu Server - Lab SAD</title>
</head>
<body>
    <h1>Ubuntu Server - Laboratorio SAD</h1>
    <p>Apache funcionando correctamente</p>
    <p>IP: 192.168.56.10</p>
</body>
</html>
EOF

# Configurar MySQL (sin contraseña root para facilitar)
mysql -e "CREATE DATABASE IF NOT EXISTS labsad;" 2>/dev/null || echo "BD ya existe"
mysql -e "CREATE USER IF NOT EXISTS 'labsad'@'%' IDENTIFIED BY 'labsad123';" 2>/dev/null || echo "Usuario ya existe"
mysql -e "GRANT ALL PRIVILEGES ON labsad.* TO 'labsad'@'%';" 2>/dev/null
mysql -e "FLUSH PRIVILEGES;" 2>/dev/null

# Configurar red estática
cat > /etc/netplan/99-vagrant.yaml << 'EOF'
network:
  version: 2
  ethernets:
    enp0s8:
      dhcp4: no
      addresses:
        - 192.168.56.10/24
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOF
netplan apply 2>/dev/null || echo "Netplan ya configurado"

# Añadir hosts
cat >> /etc/hosts << 'EOF'
192.168.56.10 ubuntu-server
192.168.56.11 windows-server
192.168.56.12 windows-client
192.168.56.13 storage-backup
192.168.56.20 kali-security
EOF

echo "============================================"
echo "✅ Ubuntu Server configurado correctamente"
echo "============================================"
echo "Usuario admin: admin / adminSAD2024!"
echo "MySQL: labsad / labsad123"
echo "Apache: http://192.168.56.10"
echo "============================================"
