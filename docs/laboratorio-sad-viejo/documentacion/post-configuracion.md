# Configuraciones Post-Instalación

Esta guía te ayudará a completar la configuración del laboratorio después de la instalación inicial de las VMs.

## 🔧 Verificaciones Post-Instalación

### 1. Verificar Conectividad de Red

```bash
# Desde tu host, verificar que todas las VMs responden
ping 192.168.56.10  # Ubuntu Server
ping 192.168.56.11  # Windows Server
ping 192.168.56.12  # Windows Client
ping 192.168.56.13  # Storage/Backup
ping 192.168.56.20  # Kali Linux
```

### 2. Verificar Accesos SSH (Linux)

```bash
# Ubuntu Server
ssh admin@192.168.56.10
# Contraseña: admin123

# Kali Linux
ssh kali@192.168.56.20
# Contraseña: kali

# Storage/Backup
ssh vagrant@192.168.56.13
# Contraseña: vagrant
```

### 3. Verificar Accesos RDP (Windows)

**Windows Server (192.168.56.11):**
- Usuario: `labadmin`
- Contraseña: `Password123!`

**Windows Client (192.168.56.12):**
- Usuario: `cliente`
- Contraseña: `User123!`

## ⚙️ Configuraciones Adicionales

### Configurar Resolución DNS Local

En cada VM Linux, añadir entradas al archivo `/etc/hosts`:

```bash
# Editar archivo hosts
sudo nano /etc/hosts

# Añadir estas líneas:
192.168.56.10  ubuntu-server
192.168.56.11  windows-server
192.168.56.12  windows-client
192.168.56.13  storage-backup
192.168.56.20  kali-security
```

### Sincronizar Tiempo (NTP)

```bash
# En Ubuntu/Debian
sudo apt update
sudo apt install ntp
sudo systemctl enable ntp
sudo systemctl start ntp

# En Kali Linux
sudo apt update
sudo apt install ntp
sudo timedatectl set-ntp true
```

### Configurar Firewall Básico

**Ubuntu Server:**
```bash
# Configurar UFW
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw status
```

**Kali Linux:**
```bash
# Desactivar firewall para herramientas de pentesting
sudo ufw disable
```

## 📁 Configurar Directorios de Trabajo

### En tu Host (PC Principal)

```bash
# Crear estructura de directorios
mkdir -p ~/laboratorio-sad/{ejercicios,informes,scripts,evidencias}
mkdir -p ~/laboratorio-sad/ejercicios/{tema2,tema3,tema4,tema5,tema6}
```

### En Kali Linux

```bash
# Crear directorios de trabajo
mkdir -p ~/Desktop/Laboratorio/{recon,explotacion,informes,scripts}
mkdir -p ~/tools
```

## 🔑 Configurar Claves SSH (Opcional)

Para acceso sin contraseña a las VMs Linux:

```bash
# Generar par de claves (en tu host)
ssh-keygen -t rsa -b 4096 -C "laboratorio-sad"

# Copiar clave a Ubuntu Server
ssh-copy-id admin@192.168.56.10

# Copiar clave a Kali Linux
ssh-copy-id kali@192.168.56.20

# Copiar clave a Storage
ssh-copy-id vagrant@192.168.56.13
```

## 📊 Configurar Monitoreo Básico

### Instalar htop en VMs Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install htop

# Usar htop para monitorear recursos
htop
```

### Configurar Logs Centralizados (Opcional)

En Storage/Backup VM:

```bash
# Configurar rsyslog para recibir logs
sudo nano /etc/rsyslog.conf

# Descomentar estas líneas:
# $ModLoad imudp
# $UDPServerRun 514

sudo systemctl restart rsyslog
```

## 🎯 Validar Servicios por VM

### Ubuntu Server
```bash
# Verificar servicios esenciales
sudo systemctl status ssh
sudo systemctl status apache2
sudo systemctl status ufw

# Verificar puertos abiertos
netstat -tuln
```

### Windows Server
```powershell
# Verificar servicios de Windows
Get-Service | Where-Object {$_.Status -eq "Running"}

# Verificar conectividad
Test-NetConnection -ComputerName 192.168.56.10 -Port 22
```

### Kali Linux
```bash
# Actualizar herramientas
sudo apt update && sudo apt upgrade -y

# Verificar herramientas principales
nmap --version
wireshark --version
metasploit-framework --version
```

### Storage/Backup
```bash
# Verificar servicios de almacenamiento
sudo systemctl status smbd
sudo systemctl status vsftpd

# Verificar espacio en disco
df -h
```

## 📸 Crear Snapshots de Estado Limpio

Una vez completada la configuración, crear snapshots:

```bash
# Usando VBoxManage
VBoxManage snapshot "SAD-Ubuntu-Server" take "Estado-Limpio-Configurado"
VBoxManage snapshot "SAD-Windows-Server" take "Estado-Limpio-Configurado"
VBoxManage snapshot "SAD-Windows-Client" take "Estado-Limpio-Configurado"
VBoxManage snapshot "SAD-Kali-Security" take "Estado-Limpio-Configurado"
VBoxManage snapshot "SAD-Storage-Backup" take "Estado-Limpio-Configurado"
```

## 🚨 Troubleshooting Post-Configuración

### Problema: VMs no se comunican
```bash
# Verificar configuración de red VirtualBox
VBoxManage list hostonlyifs

# Recrear red host-only si es necesario
VBoxManage hostonlyif remove vboxnet0
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1
```

### Problema: Servicios no inician
```bash
# Verificar logs de sistema
sudo journalctl -u service-name

# Verificar configuración de firewall
sudo ufw status
```

### Problema: Credenciales no funcionan
```bash
# Resetear contraseña en VM Linux
sudo passwd username

# En Windows, usar usuario local Administrator si hay problemas
```

## ✅ Lista de Verificación Final

- [ ] Todas las VMs responden a ping
- [ ] Acceso SSH funciona en VMs Linux
- [ ] Acceso RDP funciona en VMs Windows
- [ ] Servicios básicos están ejecutándose
- [ ] Resolución DNS local configurada
- [ ] Directorios de trabajo creados
- [ ] Snapshots de estado limpio creados
- [ ] Documentación del laboratorio accesible

## 🔗 Próximos Pasos

Una vez completada la configuración:

1. 📚 Revisar [Guía del Estudiante](guia-estudiante.md)
2. 💾 Consultar [Recursos Limitados](recursos-limitados.md) si es necesario
3. 🔧 Tener a mano [Troubleshooting](troubleshooting.md) para problemas

¡Tu laboratorio está listo para los ejercicios de seguridad!
