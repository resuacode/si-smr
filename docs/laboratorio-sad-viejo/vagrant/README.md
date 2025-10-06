# Laboratorio SAD - Despliegue con Vagrant

## 🤖 Descripción

Vagrant es una herramienta de automatización que permite crear y configurar entornos de desarrollo de manera reproducible. Con Vagrant, puedes levantar todo el laboratorio con un solo comando y destruirlo cuando termines.

## � Ventajas de Usar Vagrant

✅ **Automatización completa**: Un comando levanta todo el lab  
✅ **Reproducibilidad**: Mismo entorno en cualquier máquina  
✅ **Versionado**: Configuración como código (IaC)  
✅ **Snapshots automáticos**: Estados guardados automáticamente  
✅ **Limpieza fácil**: `vagrant destroy` elimina todo  
✅ **Aprendizaje DevOps**: Herramienta industry-standard  

## 📋 Prerrequisitos

### Software Necesario
```bash
# 1. VirtualBox 7.0+
# Descargar desde: https://www.virtualbox.org/

# 2. Vagrant 2.2+
# Descargar desde: https://www.vagrantup.com/

# 3. Git (para clonar repositorio)
# Windows: https://git-scm.com/
# Linux: sudo apt install git
# macOS: brew install git
```

### Verificar Instalación
```bash
# Comprobar versiones
vagrant --version    # Debe mostrar 2.2.x o superior
vboxmanage --version # Debe mostrar 7.0.x o superior
git --version        # Cualquier versión reciente
```

### Plugins Recomendados de Vagrant
```bash
# Plugin para recargar VMs (útil para cambios de kernel)
vagrant plugin install vagrant-reload

# Plugin para mejor gestión de VirtualBox
vagrant plugin install vagrant-vbguest
```

## 📁 Estructura del Laboratorio

```
laboratorio-sad/vagrant/
├── Vagrantfile                     # Configuración principal
├── deploy-lab.sh                   # 🆕 Script maestro de despliegue
├── provision/                      # Scripts de aprovisionamiento
│   ├── common/
│   │   └── update-system.sh
│   ├── ubuntu-server/
│   │   ├── install-services.sh
│   │   ├── configure-ssh.sh
│   │   └── setup-firewall.sh
│   ├── kali-security/
│   │   ├── configure-metasploit.sh
│   │   ├── setup-wireshark.sh
│   │   ├── update-tools.sh
│   │   └── setup-environment.sh
│   ├── storage-backup/
│   │   ├── install-backup-tools.sh
│   │   ├── configure-samba.sh
│   │   └── setup-bacula.sh
│   ├── windows-server/
│   │   ├── basic-config.ps1
│   │   └── install-services.ps1
│   └── windows-client/
│       └── basic-config.ps1
└── configs/                        # 🆕 Archivos de configuración
    ├── network-config.md
    ├── samba.conf
    ├── apache.conf
    ├── mysql.conf
    ├── bacula.conf
    └── docker.conf
```

## 🚀 Guía de Despliegue Rápido

### 🎯 Método Recomendado: Script Maestro

```bash
# 1. Verificar que todo esté listo
./deploy-lab.sh check

# 2. Desplegar todo el laboratorio
./deploy-lab.sh deploy

# 3. Ver estado de las VMs
./deploy-lab.sh status

# 4. 🆕 Probar conectividad del laboratorio
./deploy-lab.sh test

# 5. 🆕 Crear snapshot del estado inicial
./deploy-lab.sh snapshot "Estado-Inicial-Limpio"

# 6. Exportar a OVAs (opcional)
./deploy-lab.sh export
```

### 🔧 Comandos del Script Maestro

| Comando | Descripción |
|---------|------------|
| `./deploy-lab.sh check` | Verificar dependencias y scripts |
| `./deploy-lab.sh status` | Mostrar estado de las VMs |
| `./deploy-lab.sh deploy` | Desplegar todas las VMs |
| `./deploy-lab.sh deploy-vm <nombre>` | Desplegar VM específica |
| `./deploy-lab.sh test` | 🆕 Probar conectividad del laboratorio |
| `./deploy-lab.sh snapshot [nombre]` | 🆕 Crear snapshots de todas las VMs |
| `./deploy-lab.sh cleanup` | Limpiar VMs con errores |
| `./deploy-lab.sh export` | Exportar VMs a formato OVA |
| `./deploy-lab.sh destroy` | Destruir todas las VMs |

