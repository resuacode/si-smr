# Guía del Estudiante - Laboratorio SAD

## 👋 Bienvenido al Laboratorio

Esta guía te acompañará paso a paso en la configuración y uso del laboratorio virtual para el módulo de Seguridad y Alta Disponibilidad.

## 🎯 Objetivos de Aprendizaje

Al completar esta guía serás capaz de:
- ✅ Configurar un entorno de laboratorio virtualizado
- ✅ Implementar medidas de seguridad física y lógica
- ✅ Usar herramientas de criptografía y análisis de seguridad
- ✅ Monitorizar y analizar tráfico de red
- ✅ Implementar estrategias de backup y recuperación

## 📋 Antes de Empezar

### Verificaciones Previas - Configuración Optimizada

#### ⚡ Hardware Mínimo (Accesible)
```bash
# Configuración para la mayoría de estudiantes
RAM disponible: 8 GB (deja 4-6 GB para el host)
Espacio en disco: 80 GB libres (120 GB recomendado)
CPU: Cualquier procesador con soporte VT-x/AMD-V

# Si tienes menos recursos:
# Ver guía en documentacion/recursos-limitados.md
```

#### 🔧 Hardware por Configuración
- **Configuración Mínima**: 8 GB RAM + 80 GB disco
- **Configuración Estándar**: 16 GB RAM + 120 GB disco  
- **Configuración Completa**: 32 GB RAM + 200 GB disco

#### 💾 Estrategia Flexible
```
✅ Ejecutar solo VMs necesarias por ejercicio
✅ Usar suspend/resume en lugar de start/stop
✅ Compactar discos virtuales regularmente
✅ Eliminar snapshots antiguos
```

### Estructura de Trabajo Recomendada
```
~/laboratorio-sad/           # Directorio principal
├── vms/                    # Máquinas virtuales
├── ejercicios/             # Tus ejercicios y soluciones
│   ├── tema2-1-seg-fisica/
│   ├── tema2-2-seg-logica/
│   ├── tema2-3-criptografia/
│   ├── tema2-4-amenazas/
│   ├── tema2-5-monitorizacion/
│   └── tema2-6-backup/
├── documentacion/          # Apuntes y referencias
└── herramientas/          # Scripts y utilidades
```

## 🚀 Configuración Inicial

### Paso 1: Elección del Método de Instalación

#### ¿Eres principiante? → Usa OVAs
- ✅ Más rápido de configurar
- ✅ Menos propenso a errores
- ✅ Perfecto para enfocarse en los ejercicios

👉 **[Seguir guía de OVAs](../ovas/README.md)**

#### ¿Quieres aprender más? → Usa Vagrant
- ✅ Aprendes Infrastructure as Code
- ✅ Más reproducible y flexible
- ✅ Herramienta profesional

👉 **[Seguir guía de Vagrant](../vagrant/README.md)**

### Paso 2: Gestión de Recursos (IMPORTANTE)

#### 💡 Para Estudiantes con Hardware Limitado

**Si tienes 8 GB RAM o 80 GB disco**, no ejecutes todas las VMs a la vez:

```bash
# VMs por ejercicio (solo las necesarias)
# Módulo 2-3: Ubuntu + Kali
vagrant up ubuntu-server kali-security

# Módulo 4: Ubuntu + Windows Server  
vagrant up ubuntu-server windows-server

# Módulo 5: Ubuntu + Storage
vagrant up ubuntu-server storage-backup

# Módulo 6: Kali + Storage + Ubuntu
vagrant up kali-security storage-backup ubuntu-server
```

#### 🔄 Comandos de Gestión Inteligente

```bash
# Suspender VMs (más rápido que apagar)
vagrant suspend storage-backup  # Libera RAM, mantiene estado

# Reanudar cuando necesites
vagrant resume storage-backup

# Ver estado y uso de recursos
vagrant status
VBoxManage list runningvms
```

### Paso 3: Verificación de la Instalación

Una vez completada la instalación (OVAs o Vagrant), verifica que todo funciona:

