# Archivo de configuración del laboratorio SAD

Este archivo contiene instrucciones y configuraciones esenciales para la correcta instalación y funcionamiento del laboratorio SAD de máquinas virtuales en VirtualBox.

## Configuraciones comunes para todas las máquinas virtuales (VMs)

- **Red:** Todas las VMs deben estar configuradas para usar la red "Red solo-anfitrión" (vboxnet-sad).
- **NAT:** Habilitar un adaptador NAT adicional para acceso a Internet.
- **IP Estáticas:** Cada VM tiene una IP estática asignada como se detalla en la sección de configuración específica por VM.
- **Hostname:** Configurar el hostname de cada VM según su función (ej. ubuntu-server, windows-server, etc.).
- **Grupo de trabajo:** Todas las VMs Windows deben pertenecer al mismo grupo de trabajo llamado `LAB-SAD`.

- **Clones enlazados:** Crear las VMs como clones enlazados para ahorrar espacio en disco a partir de la box base y mantener la posibilidad de restaurar el estado inicial fácilmente.

- **Snapshots:** Tomar un snapshot inicial de cada VM después de la configuración básica para facilitar la restauración en caso de errores.

- **Credenciales por defecto:** 
  - Todas las VMs tienen un usuario `vagrant` con contraseña `vagrant` para acceso inicial.
  - También existen usuarios específicos para cada sistema operativo, detallados en la sección de configuración inicial.
  - El acceso a las máquinas debe ser posible utilizando vagrant/ssh o RDP según el sistema operativo. También tiene que ser posible acceder iniciandolas normalmente y usando las credenciales indicadas.

- **Teclado:** Configurar el teclado en español (ES) en todas las VMs.

- **Zona horaria:** Configurar la zona horaria a Europa/Madrid en todas las VMs.

- **Guest Additions:** Instalar las Guest Additions de VirtualBox en todas las VMs para mejorar el rendimiento y la integración.

- **SSH:** Habilitar el acceso SSH en las VMs para que sea posible conectarse entre ellas y también desde el host.

- **RDP:** Habilitar el acceso RDP en las VMs con Windows para facilitar la administración.

## Configuración específica por VM

### Ubuntu Server (192.168.56.10)
**OS**: Ubuntu Server 22.04 LTS
**Recursos**: 1.5GB RAM, 1 vCPU, 15GB disco
**Servicios básicos**:
- Apache2 (puerto 80)
- MySQL/MariaDB (puerto 3306) 
- SSH (puerto 22) - CONFIGURADO PARA ACCESO EXTERNO
- PHP básico
**Usuarios**:
- vagrant:vagrant (con sudo)
- admin:adminSAD2024! (con sudo)
**Configuración especial**:
- SSH debe permitir login con contraseña
- Firewall deshabilitado inicialmente
- Apache con sitio por defecto funcional

### Windows Server (192.168.56.11)
**OS**: Windows Server 2022 Standard Core
**Recursos**: 2GB RAM, 1 vCPU, 25GB disco
**Servicios básicos**:
- IIS básico (puerto 80)
- RDP habilitado (puerto 3389)
- SMB shares básicos
- WinRM habilitado y funcional
**Usuarios**:
- vagrant:vagrant
- labadmin:Password123! (administrador local)
**Configuración especial**:
- NO instalar Active Directory
- Firewall configurado para permitir ping
- SMB share: C:\Shares\Public (acceso total)

### Kali Security (192.168.56.20)
**OS**: Kali Linux Rolling
**Recursos**: 2GB RAM, 1 vCPU, 15GB disco
**Servicios básicos**:
- SSH (puerto 22) - CONFIGURADO PARA ACCESO EXTERNO
- Herramientas básicas de pentesting
**Usuarios**:
- vagrant:vagrant (con sudo)
- kali:kali (con sudo)
**Configuración especial**:
- SSH debe permitir login con contraseña
- Herramientas: nmap, metasploit-framework, wireshark-cli
- Metasploit sin configuración de BD (manual después)

### Storage Backup (192.168.56.13)
**OS**: Debian 12 Minimal
**Recursos**: 1GB RAM, 1 vCPU, 10GB disco
**Servicios básicos**:
- SSH (puerto 22) - CONFIGURADO PARA ACCESO EXTERNO
- Samba básico (puerto 445)
- NFS básico (puerto 2049)
**Usuarios**:
- vagrant:vagrant (con sudo)
- backup:backup123 (con sudo)
**Configuración especial**:
- SSH debe permitir login con contraseña
- Samba share: /srv/samba/public (acceso público)
- SIN discos adicionales complejos

### Windows Client (192.168.56.12)
**OS**: Windows 10 LTSC o similar
**Recursos**: 2GB RAM, 1 vCPU, 20GB disco
**Servicios básicos**:
- RDP habilitado (puerto 3389)
- WinRM habilitado
**Usuarios**:
- vagrant:vagrant
- cliente:User123! (usuario estándar)
**Configuración especial**:
- Firewall configurado para permitir ping
- Sin software adicional

### Scripts de Provisioning
- Máximo 1 script por VM
- Manejo de errores con try-catch
- Logs claros de progreso
- Sin reinicios automáticos
- Verificar configuración de red

## Documentación y Soporte
- Crear un documento README.md con instrucciones de uso, instalación y configuración, dónde se debe incluir:
    - Descripción del laboratorio
    - Requisitos previos (VirtualBox, Vagrant, etc.)
    - Instrucciones de importación o creación de VMs
    - Credenciales de acceso
    - Comandos básicos para verificar estado y conectividad
    - Ejemplos de uso de herramientas incluidas
- Incluir un archivo de configuracion-proxy.md con instrucciones para configurar un proxy si es necesario en cada VM, incluyendo ejemplos de configuración para apt, yum, npm, pip, etc.
- Incluir un archivo de troubleshooting.md con problemas comunes y soluciones
- Incluir un archivo post-configuracion.md con pasos recomendados después de la instalación (snapshots, actualizaciones, etc.)

El objetivo final del laboratorio es que sea posible instalarlo utilizando vagrant o importando OVAs, y que todas las máquinas estén listas para usarse con la configuración mínima necesaria para prácticas de seguridad informática, de sistemas y redes.

Tener en cuenta que para la instalación mediante vagrant, el objetivo no es que el estudiantado tenga acceso al repositorio, si no al propio md, que debe incluir todos los archivos y scripts necesarios, de hecho, el propio Vagrantfile debe estar en el mismo md, para que puedan copiarlo y pegarlo en su propio entorno. Se recomienda para esto usar un archivo mdx que pueda incluir un desplegable con el código del Vagrantfile y los archivos de provisioning.

Para la instalación mediante OVAs, se incluirán enlaces de descarga que se actualizarán con la dirección del repositorio dónde se encuentren alojadas las OVAs. (Un enlace por cada OVA).
El objetivo es que el estudiante pueda elegir entre ambas opciones, y que ambas sean lo más sencillas posibles.