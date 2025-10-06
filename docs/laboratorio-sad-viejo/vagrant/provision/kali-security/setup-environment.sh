#!/bin/bash
# Configuración de entorno de análisis y herramientas personalizadas

echo "====================================="
echo "Configurando entorno de pentesting"
echo "====================================="

# Crear directorios de trabajo
mkdir -p /home/kali/Desktop/Laboratorio/{recon,explotacion,informes,scripts}
mkdir -p /home/kali/tools

# Cambiar propietario
chown -R kali:kali /home/kali/Desktop/Laboratorio
chown -R kali:kali /home/kali/tools

# Configurar aliases útiles
cat >> /home/kali/.bashrc << 'EOF'

# Aliases para laboratorio SAD
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ports='netstat -tuln'
alias myip='ip addr show | grep inet'
alias scan='nmap -sV -sC'
alias vulnscan='nmap --script=vuln'
alias searchexp='searchsploit'
alias gobuster-common='gobuster dir -w /usr/share/wordlists/dirb/common.txt'

# Funciones útiles
target_ip() {
    echo "192.168.56.10" > /tmp/target_ip
    echo "Target IP configurada: 192.168.56.10"
}

quick_scan() {
    if [ -z "$1" ]; then
        echo "Uso: quick_scan <IP>"
        return 1
    fi
    nmap -sV -sC -oN /home/kali/Desktop/Laboratorio/recon/scan_$1.txt $1
}
EOF

# Configurar tmux para mejores sesiones de trabajo
cat > /home/kali/.tmux.conf << 'EOF'
# Configuración básica de tmux
set -g prefix C-a
unbind C-b
bind-key C-a send-prefix

# División de ventanas
bind | split-window -h
bind - split-window -v

# Navegación entre paneles
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Activar mouse
set -g mouse on

# Estado de la barra
set -g status-bg colour235
set -g status-fg colour136
EOF

# Crear script de inicio de laboratorio
cat > /home/kali/Desktop/start_lab.sh << 'EOF'
#!/bin/bash
# Script de inicio del laboratorio

echo "==================================="
echo "     LABORATORIO DE SEGURIDAD     "
echo "==================================="
echo ""
echo "IPs del laboratorio:"
echo "- Ubuntu Server: 192.168.56.10"
echo "- Windows Server: 192.168.56.11"
echo "- Windows Client: 192.168.56.12"
echo "- Storage/Backup: 192.168.56.13"
echo "- Kali (esta máquina): 192.168.56.20"
echo ""
echo "Directorios de trabajo:"
echo "- Reconocimiento: ~/Desktop/Laboratorio/recon"
echo "- Explotación: ~/Desktop/Laboratorio/explotacion"
echo "- Informes: ~/Desktop/Laboratorio/informes"
echo "- Scripts: ~/Desktop/Laboratorio/scripts"
echo ""
echo "Comandos útiles configurados:"
echo "- target_ip: Configura IP objetivo"
echo "- quick_scan <IP>: Escaneo rápido"
echo "- gobuster-common <URL>: Directory bruteforce"
echo ""
echo "¡Listo para empezar!"
EOF

chmod +x /home/kali/Desktop/start_lab.sh
chown kali:kali /home/kali/Desktop/start_lab.sh

# Configurar servicios que deben estar corriendo
systemctl enable ssh
systemctl start ssh

# Configurar interfaz de red
cat > /etc/systemd/network/99-vagrant.network << 'EOF'
[Match]
Name=eth1

[Network]
DHCP=no
Address=192.168.56.20/24
Gateway=192.168.56.1
DNS=8.8.8.8
EOF

systemctl enable systemd-networkd

echo "Entorno de análisis configurado"