## 📊 Configuración de VMs

| VM | Hostname | IP | RAM | CPUs | Servicios Principales |
|---|---|---|---|---|---|
| Ubuntu Server | ubuntu-server | 192.168.56.10 | 2GB | 2 | Apache, MySQL, SSH, Docker |
| Windows Server | windows-server | 192.168.56.11 | 4GB | 2 | AD DS, DNS, DHCP, IIS |
| Windows Client | windows-client | 192.168.56.12 | 2GB | 2 | Cliente del dominio |
| Storage Backup | storage-backup | 192.168.56.13 | 2GB | 2 | Samba, NFS, Bacula |
| Kali Security | kali-security | 192.168.56.20 | 3GB | 2 | Herramientas de seguridad |

## 🌐 Puertos de Acceso

| Servicio | URL/Comando | Credenciales |
|----------|-------------|--------------|
| SSH Ubuntu | `ssh -p 2210 admin@localhost` | admin:adminSAD2024! |
| Apache Web | http://localhost:8010 | - |
| phpMyAdmin | http://localhost:8010/phpmyadmin | sadlab_user:sadlab_pass |
| Portainer | http://localhost:9000 | admin:admin123 |
| RDP Windows Server | `localhost:3389` | vagrant:vagrant ó labadmin:Password123! |
| RDP Windows Client | `localhost:3390` | vagrant:vagrant ó cliente:User123! |
| SMB Storage | `\\localhost:4445\shared` | backup:backup123 |
| SSH Kali | `ssh -p 2220 kali@localhost` | kali:kali |
| SSH Storage | `ssh -p 2213 backup@localhost` | backup:backup123 |

## 🛠️ Instalación y Uso Manual



### Paso 2: Verificación Previa

```bash
# Verificar recursos del sistema
free -h          # RAM disponible (recomendado: 16GB+)
nproc           # CPUs disponibles (recomendado: 8+)
df -h           # Espacio en disco (recomendado: 50GB+)

# Verificar que todos los scripts estén presentes
./deploy-lab.sh check
```

### Paso 3: Despliegue

#### Opción A: Despliegue Automático (Recomendado)
```bash
./deploy-lab.sh deploy
```

#### Opción B: Despliegue Manual VM por VM
```bash
# Empezar por Ubuntu Server (servicios base)
vagrant up ubuntu-server

# Luego Storage (dependencias compartidas)
vagrant up storage-backup

# Después las VMs de prueba
vagrant up kali-security

# Finalmente Windows (más pesadas)
vagrant up windows-server
vagrant up windows-client
```

### Paso 4: Verificación Post-Despliegue

```bash
# Ver estado general
./deploy-lab.sh status

# Probar conectividad
vagrant ssh ubuntu-server -c "curl -I http://localhost"
vagrant ssh ubuntu-server -c "docker ps"
```

### Paso 5: Validación y Snapshots 🆕

#### Probar Conectividad del Laboratorio
```bash
# Ejecutar suite completa de pruebas
./deploy-lab.sh test

# Esto verifica:
# ✅ Estado de todas las VMs (running/stopped)
# ✅ SSH en VMs Linux (ubuntu-server, storage-backup, kali-security)
# ✅ WinRM en VMs Windows (windows-server, windows-client)
# ✅ Conectividad de red interna entre VMs
# ✅ Timeouts automáticos para evitar bloqueos
```

#### Crear Snapshots del Estado Inicial
```bash
# Snapshot con nombre personalizado
./deploy-lab.sh snapshot "Estado-Inicial-Limpio"

# Snapshot con timestamp automático
./deploy-lab.sh snapshot

# Los snapshots incluyen:
# 📸 Estado completo de todas las VMs
# 🔄 Punto de restauración para estudiantes
# ⚡ Recuperación rápida después de ejercicios destructivos
```

**💡 Recomendación**: Crear siempre un snapshot del estado inicial antes de comenzar ejercicios prácticos.

## 🔧 Gestión del Laboratorio

### Comandos Básicos de Vagrant

```bash
# Ver estado de todas las VMs
vagrant status

# Conectar por SSH a una VM
vagrant ssh <vm-name>

# Reiniciar una VM
vagrant reload <vm-name>

# Suspender/reanudar
vagrant suspend <vm-name>
vagrant resume <vm-name>

# Destruir una VM específica
vagrant destroy <vm-name> -f

# Destruir todo el laboratorio
vagrant destroy -f
```

