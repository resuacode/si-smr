#!/bin/bash
# Configuración segura de SSH en Ubuntu Server

echo "========================"
echo "Configurando SSH seguro"
echo "========================"

# Backup de configuración original
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Configuración de seguridad SSH
cat > /etc/ssh/sshd_config.d/99-security.conf << 'EOF'
# Configuración de seguridad SSH para laboratorio SAD

# Cambiar puerto por defecto (para ejercicios)
Port 22

# Autenticación
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Límites de conexión
MaxAuthTries 5
MaxStartups 3:30:10
LoginGraceTime 60

# Configuración de protocolo
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Criptografía segura
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group16-sha512

# Otras configuraciones
X11Forwarding no
AllowTcpForwarding yes
TCPKeepAlive no
ClientAliveInterval 300
ClientAliveCountMax 2

# Banner de aviso
Banner /etc/ssh/ssh_banner
EOF

# Crear banner de advertencia
cat > /etc/ssh/ssh_banner << 'EOF'
***************************************************************************
                    LABORATORIO DE SEGURIDAD - ACCESO RESTRINGIDO
                    
Este sistema es para uso educativo exclusivamente.
Todas las actividades son monitorizadas y registradas.
El acceso no autorizado está prohibido.

Módulo: Seguridad y Alta Disponibilidad (SAD)
***************************************************************************
EOF

# Reiniciar SSH para aplicar cambios
systemctl restart ssh

echo "SSH configurado con ajustes de seguridad"