#### 3.1 Test de Conectividad Básico
```bash
# Desde tu host, hacer ping a las VMs (IPs optimizadas)
ping 192.168.56.10  # Ubuntu Server
ping 192.168.56.11  # Windows Server
ping 192.168.56.12  # Windows Client  
ping 192.168.56.13  # Storage Backup
ping 192.168.56.20  # Kali Security
```

#### 3.2 Test de Acceso SSH (Linux)
```bash
# Conectar a Ubuntu Server
ssh admin@192.168.56.10
# Contraseña: adminSAD2024!

# Conectar a Kali Security
ssh kali@192.168.56.20
# Contraseña: kali

# Conectar a Storage Backup
ssh backup@192.168.56.13
# Contraseña: backup123
```

#### 3.3 Test de Acceso RDP (Windows)
```bash
# Conectar a Windows Server: 192.168.56.11
# Usuario: labadmin
# Contraseña: Password123!

# Conectar a Windows Client: 192.168.56.12
# Usuario: cliente  
# Contraseña: User123!
```

### Paso 4: Configuración de Snapshots

**¡MUY IMPORTANTE!** Antes de hacer cualquier ejercicio, crea snapshots:

#### En VirtualBox GUI:
```
1. Seleccionar VM
2. Menú Máquina → Tomar Instantánea
3. Nombre: "Estado-Inicial-Limpio"
4. Descripción: "VM recién instalada y configurada"
5. Repetir para todas las VMs
```

#### Con Vagrant:
```bash
# Crear snapshots de todas las VMs
vagrant snapshot save "estado-inicial"
```

## 📚 Metodología de Trabajo

### Ciclo de Ejercicios Recomendado

1. **📖 Leer teoría** en documentación del tema
2. **🎯 Identificar objetivo** del ejercicio
3. **📷 Crear snapshot** antes de empezar
4. **🔧 Realizar configuración** paso a paso
5. **✅ Verificar funcionamiento**
6. **📝 Documentar proceso** y resultados
7. **💾 Guardar evidencias** (capturas, configs, logs)
8. **📷 Crear snapshot final** si todo funciona

### Organización de Entregas

#### Estructura de Carpetas
```
ejercicios/tema2-X-nombre/
├── README.md                    # Resumen del ejercicio
├── configuraciones/            # Archivos de config
│   ├── antes/                  # Estados iniciales
│   └── despues/               # Estados finales
├── scripts/                    # Scripts desarrollados
├── capturas/                   # Screenshots de evidencia
├── logs/                       # Archivos de log relevantes
└── informe.md                  # Análisis y conclusiones
```

#### Template de Informe
```markdown
# Ejercicio X.Y: [Nombre del Ejercicio]

## Objetivo
[Descripción del objetivo del ejercicio]

## Entorno
- VM utilizada: [nombre]
- Software adicional: [lista]
- Configuración previa: [requisitos]

## Desarrollo
### Paso 1: [Descripción]
````bash
[comandos ejecutados]
````
[resultado obtenido]

### Paso 2: [Descripción]
[proceso seguido]

## Evidencias
- Captura 1: [descripción]
- Log 1: [ubicación y contenido relevante]

## Problemas Encontrados
[Dificultades y cómo se resolvieron]

## Conclusiones
[Aprendizajes obtenidos]

## Referencias
[Enlaces y fuentes consultadas]
```

## 🔧 Herramientas Esenciales

### En el Host (tu ordenador)
```bash
# Editores de texto
- VS Code (recomendado)
- Sublime Text
- Vim/Nano para edición rápida

# Clientes de red
- PuTTY (Windows) o Terminal (Linux/macOS)
- WinSCP o FileZilla para transferencia de archivos
- Cliente RDP (mstsc en Windows)

# Navegadores
- Firefox o Chrome actualizados
- Con extensiones de desarrollo (F12 tools)
```

### En las VMs Linux
```bash
# Herramientas básicas (ya instaladas)
sudo apt update && sudo apt install -y \
  curl wget git vim nano htop iotop \
  net-tools tcpdump wireshark-common

# Herramientas de seguridad (en Kali)
nmap, metasploit-framework, john, hashcat,
burpsuite, nikto, dirb, gobuster
```