### Snapshots para Puntos de Restauración

#### Opción A: Automática (Recomendado) 🆕
```bash
# Crear snapshots de todas las VMs simultáneamente
./deploy-lab.sh snapshot "Nombre-Descriptivo"

# Ejemplo práctico
./deploy-lab.sh snapshot "Antes-Ejercicio-XSS"
./deploy-lab.sh snapshot "Configuracion-Base-Completada"
```

#### Opción B: Manual (VM Individual)
```bash
# Crear snapshot de una VM específica
vagrant snapshot save <vm-name> "nombre-snapshot"

# Listar snapshots
vagrant snapshot list <vm-name>

# Restaurar snapshot
vagrant snapshot restore <vm-name> "nombre-snapshot"

# Eliminar snapshot
vagrant snapshot delete <vm-name> "nombre-snapshot"
```

**💾 Restauración de Snapshots Automáticos**
```bash
# Los snapshots creados con deploy-lab.sh se restauran con VirtualBox:
VBoxManage snapshot <VM-Name> restore "Nombre-Snapshot"

# Ejemplo:
VBoxManage snapshot "SAD-Ubuntu-Server" restore "Estado-Inicial-Limpio"
```

## 📂 Exportación a OVAs

### Automática (Recomendado)
```bash
./deploy-lab.sh export
```
Esto creará una carpeta `ovas/` con todos los archivos OVA.

### Manual
```bash
# Detener VMs si están corriendo
vagrant halt

# Exportar cada VM
VBoxManage export "sadlab_ubuntu-server" --output "ubuntu-server.ova"
VBoxManage export "sadlab_windows-server" --output "windows-server.ova"
# ... etc para cada VM
```

## 🚨 Troubleshooting Común

### Error: Scripts de aprovisionamiento faltantes
```bash
# Verificar que todos los scripts estén presentes
./deploy-lab.sh check

# Si faltan scripts, descargar de nuevo el repositorio
```

### Error: No hay suficientes recursos
```bash
# Reducir RAM/CPUs en Vagrantfile
# Editar valores en la sección de cada VM:
vb.memory = "1024"  # Reducir de 2048 a 1024
vb.cpus = 1         # Reducir de 2 a 1
```

### Error: VM no arranca
```bash
# Limpiar y reintentar
vagrant destroy <vm-name> -f
./deploy-lab.sh deploy-vm <vm-name>
```

### Error: Red no funciona
```bash
# Verificar configuración de red en VirtualBox
# Reiniciar servicios de red
vagrant reload <vm-name>
```

### Error: Vagrant version comparison
```bash
# Asegúrate de usar la última versión del deploy-lab.sh
# que incluye la corrección para comparación de versiones
```

### 🆕 Diagnóstico con Funciones Nuevas

#### Verificar conectividad del laboratorio
```bash
# Ejecutar suite completa de pruebas
./deploy-lab.sh test

# Si fallan las pruebas SSH/WinRM:
# 1. Verificar que las VMs estén completamente iniciadas
# 2. Reintentar después de 5 minutos
# 3. Reiniciar VM problemática: vagrant reload <vm-name>
```

#### Recuperar estado de snapshot
```bash
# Si el laboratorio se corrompe durante ejercicios
# 1. Crear snapshot preventivo antes de ejercicios:
./deploy-lab.sh snapshot "Antes-Ejercicio-Riesgoso"

# 2. Restaurar snapshot si es necesario:
VBoxManage snapshot "SAD-Ubuntu-Server" restore "Antes-Ejercicio-Riesgoso"
VBoxManage snapshot "SAD-Windows-Server" restore "Antes-Ejercicio-Riesgoso"
# ... etc para cada VM

# 3. Verificar que todo funciona:
./deploy-lab.sh test
```

#### Error: Snapshot falló
```bash
# Si el comando snapshot falla:
# 1. Verificar que VirtualBox esté funcionando
VBoxManage list vms

# 2. Verificar que las VMs estén disponibles
./deploy-lab.sh status

# 3. Crear snapshot manual si es necesario:
VBoxManage snapshot "SAD-Ubuntu-Server" take "Snapshot-Manual"
```

## 🔍 Configuraciones Avanzadas

### Personalización de Red

Edita el `Vagrantfile` para cambiar el rango de IPs:

