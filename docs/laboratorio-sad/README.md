# Laboratorio Virtual - Seguridad y Alta Disponibilidad

Este repositorio contiene las configuraciones y documentación necesarias para montar el laboratorio virtual del módulo de Seguridad y Alta Disponibilidad (SAD) de 2º ASIR.

## 📋 Requisitos del Sistema

### Hardware Mínimo del Host
- **CPU**: Intel/AMD con soporte de virtualización (VT-x/AMD-V)
- **RAM**: 8 GB (recomendado 16 GB para todas las VMs simultáneas)
- **Almacenamiento**: 80 GB libres (120 GB recomendado)
- **Red**: Conexión a Internet para descargas iniciales

### Configuraciones Flexibles
- **Configuración Mínima (80 GB)**: Solo 2-3 VMs ejecutándose simultáneamente
- **Configuración Estándar (120 GB)**: Todas las VMs disponibles
- **Configuración Completa (200 GB)**: Con espacio para snapshots y backups

### Software Requerido
- **VirtualBox 7.0** o superior
- **Vagrant 2.3+** (opcional, para automatización)
- **Git** (para clonar repositorio)
- **7-Zip/WinRAR** (para extraer OVAs)

## 🏗️ Arquitectura del Laboratorio

### Máquinas Virtuales (Configuración Optimizada)
| VM | OS | RAM | CPU | Disco | IP | Función |
|----|----|----|-----|-------|----|---------| 
| **Ubuntu-Server** | Ubuntu Server 22.04 LTS | 1.5 GB | 1 vCPU | 15 GB | 192.168.56.10 | Servicios web, SSH |
| **Windows-Server** | Windows Server 2019 Core | 2 GB | 1 vCPU | 25 GB | 192.168.56.11 | IIS, SMB, RDP |
| **Windows-Client** | Windows 10 LTSC | 2 GB | 1 vCPU | 20 GB | 192.168.56.12 | Cliente final |
| **Kali-Security** | Kali Linux Rolling | 2 GB | 1 vCPU | 15 GB | 192.168.56.20 | Pentesting |
| **Storage-Backup** | Debian 12 Minimal | 1 GB | 1 vCPU | 10 GB | 192.168.56.13 | Almacenamiento |

**Total estimado**: ~85 GB | **RAM simultánea**: 8.5 GB

### Configuración de Red
- **Red interna**: `192.168.56.0/24` (Host-Only)
- **NAT**: Para acceso a Internet cuando sea necesario
- **Gateway**: 192.168.56.1 (VirtualBox Host-Only)

## 🎯 Opciones de Instalación

### Opción A: OVAs Preconfiguradas (Recomendado para principiantes)
✅ **Ventajas**: Instalación rápida, configuración previa completa
❌ **Desventajas**: Archivos grandes, menor aprendizaje técnico

**Proceso**:
1. Descargar OVAs desde el repositorio
2. Importar en VirtualBox
3. Configurar red
4. ¡Listo para usar!

👉 **[Ir a guía de OVAs](ovas/README.md)**

### Opción B: Vagrant (Recomendado para avanzados)
✅ **Ventajas**: Automatización, reproducibilidad, aprendizaje IaC
❌ **Desventajas**: Curva de aprendizaje, requiere más tiempo inicial

**Proceso**:
1. Instalar Vagrant
2. Clonar repositorio
3. Ejecutar `vagrant up`
4. Configuración automática

👉 **[Ir a guía de Vagrant](vagrant/README.md)**

## 📚 Documentación Adicional

- **[Guía del Estudiante](documentacion/guia-estudiante.md)** - Instrucciones paso a paso
- **[Troubleshooting](documentacion/troubleshooting.md)** - Solución de problemas comunes
- **[Configuraciones Post-Instalación](documentacion/post-configuracion.md)** - Ajustes finales
- **[Scripts de Automatización](scripts/README.md)** - Herramientas auxiliares
- **[🏢 Configuración de Proxy del Centro](configuracion-proxy/README.md)** - Para uso en red del centro educativo

> ⚠️ **Nota especial**: La configuración de proxy **solo es necesaria** cuando uses el laboratorio dentro de la red del centro educativo. Para uso doméstico, omitir esta sección.

## 🚀 Inicio Rápido

### Para Estudiantes (Opción A - OVAs)
```bash
# 1. Crear directorio de trabajo
mkdir ~/laboratorio-sad
cd ~/laboratorio-sad

# 2. Descargar OVAs (enlaces en ovas/README.md)
# 3. Importar en VirtualBox
# 4. Seguir guía-estudiante.md

# 💡 ¿Tienes recursos limitados?
# Ver: documentacion/recursos-limitados.md
```

## 💾 Optimización de Espacio

### Estrategias para Reducir Uso de Disco

**🎯 Configuración Mínima (80 GB total)**
- Ejecutar solo 2-3 VMs simultáneamente según el ejercicio
- Usar Windows Server Core (sin GUI)
- Desactivar funciones no necesarias
- Limpiar archivos temporales regularmente

**📊 Uso por Ejercicio**
- **Módulo 2-3**: Ubuntu Server + Kali = 30 GB
- **Módulo 4**: Ubuntu Server + Windows Server = 40 GB  
- **Módulo 5**: Ubuntu Server + Storage = 25 GB
- **Módulo 6**: Kali + Storage + Ubuntu = 40 GB

**⚡ Consejos de Optimización**
```bash
# Compactar discos virtuales después de uso
VBoxManage modifymedium disk vm-disk.vdi --compact

# Crear snapshots solo cuando sea necesario
# Eliminar snapshots antiguos regularmente
# Usar formato VDI con asignación dinámica
```

**🔄 Gestión Flexible**
- Crear/eliminar VMs según necesidad del módulo
- Exportar/importar appliances para conservar espacio
- Usar discos duros externos para almacenamiento adicional

### Para Instructores/Avanzados (Opción B - Vagrant)
```bash
# 1. Clonar repositorio
git clone <repositorio-url>
cd laboratorio-sad

# 2. Levantar laboratorio completo
cd vagrant
vagrant up

# 3. Verificar estado
vagrant status
```

## 🔧 Configuración Inicial

### Credenciales por Defecto
| Sistema | Usuario | Contraseña | Notas |
|---------|---------|------------|-------|
| Windows Server | vagrant | vagrant | Usuario Vagrant por defecto |
| Windows Server | labadmin | Password123! | Administrador del laboratorio |
| Windows Server | labuser | Password123! | Usuario estándar |
| Windows Client | vagrant | vagrant | Usuario Vagrant por defecto |
| Windows Client | cliente | User123! | Usuario cliente |
| Windows Client | clienteadmin | User123! | Administrador local |
| Ubuntu Server | admin | adminSAD2024! | Usuario con sudo |
| Kali Linux | kali | kali | Usuario por defecto |
| Storage-Backup | vagrant | vagrant | Usuario Vagrant por defecto |
| Storage-Backup | backup | backup123 | Usuario de servicios |

⚠️ **Importante**: Cambiar todas las contraseñas en el primer uso.

### Red Host-Only en VirtualBox
```
Nombre: vboxnet-sad
Rango: 192.168.100.0/24
DHCP: Deshabilitado (IPs estáticas)
```

## 🆘 Soporte

- **Issues**: Reportar problemas en el repositorio
- **Documentación**: Revisar troubleshooting.md

## 📄 Licencia

Material educativo para uso en el módulo SAD de ASIR.
Distribuido bajo licencia Creative Commons BY-SA.

---
**Última actualización**: Septiembre 2025
**Versión**: 1.0
**Autor**: @ResuaCode
