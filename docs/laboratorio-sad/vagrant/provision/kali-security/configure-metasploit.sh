#!/bin/bash
# configure-metasploit.sh - Configuración de Metasploit para laboratorio SAD

echo "============================="
echo "Configurando Metasploit"
echo "============================="

# Verificar si Metasploit está instalado
if ! command -v msfconsole &> /dev/null; then
    echo "Instalando Metasploit..."
    sudo apt update
    sudo apt install -y metasploit-framework
fi

# Crear directorio de configuración
sudo mkdir -p /opt/metasploit-framework/config
sudo chown -R kali:kali /opt/metasploit-framework/

# Configurar base de datos PostgreSQL
echo "Configurando base de datos PostgreSQL..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Crear usuario y base de datos para Metasploit
sudo -u postgres createuser -s msf 2>/dev/null || true
sudo -u postgres createdb msf_database 2>/dev/null || true
sudo -u postgres psql -c "ALTER USER msf PASSWORD 'msf123';" 2>/dev/null || true

# Configurar Metasploit para usar PostgreSQL
cat > ~/.msf4/database.yml <<EOF
production:
  adapter: postgresql
  database: msf_database
  username: msf
  password: msf123
  host: localhost
  port: 5432
  pool: 5
  timeout: 5
EOF

# Inicializar base de datos
echo "Inicializando base de datos de Metasploit..."
msfdb init

# Configurar proxychains (para usar con proxy del centro si es necesario)
echo "Configurando proxychains..."
sudo sed -i 's/#quiet_mode/quiet_mode/' /etc/proxychains4.conf
sudo sed -i 's/strict_chain/dynamic_chain/' /etc/proxychains4.conf

# Crear scripts útiles para el laboratorio
mkdir -p ~/msf-scripts
cat > ~/msf-scripts/lab-setup.rc <<'EOF'
# Script de configuración inicial para laboratorio SAD
setg RHOSTS 192.168.56.0/24
setg LHOST 192.168.56.20
setg ConsoleLogging true
setg LogLevel 3

# Configurar workspace para laboratorio
workspace -a laboratorio-sad
workspace laboratorio-sad

echo "Metasploit configurado para laboratorio SAD"
echo "Workspace: laboratorio-sad"
echo "RHOSTS: 192.168.56.0/24"
echo "LHOST: 192.168.56.20"
EOF

# Configurar arranque automático de PostgreSQL
sudo systemctl enable postgresql

# Verificar instalación
echo "Verificando instalación de Metasploit..."
msfconsole -v

echo "✓ Metasploit configurado correctamente"
echo "✓ Base de datos PostgreSQL configurada"
echo "✓ Workspace 'laboratorio-sad' creado"
echo ""
echo "Para usar: msfconsole -r ~/msf-scripts/lab-setup.rc"