```ruby
# Cambiar la red privada
config.vm.network "private_network", type: "dhcp", 
  virtualbox__intnet: "sadlab_network",
  virtualbox__dhcp_enabled: false
```

### Recursos por VM

Ajusta RAM y CPUs según tu hardware:

```ruby
vb.memory = "4096"  # 4GB RAM
vb.cpus = 4         # 4 CPUs
```

### Carpetas Compartidas

```ruby
# Compartir carpeta adicional
config.vm.synced_folder "./shared", "/vagrant/shared"
```

## 📚 Recursos Adicionales

### Documentación Oficial
- [Vagrant Docs](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)

### Configuraciones de Referencia
- [Configuración de Red](configs/network-config.md)
- [Configuración Samba](configs/samba.conf)
- [Configuración Apache](configs/apache.conf)
- [Configuración MySQL](configs/mysql.conf)
- [Configuración Bacula](configs/bacula.conf)
- [Configuración Docker](configs/docker.conf)

## 🚀 Instalación y Uso

### Paso 1: Obtener el Código

#### Opción A: Clonar repositorio completo
```bash
git clone <url-repositorio>
cd laboratorio-sad/vagrant
```

#### Opción B: Solo archivos Vagrant
```bash
mkdir laboratorio-sad
cd laboratorio-sad
# Descargar archivos individuales de la carpeta vagrant/
```

### Paso 2: Configuración Inicial

#### 2.1 Revisar Vagrantfile
```bash
# Editar configuración si es necesario
nano Vagrantfile

# Ajustar según tu hardware:
# - RAM por VM
# - CPUs por VM  
# - Configuración de red
```

#### 2.2 Verificar recursos disponibles
```bash
# Linux/macOS
free -h           # RAM disponible
nproc            # CPUs disponibles
df -h            # Espacio en disco

# Windows (PowerShell)
Get-ComputerInfo | Select-Object TotalPhysicalMemory, CsProcessors
Get-PSDrive C    # Espacio en disco
```

### Paso 3: Levantar el Laboratorio

#### 3.1 Iniciar todas las VMs
```bash
# Crear y configurar todas las VMs
vagrant up

# Este proceso puede tomar 30-60 minutos en la primera ejecución
# Vagrant descargará las boxes base y ejecutará scripts de provisioning
```

#### 3.2 Iniciar VMs específicas
```bash
# Solo Ubuntu Server
vagrant up ubuntu-server

# Solo herramientas de seguridad
vagrant up kali-security

# Windows Server + Client
vagrant up windows-server windows-client
```

#### 3.3 Verificar estado
```bash
# Estado de todas las VMs
vagrant status

# Estado global más detallado
vagrant global-status
```

### Paso 4: Gestión del Laboratorio

#### 4.1 Conectarse a las VMs
```bash
# SSH a Ubuntu Server
vagrant ssh ubuntu-server

# SSH a Kali (si tiene SSH configurado)
vagrant ssh kali-security

# Para Windows, usar RDP o consola de VirtualBox
```

#### 4.2 Comandos útiles
```bash
# Reiniciar VM específica
vagrant reload ubuntu-server

# Suspender todas las VMs
vagrant suspend

# Reanudar todas las VMs
vagrant resume

# Reconfigurar (ejecutar provisioning de nuevo)
vagrant provision ubuntu-server

# Ver configuración SSH
vagrant ssh-config ubuntu-server
```

#### 4.3 Snapshots y respaldos
```bash
# Crear snapshot de estado actual
vagrant snapshot save ubuntu-server "configuracion-inicial"

# Listar snapshots
vagrant snapshot list ubuntu-server

# Restaurar snapshot
vagrant snapshot restore ubuntu-server "configuracion-inicial"

# Eliminar snapshot
vagrant snapshot delete ubuntu-server "configuracion-inicial"
```

## ⚙️ Configuración Detallada

### Vagrantfile Principal

El archivo principal define:
- **5 VMs** con sus especificaciones
- **Red privada** 192.168.56.0/24
- **Scripts de provisioning** automáticos
- **Forwarded ports** para acceso desde host
- **Configuración de recursos** adaptable

### Scripts de Provisioning

Cada VM ejecuta scripts específicos:

#### Ubuntu Server
- Actualización del sistema
- Instalación de Docker, SSH, UFW
- Configuración de servicios de red
- Herramientas de monitoreo (htop, iotop)

