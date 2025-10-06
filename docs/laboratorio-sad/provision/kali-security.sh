#!/bin/bash
# Provisioning script para Kali Security
# Configuración mínima de herramientas

set -e

echo "============================================"
echo "Configurando Kali Security..."
echo "============================================"

# Configurar zona horaria
timedatectl set-timezone Europe/Madrid 2>/dev/null || echo "Zona horaria ya configurada"

# Configurar usuario kali con contraseña
# Forzar contraseña "kali" para el usuario kali
echo "Configurando contraseña para usuario kali..."
echo "kali:kali" | sudo chpasswd 2>/dev/null || {
    echo "kali" | sudo passwd --stdin kali 2>/dev/null || {
        echo -e "kali\nkali" | sudo passwd kali 2>/dev/null
    }
}
echo "Usuario kali configurado con contraseña: kali"

# Configurar SSH para acceso con contraseña
echo "Configurando SSH para autenticación por contraseña..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Asegurar que la configuración está activa
grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config || echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

systemctl restart sshd || systemctl restart ssh
systemctl enable ssh
echo "SSH configurado correctamente"

# Actualizar sistema
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# Instalar herramientas básicas (sin metasploit por ahora, muy pesado)
echo "Instalando herramientas básicas..."
apt-get install -y -qq nmap tshark tcpdump netcat-traditional curl wget 2>/dev/null || \
apt-get install -y -qq nmap tcpdump netcat-traditional curl wget

# Configurar red estática
cat > /etc/network/interfaces.d/eth1 << 'EOF'
auto eth1
iface eth1 inet static
    address 192.168.56.20
    netmask 255.255.255.0
EOF

# Añadir hosts
cat >> /etc/hosts << 'EOF'
192.168.56.10 ubuntu-server
192.168.56.11 windows-server
192.168.56.12 windows-client
192.168.56.13 storage-backup
192.168.56.20 kali-security
EOF

# Asegurar que el directorio home de kali existe y crear script de Metasploit
if [ -d "/home/kali" ]; then
    cat > /home/kali/install-metasploit.sh << 'EOFSCRIPT'
#!/bin/bash
echo "Instalando Metasploit Framework..."
sudo apt-get update
sudo apt-get install -y metasploit-framework postgresql
sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo msfdb init
echo "✅ Metasploit instalado. Ejecuta 'msfconsole' para usarlo."
EOFSCRIPT
    chmod +x /home/kali/install-metasploit.sh
    chown kali:kali /home/kali/install-metasploit.sh 2>/dev/null || echo "Permisos ajustados"
    echo "Script de Metasploit creado en /home/kali/install-metasploit.sh"
else
    echo "Directorio /home/kali no encontrado, omitiendo script de Metasploit"
fi

echo "============================================"
echo "✅ Kali Security configurado correctamente"
echo "============================================"
echo "Usuario: kali / kali"
echo "Herramientas: nmap, wireshark-cli, tcpdump"
echo "Para Metasploit: ~/install-metasploit.sh"
echo "============================================"
