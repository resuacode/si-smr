# Scripts de Utilidad para el Laboratorio

## Scripts de Validación

### Validar Conectividad de Red
```bash
#!/bin/bash
# check_network.sh - Verificar conectividad entre VMs

echo "==================================="
echo "   VALIDACIÓN DE RED DEL LAB"
echo "==================================="

VMS=("192.168.56.10:Ubuntu Server" "192.168.56.11:Windows Server" "192.168.56.12:Windows Client" "192.168.56.13:Storage/Backup" "192.168.56.20:Kali Linux")

for vm in "${VMS[@]}"; do
    ip=$(echo $vm | cut -d: -f1)
    name=$(echo $vm | cut -d: -f2)
    
    echo -n "Verificando $name ($ip)... "
    if ping -c 1 -W 2 $ip > /dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ FALLO"
    fi
done

echo ""
echo "Verificando puertos específicos:"
echo -n "SSH Ubuntu Server (22)... "
nc -z 192.168.56.10 22 && echo "✅ OK" || echo "❌ FALLO"

echo -n "HTTP Ubuntu Server (80)... "
nc -z 192.168.56.10 80 && echo "✅ OK" || echo "❌ FALLO"

echo -n "RDP Windows Server (3389)... "
nc -z 192.168.56.11 3389 && echo "✅ OK" || echo "❌ FALLO"

echo -n "SMB Storage (445)... "
nc -z 192.168.56.13 445 && echo "✅ OK" || echo "❌ FALLO"

echo -n "FTP Storage (21)... "
nc -z 192.168.56.13 21 && echo "✅ OK" || echo "❌ FALLO"
```

### Validar Servicios
```bash
#!/bin/bash
# check_services.sh - Verificar servicios en VMs

echo "======================================"
echo "   VALIDACIÓN DE SERVICIOS DEL LAB"
echo "======================================"

check_web_service() {
    local url=$1
    local name=$2
    
    echo -n "Verificando $name... "
    if curl -s --connect-timeout 5 "$url" > /dev/null; then
        echo "✅ OK"
    else
        echo "❌ FALLO"
    fi
}

check_web_service "http://192.168.56.10" "Servidor Web Ubuntu"
check_web_service "http://192.168.56.11" "Servidor Web Windows"

echo -n "Verificando FTP anónimo... "
if echo "quit" | ftp -n 192.168.56.13 > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FALLO"
fi

echo -n "Verificando SMB shares... "
if smbclient -L //192.168.56.13 -N > /dev/null 2>&1; then
    echo "✅ OK"
else
    echo "❌ FALLO"
fi
```

## Scripts de Configuración Rápida

### Configurar Entorno de Estudiante
```bash
#!/bin/bash
# setup_student_env.sh - Configuración inicial para estudiantes

echo "===================================="
echo "   CONFIGURACIÓN DE ESTUDIANTE"
echo "===================================="

# Crear directorios de trabajo
mkdir -p ~/Laboratorio/{ejercicios,herramientas,informes,evidencias}

# Configurar aliases útiles
cat >> ~/.bashrc << 'EOF'

# Aliases para laboratorio SAD
alias lab-ping='ping -c 3'
alias lab-scan='nmap -sV -sC'
alias lab-http='curl -I'
alias lab-ftp='ftp'
alias lab-smb='smbclient -L'

# Funciones útiles
lab-target() {
    case $1 in
        "server") echo "192.168.56.10" ;;
        "winserver") echo "192.168.56.11" ;;
        "winclient") echo "192.168.56.12" ;;
        "storage") echo "192.168.56.13" ;;
        "kali") echo "192.168.56.20" ;;
        *) echo "Uso: lab-target [server|winserver|winclient|storage|kali]" ;;
    esac
}

lab-info() {
    echo "=== INFORMACIÓN DEL LABORATORIO ==="
    echo "Ubuntu Server:    192.168.56.10"
    echo "Windows Server:   192.168.56.11"
    echo "Windows Client:   192.168.56.12"
    echo "Storage/Backup:   192.168.56.13"
    echo "Kali Linux:       192.168.56.20"
    echo ""
    echo "Credenciales por defecto:"
    echo "- vagrant/vagrant (Linux)"
    echo "- admin/admin123 (servicios)"
    echo "- Ver documentación para más detalles"
}
EOF

# Instalar herramientas básicas si no están presentes
if command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y nmap curl ftp smbclient netcat-openbsd
elif command -v yum &> /dev/null; then
    sudo yum install -y nmap curl ftp samba-client nmap-ncat
fi

# Crear plantilla de informe
cat > ~/Laboratorio/informes/plantilla_ejercicio.md << 'EOF'
# Informe de Ejercicio - [TÍTULO]

**Estudiante:** [Nombre]
**Fecha:** [Fecha]
**Ejercicio:** [Número y título del ejercicio]

## Objetivo
[Descripción del objetivo del ejercicio]

## Metodología
[Pasos seguidos y herramientas utilizadas]

## Resultados
[Resultados obtenidos, capturas de pantalla, logs relevantes]

## Evidencias
[Enlaces a archivos de evidencia, logs, capturas]

## Conclusiones
[Análisis de los resultados y lecciones aprendidas]

## Recomendaciones
[Medidas de seguridad o mejoras identificadas]
EOF

echo "✅ Entorno de estudiante configurado"
echo "💡 Ejecuta 'source ~/.bashrc' para cargar los nuevos aliases"
echo "📁 Directorios creados en ~/Laboratorio/"
echo "📋 Plantilla de informe disponible en ~/Laboratorio/informes/"
```