#### Windows Server
- Instalación de roles AD DS, DNS, DHCP
- Configuración de dominio SAD.local
- Políticas de grupo básicas
- Herramientas administrativas

#### Kali Security
- Actualización de herramientas
- Configuración de Metasploit
- Wireshark con permisos
- Scripts personalizados

#### Storage Backup
- Servicios Samba y NFS
- Cliente Bacula
- Scripts de backup automatizados
- Configuración de rclone

## 🔧 Personalización

### Modificar Recursos de VMs
```ruby
# En Vagrantfile, buscar sección de cada VM:
config.vm.provider "virtualbox" do |vb|
  vb.memory = "4096"    # Cambiar RAM
  vb.cpus = 2          # Cambiar CPUs
  vb.gui = false       # true para ver interfaz gráfica
end
```

### Añadir Software Personalizado
```bash
# Crear script en provision/custom/
# Añadir al Vagrantfile:
config.vm.provision "shell", path: "provision/custom/mi-software.sh"
```

### Configurar Red Diferente
```ruby
# Cambiar rango de red en Vagrantfile:
config.vm.network "private_network", ip: "10.0.1.10"  # Nueva IP
```

## 🎓 Comandos de Aprendizaje

### Para Estudiantes Nuevos en Vagrant
```bash
# Tutorial básico
vagrant init ubuntu/jammy64    # Crear Vagrantfile básico
vagrant up                     # Levantar VM
vagrant ssh                    # Conectar por SSH
vagrant halt                   # Apagar VM
vagrant destroy                # Eliminar VM

# Ver ayuda
vagrant --help
vagrant <comando> --help
```

### Workflow Típico de Desarrollo
```bash
# 1. Levantar laboratorio
vagrant up

# 2. Trabajar en ejercicios
vagrant ssh ubuntu-server

# 3. Hacer cambios, crear snapshot
vagrant snapshot save "ejercicio-completado"

# 4. Si algo se rompe, restaurar
vagrant snapshot restore "ejercicio-completado"

# 5. Al terminar, limpiar
vagrant destroy
```

## 📊 Monitoreo y Logs

### Ver logs de provisioning
```bash
# Logs en tiempo real
vagrant up --debug

# Logs específicos de VM
vagrant provision ubuntu-server --debug
```

### Verificar estado de servicios
```bash
# Ejecutar comandos remotos
vagrant ssh ubuntu-server -c "systemctl status ssh"
vagrant ssh kali-security -c "service metasploit status"
```

## 🚨 Troubleshooting Vagrant

### Problema: Box no se descarga
```bash
# Agregar box manualmente
vagrant box add ubuntu/jammy64
vagrant box add kalilinux/rolling

# Verificar boxes instaladas
vagrant box list
```

### Problema: VM no inicia
```bash
# Reiniciar con logs detallados
vagrant destroy
vagrant up --debug

# Verificar configuración VirtualBox
VBoxManage list vms
VBoxManage showvminfo <vm-name>
```

### Problema: Provisioning falla
```bash
# Re-ejecutar solo provisioning
vagrant provision ubuntu-server

# Ejecutar shell específico
vagrant ssh ubuntu-server -c "sudo /vagrant/provision/ubuntu-server/install-services.sh"
```

### Problema: Red no funciona
```bash
# Verificar configuración de red
vagrant ssh ubuntu-server -c "ip addr show"
vagrant ssh ubuntu-server -c "ping 192.168.56.1"

# Reiniciar red en VM
vagrant reload ubuntu-server
```

## 📖 Recursos de Aprendizaje

### Documentación Oficial
- [Vagrant Docs](https://www.vagrantup.com/docs)
- [VirtualBox Manual](https://www.virtualbox.org/manual/)

### Tutoriales Recomendados
- [Vagrant Tutorial - HashiCorp Learn](https://learn.hashicorp.com/vagrant)

## 📖 Siguiente Paso

Una vez completada la instalación con Vagrant:
👉 **[Configuración Post-Instalación](../documentacion/post-configuracion.md)**

## 🏆 Ejercicios Avanzados con Vagrant

Después de dominar lo básico, prueba:
1. **Multi-provider**: Usar AWS/Azure además de VirtualBox
2. **Vagrant Cloud**: Compartir boxes personalizadas
3. **Ansible integration**: Provisioning con Ansible
4. **Custom boxes**: Crear tus propias boxes