### En las VMs Windows
```powershell
# Herramientas administrativas
- Sysinternals Suite
- Process Monitor
- TCPView
- Wireshark
- PowerShell ISE
```

## 📊 Seguimiento del Progreso

### Checklist de Progreso Personal

#### Básico ✅
- [ ] Laboratorio instalado y funcionando
- [ ] Conectividad entre VMs verificada
- [ ] Snapshots iniciales creados
- [ ] Primer ejercicio completado y documentado

#### Intermedio ✅
- [ ] 50% de ejercicios básicos completados
- [ ] Configuración de servicios de red funcional
- [ ] Herramientas de seguridad configuradas
- [ ] Análisis básico de logs realizado

#### Avanzado ✅
- [ ] 80% de ejercicios completados
- [ ] Scripts personalizados desarrollados
- [ ] Análisis forense básico realizado
- [ ] Plan de backup implementado y probado

#### Experto ✅
- [ ] Todos los ejercicios completados
- [ ] Ejercicios avanzados personalizados
- [ ] Contribuciones al laboratorio
- [ ] Mentoría a otros estudiantes

## 🆘 Cuando Necesites Ayuda

### 1. Autodiagnóstico
```bash
# Verificar estado de VMs
VBoxManage list runningvms

# Verificar conectividad
ping -c 4 192.168.100.30

# Verificar servicios
systemctl status ssh  # En Linux
Get-Service  # En PowerShell
```

### 2. Recursos de Consulta
- **Documentación oficial** de cada herramienta
- **Stack Overflow** para errores específicos
- **GitHub Issues** del repositorio del laboratorio
- **Troubleshooting.md** para problemas comunes

### 3. Solicitar Ayuda
Cuando reportes un problema, incluye:
```
- Descripción del problema
- Pasos para reproducirlo
- Mensajes de error exactos
- Capturas de pantalla
- Configuración de la VM afectada
- Logs relevantes
```

## 🏆 Buenas Prácticas

### Seguridad
- 🔐 **Cambiar contraseñas por defecto** en primer uso
- 📷 **Crear snapshots** antes de cambios importantes
- 🔒 **No usar laboratorio en red de producción**
- 🧹 **Limpiar evidencias** después de ejercicios

### Organización
- 📝 **Documentar todo** lo que hagas
- 🏷️ **Nombrar archivos** de forma descriptiva
- 📁 **Organizar por temas** y ejercicios
- ⏰ **Usar control de versiones** (git) para tus ejercicios

### Aprendizaje
- 🤔 **Entender antes de copiar** comandos
- 🔄 **Repetir ejercicios** hasta dominarlos
- 💡 **Experimentar** con variaciones
- 🤝 **Colaborar** con compañeros

## 🎖️ Certificación de Competencias

Al completar el laboratorio, habrás adquirido habilidades en:

### Técnicas ✅
- Virtualización con VirtualBox
- Administración de sistemas Linux/Windows
- Herramientas de seguridad (nmap, Wireshark, Metasploit)
- Criptografía aplicada
- Análisis forense básico
- Backup y recuperación

### Metodológicas ✅
- Documentación técnica
- Resolución de problemas
- Análisis de riesgos
- Planificación de contingencias
- Trabajo en equipo

### Profesionales ✅
- Infraestructura como código (Vagrant)
- Buenas prácticas de seguridad
- Cumplimiento normativo
- Comunicación técnica

---

## 🚀 ¡Comienza Tu Aventura!

Estás listo para comenzar. Recuerda:
- **Paciencia**: La seguridad se aprende paso a paso
- **Práctica**: No hay sustituto para la experiencia hands-on
- **Curiosidad**: Siempre pregunta "¿qué pasa si...?"
- **Persistencia**: Los errores son oportunidades de aprendizaje

**¡Éxito en tu aprendizaje!** 🎓

---
**📞 Soporte**: Si necesitas ayuda, consulta [troubleshooting.md](troubleshooting.md) o contacta al instructor.