### Script de Reset del Laboratorio
```bash
#!/bin/bash
# reset_lab.sh - Reiniciar laboratorio a estado inicial

echo "====================================="
echo "     RESET DEL LABORATORIO"
echo "====================================="

echo "⚠️  ADVERTENCIA: Esto reiniciará todas las VMs del laboratorio"
echo "Todos los cambios no guardados se perderán."
echo ""
read -p "¿Continuar? (s/N): " confirm

if [[ $confirm != [sS] ]]; then
    echo "Operación cancelada."
    exit 1
fi

# Verificar si Vagrant está disponible
if ! command -v vagrant &> /dev/null; then
    echo "❌ Vagrant no encontrado. Usando VirtualBox directamente..."
    
    # Lista de VMs del laboratorio
    VMS=("ubuntu-server-lab" "windows-server-lab" "windows-client-lab" "storage-backup-lab" "kali-security-lab")
    
    for vm in "${VMS[@]}"; do
        echo "Deteniendo $vm..."
        VBoxManage controlvm "$vm" poweroff 2>/dev/null
        echo "Restaurando snapshot inicial de $vm..."
        VBoxManage snapshot "$vm" restore "Estado-Inicial" 2>/dev/null
    done
else
    echo "🔄 Reiniciando VMs con Vagrant..."
    vagrant halt
    vagrant up --provision
fi

echo ""
echo "✅ Laboratorio reiniciado"
echo "💡 Todas las VMs han vuelto a su estado inicial"
echo "📋 Verifica la conectividad con: ./check_network.sh"
```

### Script de Backup del Trabajo
```bash
#!/bin/bash
# backup_work.sh - Crear backup del trabajo del estudiante

echo "=================================="
echo "   BACKUP DEL TRABAJO"
echo "=================================="

DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="backup_laboratorio_$DATE"

# Crear directorio de backup
mkdir -p "$BACKUP_DIR"

echo "📁 Creando backup en $BACKUP_DIR..."

# Backup de informes y evidencias
if [ -d ~/Laboratorio ]; then
    cp -r ~/Laboratorio "$BACKUP_DIR/"
    echo "✅ Copiados archivos de ~/Laboratorio"
fi

# Backup de configuraciones personalizadas
cp ~/.bashrc "$BACKUP_DIR/bashrc_backup" 2>/dev/null
cp ~/.vimrc "$BACKUP_DIR/vimrc_backup" 2>/dev/null

# Crear resumen del sistema
cat > "$BACKUP_DIR/system_info.txt" << EOF
Información del sistema - $DATE
================================

Usuario: $(whoami)
Sistema: $(uname -a)
Fecha: $(date)

Versiones instaladas:
$(nmap --version 2>/dev/null | head -1)
$(curl --version 2>/dev/null | head -1)

Aliases configurados:
$(alias | grep lab-)
EOF

# Comprimir backup
tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR"
rm -rf "$BACKUP_DIR"

echo "✅ Backup creado: ${BACKUP_DIR}.tar.gz"
echo "💾 Tamaño: $(du -h ${BACKUP_DIR}.tar.gz | cut -f1)"

# Opción de subida (ejemplo)
echo ""
echo "Para subir el backup:"
echo "scp ${BACKUP_DIR}.tar.gz usuario@servidor:/path/to/backups/"
```

## Scripts de Monitoreo

### Monitor de Recursos
```bash
#!/bin/bash
# monitor_resources.sh - Monitorear recursos del laboratorio

echo "======================================"
echo "   MONITOR DE RECURSOS DEL LAB"
echo "======================================"

echo "💻 Recursos del Host:"
echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "RAM Total: $(free -h | grep Mem | awk '{print $2}')"
echo "RAM Disponible: $(free -h | grep Mem | awk '{print $7}')"
echo "Disco /: $(df -h / | tail -1 | awk '{print $4}' | xargs) disponible"

echo ""
echo "🖥️  VMs en VirtualBox:"
VBoxManage list runningvms | while read vm; do
    vm_name=$(echo "$vm" | cut -d'"' -f2)
    echo "  ▶️  $vm_name"
done

echo ""
echo "📊 Carga del sistema:"
uptime

echo ""
echo "🌐 Conexiones de red activas:"
netstat -tuln | grep LISTEN | grep -E ":(22|80|21|445|3389|139)" | head -10

echo ""
echo "💾 Espacio usado por VirtualBox:"
if [ -d ~/VirtualBox\ VMs ]; then
    du -sh ~/VirtualBox\ VMs
fi
```

Estos scripts proporcionan herramientas útiles para la gestión y validación del laboratorio. Los estudiantes pueden usar estos scripts para verificar que todo funciona correctamente y para mantener su entorno de trabajo organizado.
