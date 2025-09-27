# Guía de Resolución de Problemas

## Problemas Comunes con Vagrant

### 1. Error de VirtualBox

**Problema:** `VBoxManage: error: Failed to create the host-only adapter`

**Solución:**
```bash
# En Linux
sudo modprobe vboxdrv
sudo /sbin/vboxconfig

# Reiniciar VirtualBox
sudo systemctl restart virtualbox
```

**Problema:** `Vagrant cannot forward the specified ports`

**Solución:**
```bash
# Verificar puertos en uso
netstat -tuln | grep :2222

# Cambiar puerto en Vagrantfile si es necesario
config.vm.network "forwarded_port", guest: 22, host: 2223
```

### 2. Problemas de Red

**Problema:** Las VMs no se comunican entre sí

**Verificaciones:**
```bash
# Dentro de cada VM
ip addr show
ping 192.168.56.10  # Desde cualquier VM al servidor

# Verificar configuración de red de VirtualBox
VBoxManage list hostonlyifs
```

**Solución:**
```bash
# Recrear red host-only si es necesario
VBoxManage hostonlyif remove vboxnet0
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0
```

### 3. Problemas de Aprovisionamiento

**Problema:** Script de aprovisionamiento falla

**Verificación:**
```bash
# Ver logs detallados
vagrant up --debug

# Re-ejecutar aprovisionamiento
vagrant provision
```

**Problema:** Windows no puede ejecutar PowerShell scripts

**Solución:**
```powershell
# Dentro de la VM Windows
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Problemas de Recursos

**Problema:** VM no arranca por falta de memoria

**Solución:**
- Reducir memoria asignada en Vagrantfile
- Cerrar VMs no necesarias
- Verificar memoria disponible del host

### 5. Problemas de SSH/RDP

**Problema:** No se puede acceder por SSH/RDP

**Verificaciones:**
```bash
# Estado del servicio SSH (Linux)
sudo systemctl status ssh

# Estado del firewall
sudo ufw status
```

**Para Windows RDP:**
```powershell
# Verificar RDP habilitado
Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections"

# Habilitar RDP si es necesario
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
```

## Problemas Comunes con OVAs

### 1. Importación de OVA

**Problema:** Error al importar OVA

**Verificaciones:**
- Verificar espacio en disco suficiente
- Comprobar integridad del archivo OVA
- Verificar versión de VirtualBox compatible

**Solución:**
```bash
# Verificar integridad
sha256sum archivo.ova

# Importar con más memoria si es necesario
VBoxManage import archivo.ova --memory 2048
```

### 2. Configuración de Red

**Problema:** VM importada no tiene conectividad

**Solución:**
1. Configurar adaptador de red en VirtualBox
2. Seleccionar "Red solo-anfitrión (vboxnet0)"
3. Configurar IP estática en la VM

### 3. Credenciales de Acceso

**Problema:** No se pueden recordar las credenciales

**Credenciales por defecto:**

**Ubuntu Server (192.168.56.10):**
- Usuario: `vagrant` / Password: `vagrant`
- Usuario: `admin` / Password: `admin123`

**Kali Linux (192.168.56.20):**
- Usuario: `kali` / Password: `kali`

**Windows Server (192.168.56.11):**
- Usuario: `labadmin` / Password: `Password123!`
- Usuario: `Administrator` / Password: `vagrant`

**Windows Client (192.168.56.12):**
- Usuario: `cliente` / Password: `User123!`
- Usuario: `clienteadmin` / Password: `User123!`

**Storage/Backup (192.168.56.13):**
- Usuario: `vagrant` / Password: `vagrant`
- Usuario: `backup` / Password: `backup123`

## Comandos de Diagnóstico Útiles

### Verificación de Red
```bash
# Ping a todas las VMs del laboratorio
ping -c 3 192.168.56.10  # Ubuntu Server
ping -c 3 192.168.56.11  # Windows Server
ping -c 3 192.168.56.12  # Windows Client
ping -c 3 192.168.56.13  # Storage/Backup
ping -c 3 192.168.56.20  # Kali Linux

# Escaneo de puertos básico
nmap -sV 192.168.56.10-13
```

### Verificación de Servicios
```bash
# Ubuntu Server
sudo systemctl status ssh apache2 mysql

# Storage/Backup
sudo systemctl status smbd vsftpd

# Verificar puertos abiertos
netstat -tuln
```

### Windows PowerShell
```powershell
# Verificar servicios de Windows
Get-Service | Where-Object {$_.Status -eq "Running"}

# Verificar conexiones de red
Get-NetTCPConnection | Where-Object {$_.State -eq "Listen"}

# Verificar firewall
Get-NetFirewallProfile
```

## Recuperación de Errores

### Reset Completo con Vagrant
```bash
# Destruir todas las VMs
vagrant destroy -f

# Limpiar cache de Vagrant
vagrant box remove ubuntu/focal64
vagrant box remove kalilinux/rolling

# Recrear desde cero
vagrant up
```

### Reset de VM Individual
```bash
# Solo una VM específica
vagrant destroy ubuntu-server -f
vagrant up ubuntu-server
```

### Backup y Restauración
```bash
# Crear snapshot antes de cambios importantes
VBoxManage snapshot "VM_Name" take "snapshot_name"

# Restaurar snapshot
VBoxManage snapshot "VM_Name" restore "snapshot_name"
```

## Contacto y Soporte

Si los problemas persisten:

1. **Documentar el error:** Copiar mensajes de error completos
2. **Verificar logs:** `vagrant up --debug > debug.log 2>&1`
3. **Verificar requisitos:** Versiones de VirtualBox, Vagrant, recursos del sistema
4. **Consultar documentación:** https://www.vagrantup.com/docs

## Logs Importantes

### Vagrant
- `~/.vagrant.d/logs/` - Logs de Vagrant
- Salida de `vagrant up --debug`

### VirtualBox
- En Linux: `~/.config/VirtualBox/VBoxSVC.log`
- En Windows: `%USERPROFILE%\.VirtualBox\VBoxSVC.log`

### Laboratorio
- `/backup/logs/` - Logs del sistema de backup
- `/var/log/` - Logs del sistema en Linux
- Event Viewer en Windows
