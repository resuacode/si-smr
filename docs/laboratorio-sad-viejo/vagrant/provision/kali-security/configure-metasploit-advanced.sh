#!/bin/bash
# configure-metasploit-advanced.sh - Configuración avanzada de Metasploit

echo "========================================="
echo "Configurando Metasploit Framework"
echo "========================================="

# Inicializar base de datos de Metasploit
echo "Inicializando base de datos de Metasploit..."
systemctl start postgresql
systemctl enable postgresql

# Crear usuario de base de datos para Metasploit
sudo -u postgres createuser msf -P
sudo -u postgres createdb msf_database -O msf

# Configurar Metasploit database
sudo -u kali bash << 'EOF'
msfdb init
msfconsole -x "db_status; exit"
EOF

# Crear script de inicio rápido para pentesting
cat > /home/kali/start-pentest.sh << 'EOF'
#!/bin/bash
# Script de inicio rápido para pentesting

echo "========================================="
echo "Iniciando entorno de pentesting"
echo "========================================="

# Verificar conectividad a las VMs del lab
echo "Verificando conectividad al laboratorio..."
ping -c 1 192.168.56.10 && echo "✅ Ubuntu Server accesible" || echo "❌ Ubuntu Server no accesible"
ping -c 1 192.168.56.11 && echo "✅ Windows Server accesible" || echo "❌ Windows Server no accesible"
ping -c 1 192.168.56.13 && echo "✅ Storage accesible" || echo "❌ Storage no accesible"

echo ""
echo "Comandos útiles para el laboratorio:"
echo "nmap -sV 192.168.56.10-13          # Escaneo de servicios"
echo "nikto -h http://192.168.56.10       # Análisis web Ubuntu"
echo "nikto -h http://192.168.56.11       # Análisis web Windows"
echo "msfconsole                          # Iniciar Metasploit"
echo "wireshark                           # Análisis de tráfico"
echo ""
EOF

chmod +x /home/kali/start-pentest.sh
chown kali:kali /home/kali/start-pentest.sh

# Configurar Wireshark para usuario kali
echo "Configurando Wireshark..."
usermod -a -G wireshark kali

# Crear scripts personalizados para el laboratorio
mkdir -p /home/kali/lab-scripts

cat > /home/kali/lab-scripts/scan-lab.sh << 'EOF'
#!/bin/bash
# Escaneo completo del laboratorio

echo "Escaneando laboratorio SAD..."
nmap -sV -sC 192.168.56.10-13 -oN /home/kali/lab-scan.txt
echo "Resultados guardados en /home/kali/lab-scan.txt"
EOF

cat > /home/kali/lab-scripts/web-enum.sh << 'EOF'
#!/bin/bash
# Enumeración de aplicaciones web

echo "Enumerando aplicaciones web del laboratorio..."
nikto -h http://192.168.56.10 -output /home/kali/nikto-ubuntu.txt
nikto -h http://192.168.56.11 -output /home/kali/nikto-windows.txt
gobuster dir -u http://192.168.56.10 -w /usr/share/wordlists/dirb/common.txt
echo "Análisis web completado"
EOF

chmod +x /home/kali/lab-scripts/*.sh
chown -R kali:kali /home/kali/lab-scripts

# Actualizar Metasploit
echo "Actualizando Metasploit..."
msfupdate

echo "Configuración avanzada de Metasploit completada"