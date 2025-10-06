#!/bin/bash

# Script maestro para desplegar el laboratorio SAD
# Autor: Laboratorio SAD
# Fecha: $(date +%Y-%m-%d)

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar dependencias
check_dependencies() {
    log_info "Verificando dependencias..."
    
    # Verificar VirtualBox
    if ! command -v VBoxManage &> /dev/null; then
        log_error "VirtualBox no está instalado"
        exit 1
    fi
    
    # Verificar Vagrant
    if ! command -v vagrant &> /dev/null; then
        log_error "Vagrant no está instalado"
        exit 1
    fi
    
    # Verificar versión mínima de Vagrant
    VAGRANT_VERSION=$(vagrant --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
    REQUIRED_VERSION="2.2.0"
    
    # Función simple para comparar versiones
    version_compare() {
        local version1="$1"
        local version2="$2"
        
        # Convertir versiones a números comparables
        local v1=$(echo "$version1" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}')
        local v2=$(echo "$version2" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}')
        
        [[ $v1 -ge $v2 ]]
    }
    
    if version_compare "$VAGRANT_VERSION" "$REQUIRED_VERSION"; then
        log_success "Vagrant $VAGRANT_VERSION está instalado (requerido: $REQUIRED_VERSION+)"
    else
        log_error "Vagrant versión $REQUIRED_VERSION o superior requerida, encontrada: $VAGRANT_VERSION"
        exit 1
    fi
    
    log_success "Todas las dependencias están instaladas"
}

# Función para verificar scripts de aprovisionamiento
check_provision_scripts() {
    log_info "Verificando scripts de aprovisionamiento..."
    
    local missing_scripts=()
    
    # Scripts comunes
    local common_scripts=(
        "provision/common/update-system.sh"
    )
    
    # Scripts Ubuntu Server
    local ubuntu_scripts=(
        "provision/ubuntu-server/install-services.sh"
        "provision/ubuntu-server/configure-ssh.sh"
        "provision/ubuntu-server/setup-firewall.sh"
    )
    
    # Scripts Kali Security
    local kali_scripts=(
        "provision/kali-security/configure-metasploit.sh"
        "provision/kali-security/setup-wireshark.sh"
        "provision/kali-security/update-tools.sh"
        "provision/kali-security/setup-environment.sh"
    )
    
    # Scripts Storage Backup
    local storage_scripts=(
        "provision/storage-backup/install-backup-tools.sh"
        "provision/storage-backup/configure-samba.sh"
        "provision/storage-backup/setup-bacula.sh"
    )
    
    # Scripts Windows Server
    local windows_server_scripts=(
        "provision/windows-server/basic-config.ps1"
        "provision/windows-server/install-services.ps1"
    )
    
    # Scripts Windows Client
    local windows_client_scripts=(
        "provision/windows-client/basic-config.ps1"
    )
    
    # Combinar todos los scripts
    local all_scripts=("${common_scripts[@]}" "${ubuntu_scripts[@]}" "${kali_scripts[@]}" "${storage_scripts[@]}" "${windows_server_scripts[@]}" "${windows_client_scripts[@]}")
    
    for script in "${all_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            missing_scripts+=("$script")
        elif [[ ! -x "$script" && "$script" == *.sh ]]; then
            log_warning "Script $script no es ejecutable, corrigiendo..."
            chmod +x "$script"
        fi
    done
    
    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        log_error "Scripts faltantes:"
        for script in "${missing_scripts[@]}"; do
            echo "  - $script"
        done
        return 1
    fi
    
    log_success "Todos los scripts de aprovisionamiento están presentes"
    return 0
}

# Función para verificar configuraciones
check_configs() {
    log_info "Verificando archivos de configuración..."
    
    local config_files=(
        "configs/network-config.md"
        "configs/samba.conf"
        "configs/apache.conf"
        "configs/mysql.conf"
        "configs/bacula.conf"
        "configs/docker.conf"
    )
    
    for config in "${config_files[@]}"; do
        if [[ ! -f "$config" ]]; then
            log_warning "Archivo de configuración faltante: $config"
        fi
    done
    
    log_success "Verificación de configuraciones completada"
}

# Función para mostrar estado de las VMs
show_vm_status() {
    log_info "Estado actual de las VMs:"
    echo ""
    
    local vms=("ubuntu-server" "windows-server" "windows-client" "storage-backup" "kali-security")
    
    for vm in "${vms[@]}"; do
        local status=$(vagrant status "$vm" 2>/dev/null | grep "$vm" | awk '{print $2}')
        if [[ -z "$status" ]]; then
            status="unknown"
        fi
        
        case $status in
            "running")
                echo -e "  📗 $vm: ${GREEN}$status${NC}"
                ;;
            "poweroff"|"not_created")
                echo -e "  📕 $vm: ${RED}$status${NC}"
                ;;
            "saved"|"suspended")
                echo -e "  📙 $vm: ${YELLOW}$status${NC}"
                ;;
            *)
                echo -e "  📘 $vm: ${BLUE}$status${NC}"
                ;;
        esac
    done
    echo ""
}

# Función para limpiar VMs con errores
cleanup_failed_vms() {
    log_info "Limpiando VMs con errores..."
    
    local vms=("ubuntu-server" "windows-server" "windows-client" "storage-backup" "kali-security")
    
    for vm in "${vms[@]}"; do
        local status=$(vagrant status "$vm" 2>/dev/null | grep "$vm" | awk '{print $2}')
        if [[ "$status" == "running" ]]; then
            log_info "Verificando estado de $vm..."
            if ! vagrant ssh "$vm" -c "echo 'VM accessible'" &>/dev/null; then
                log_warning "VM $vm no responde, destruyendo..."
                vagrant destroy "$vm" -f
            fi
        fi
    done
    
    log_success "Limpieza completada"
}

# Función para limpiar archivos VDI residuales
clean_vdi_files() {
    log_info "Limpiando archivos VDI residuales..."
    
    # Limpiar archivos VDI que pueden causar conflictos
    local vdi_files=("ubuntu-server-disk.vdi" "storage-disk.vdi")
    
    for vdi_file in "${vdi_files[@]}"; do
        if [[ -f "$vdi_file" ]]; then
            log_warning "Eliminando archivo VDI existente: $vdi_file"
            rm -f "$vdi_file"
        fi
    done
    
    log_success "Limpieza de archivos VDI completada"
}

# Función para desplegar una VM específica
deploy_vm() {
    local vm_name="$1"
    local attempt=1
    local max_attempts=2
    
    log_info "Desplegando VM: $vm_name"
    
    while [[ $attempt -le $max_attempts ]]; do
        log_info "Intento $attempt de $max_attempts para $vm_name"
        
        if vagrant up "$vm_name"; then
            log_success "VM $vm_name desplegada correctamente"
            return 0
        else
            log_error "Falló el despliegue de $vm_name en intento $attempt"
            
            if [[ $attempt -lt $max_attempts ]]; then
                log_info "Limpiando y reintentando..."
                vagrant destroy "$vm_name" -f 2>/dev/null || true
                sleep 5
            fi
            
            ((attempt++))
        fi
    done
    
    log_error "No se pudo desplegar $vm_name después de $max_attempts intentos"
    return 1
}

# Función para desplegar todas las VMs
deploy_all_vms() {
    log_info "Iniciando despliegue completo del laboratorio..."
    
    # Limpiar archivos VDI residuales antes del despliegue
    clean_vdi_files
    
    local vms=("ubuntu-server" "storage-backup" "kali-security" "windows-server" "windows-client")
    local failed_vms=()
    
    for vm in "${vms[@]}"; do
        if ! deploy_vm "$vm"; then
            failed_vms+=("$vm")
        fi
        echo ""
    done
    
    if [[ ${#failed_vms[@]} -eq 0 ]]; then
        log_success "¡Todas las VMs se desplegaron correctamente!"
        show_vm_status
    else
        log_error "VMs que fallaron: ${failed_vms[*]}"
        return 1
    fi
}

# Función para exportar OVAs
export_ovas() {
    log_info "Exportando VMs a formato OVA..."
    
    local export_dir="ovas"
    mkdir -p "$export_dir"
    
    local vms=("ubuntu-server" "windows-server" "windows-client" "storage-backup" "kali-security")
    
    for vm in "${vms[@]}"; do
        local status=$(vagrant status "$vm" 2>/dev/null | grep "$vm" | awk '{print $2}')
        
        if [[ "$status" == "running" ]]; then
            log_info "Deteniendo $vm para exportación..."
            vagrant halt "$vm"
        fi
        
        if [[ "$status" != "not_created" ]]; then
            log_info "Exportando $vm a OVA..."
            # Convertir nombre de VM al formato usado en VirtualBox (SAD-Ubuntu-Server, etc.)
            local vbox_name="SAD-$(echo $vm | sed 's/-/ /g' | sed 's/\b\w/\U&/g' | sed 's/ /-/g')"
            local vm_uuid=$(VBoxManage list vms | grep "$vbox_name" | grep -o '{[^}]*}' | tr -d '{}')
            
            if [[ -n "$vm_uuid" ]]; then
                VBoxManage export "$vm_uuid" --output "$export_dir/sadlab-$vm.ova" --manifest
                log_success "Exportado: $export_dir/sadlab-$vm.ova"
            else
                log_error "No se encontró UUID para $vm (buscando como $vbox_name)"
            fi
        else
            log_warning "VM $vm no existe, saltando exportación"
        fi
    done
    
    log_success "Exportación completada. OVAs guardadas en: $export_dir/"
    
    # Generar checksums automáticamente
    log_info "Generando checksums SHA256..."
    if cd "$export_dir" && ls *.ova >/dev/null 2>&1; then
        sha256sum *.ova > checksums.sha256
        log_success "Checksums generados en: $export_dir/checksums.sha256"
        
        echo ""
        log_info "📋 Checksums SHA256:"
        cat checksums.sha256
        echo ""
        log_info "💡 Para verificar: sha256sum -c $export_dir/checksums.sha256"
    else
        log_warning "No se encontraron archivos OVA para generar checksums"
    fi
    cd - >/dev/null
}

# Función para probar conectividad del laboratorio
test_connectivity() {
    log_info "Probando conectividad del laboratorio..."
    
    local vms=("ubuntu-server" "storage-backup" "kali-security" "windows-server" "windows-client")
    local failed_tests=()
    
    # Verificar que las VMs estén ejecutándose
    for vm in "${vms[@]}"; do
        local status=$(vagrant status "$vm" 2>/dev/null | grep "$vm" | awk '{print $2}')
        if [[ "$status" != "running" ]]; then
            log_error "VM $vm no está ejecutándose (estado: $status)"
            failed_tests+=("$vm-not-running")
        else
            log_success "VM $vm está ejecutándose"
        fi
    done
    
    # Probar SSH en VMs Linux
    log_info "Probando conectividad SSH..."
    for vm in "ubuntu-server" "storage-backup" "kali-security"; do
        if vagrant ssh-config "$vm" >/dev/null 2>&1; then
            if timeout 10 vagrant ssh "$vm" -c "echo 'SSH OK en $vm'" 2>/dev/null; then
                log_success "SSH funcionando en $vm"
            else
                log_error "SSH falló en $vm"
                failed_tests+=("$vm-ssh")
            fi
        else
            log_warning "SSH config no disponible para $vm"
            failed_tests+=("$vm-ssh-config")
        fi
    done
    
    # Probar WinRM en VMs Windows
    log_info "Probando conectividad WinRM..."
    for vm in "windows-server" "windows-client"; do
        if timeout 10 vagrant winrm "$vm" -c "echo 'WinRM OK en $vm'" 2>/dev/null; then
            log_success "WinRM funcionando en $vm"
        else
            log_warning "WinRM falló en $vm (puede ser temporal después de cambios de red)"
            log_info "→ Alternativas: RDP disponible en localhost:3389 (windows-server) / 3390 (windows-client)"
            log_info "→ Para reparar: vagrant winrm $vm -c 'Restart-Service WinRM; Enable-PSRemoting -Force'"
            # No agregamos a failed_tests si el VM está corriendo
            if ! vagrant status "$vm" 2>/dev/null | grep -q "running"; then
                failed_tests+=("$vm-winrm")
            fi
        fi
    done
    
    # Probar conectividad de red interna
    log_info "Probando conectividad de red interna..."
    
    # Matriz de pruebas de conectividad críticas
    local network_tests=(
        "ubuntu-server:192.168.56.20:kali-security"
        "ubuntu-server:192.168.56.11:windows-server" 
        "ubuntu-server:192.168.56.13:storage-backup"
        "kali-security:192.168.56.10:ubuntu-server"
        "kali-security:192.168.56.11:windows-server"
        "storage-backup:192.168.56.10:ubuntu-server"
    )
    
    for test in "${network_tests[@]}"; do
        IFS=':' read -r source_vm target_ip target_name <<< "$test"
        if timeout 10 vagrant ssh "$source_vm" -c "ping -c 2 $target_ip >/dev/null 2>&1" 2>/dev/null; then
            log_success "Conectividad de red: $source_vm → $target_name ($target_ip)"
        else
            log_error "Falló conectividad de red: $source_vm → $target_name ($target_ip)"
            failed_tests+=("network-$source_vm-to-$target_name")
        fi
    done
    
    # Probar servicios específicos del laboratorio
    log_info "Probando servicios específicos del laboratorio..."
    
    # Probar HTTP en Ubuntu Server
    if timeout 10 vagrant ssh ubuntu-server -c "curl -s -o /dev/null -w '%{http_code}' http://localhost | grep -q '200\|302\|403'" 2>/dev/null; then
        log_success "Servicio HTTP funcionando en ubuntu-server"
    else
        log_warning "Servicio HTTP no responde en ubuntu-server (normal si no está configurado aún)"
    fi
    
    # Probar SSH entre VMs (resolución de nombres)
    if timeout 10 vagrant ssh kali-security -c "ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu-server echo 'SSH entre VMs OK' 2>/dev/null" 2>/dev/null; then
        log_success "SSH entre VMs funcionando (kali → ubuntu)"
    else
        log_warning "SSH entre VMs falló (normal si no hay intercambio de claves)"
    fi
    
    # Probar resolución de nombres (hosts file)
    if timeout 10 vagrant ssh ubuntu-server -c "getent hosts kali-security | grep -q 192.168.56.20" 2>/dev/null; then
        log_success "Resolución de nombres funcionando (ubuntu-server puede resolver kali-security)"
    else
        log_error "Falló resolución de nombres en ubuntu-server"
        failed_tests+=("dns-resolution")
    fi
    
    # Resumen de resultados
    echo ""
    if [[ ${#failed_tests[@]} -eq 0 ]]; then
        log_success "✅ Todas las pruebas de conectividad pasaron"
        log_info "El laboratorio está completamente funcional"
    else
        log_error "❌ Algunas pruebas fallaron: ${failed_tests[*]}"
        log_warning "Revisa la configuración de las VMs que fallaron"
    fi
}

# Función para habilitar ICMP en VMs Windows existentes
fix_windows_connectivity() {
    log_info "Habilitando ICMP (ping) en VMs Windows..."
    
    local windows_vms=("windows-server" "windows-client")
    local failed_fixes=()
    
    for vm in "${windows_vms[@]}"; do
        local status=$(vagrant status "$vm" 2>/dev/null | grep "$vm" | awk '{print $2}')
        
        if [[ "$status" == "running" ]]; then
            log_info "Configurando firewall ICMP en $vm..."
            
            if vagrant winrm "$vm" -c "netsh advfirewall firewall add rule name='Allow ICMPv4-In' protocol=icmpv4:8,any dir=in action=allow" 2>/dev/null; then
                if vagrant winrm "$vm" -c "netsh advfirewall firewall add rule name='Allow ICMPv4-Out' protocol=icmpv4:8,any dir=out action=allow" 2>/dev/null; then
                    log_success "ICMP habilitado en $vm"
                else
                    log_error "Error habilitando ICMP-Out en $vm"
                    failed_fixes+=("$vm-out")
                fi
            else
                log_error "Error habilitando ICMP-In en $vm"
                failed_fixes+=("$vm-in")
            fi
        else
            log_warning "VM $vm no está ejecutándose (estado: $status)"
            failed_fixes+=("$vm-not-running")
        fi
    done
    
    echo ""
    if [[ ${#failed_fixes[@]} -eq 0 ]]; then
        log_success "✅ ICMP habilitado en todas las VMs Windows"
        log_info "Ejecuta './deploy-lab.sh test' para verificar la conectividad"
    else
        log_error "❌ Error configurando ICMP en: ${failed_fixes[*]}"
    fi
}

# Función para crear snapshots de todas las VMs
create_snapshots() {
    local snapshot_name="${1:-Estado-$(date +%Y%m%d-%H%M%S)}"
    
    log_info "Creando snapshots con nombre: $snapshot_name"
    
    local vms=("ubuntu-server" "storage-backup" "kali-security" "windows-server" "windows-client")
    local failed_snapshots=()
    
    for vm in "${vms[@]}"; do
        local status=$(vagrant status "$vm" 2>/dev/null | grep "$vm" | awk '{print $2}')
        
        if [[ "$status" == "running" || "$status" == "poweroff" ]]; then
            log_info "Creando snapshot de $vm..."
            
            # Obtener UUID de la VM
            local vm_uuid=$(VBoxManage list vms | grep "SAD-$(echo $vm | sed 's/-/ /g' | sed 's/\b\w/\U&/g' | sed 's/ /-/g')" | grep -o '{[^}]*}' | tr -d '{}')
            
            if [[ -n "$vm_uuid" ]]; then
                if VBoxManage snapshot "$vm_uuid" take "$snapshot_name" --description "Snapshot automático creado por deploy-lab.sh el $(date)" 2>/dev/null; then
                    log_success "Snapshot creado para $vm"
                else
                    log_error "Error creando snapshot para $vm"
                    failed_snapshots+=("$vm")
                fi
            else
                log_error "No se encontró UUID para $vm"
                failed_snapshots+=("$vm")
            fi
        else
            log_warning "VM $vm no está disponible para snapshot (estado: $status)"
            failed_snapshots+=("$vm")
        fi
    done
    
    echo ""
    if [[ ${#failed_snapshots[@]} -eq 0 ]]; then
        log_success "✅ Snapshots creados exitosamente para todas las VMs"
        log_info "Nombre del snapshot: $snapshot_name"
        log_info "Para restaurar: VBoxManage snapshot <VM> restore '$snapshot_name'"
    else
        log_error "❌ Error creando snapshots para: ${failed_snapshots[*]}"
    fi
}

# Función para mostrar ayuda
show_help() {
    echo "Script maestro para el laboratorio SAD"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  check       - Verificar dependencias y scripts"
    echo "  status      - Mostrar estado de las VMs"
    echo "  deploy      - Desplegar todas las VMs"
    echo "  deploy-vm   - Desplegar una VM específica"
    echo "  test        - Probar conectividad del laboratorio"
    echo "  fix-windows - Habilitar ICMP en VMs Windows existentes"
    echo "  snapshot    - Crear snapshots de todas las VMs"
    echo "  cleanup     - Limpiar VMs con errores"
    echo "  export      - Exportar VMs a formato OVA"
    echo "  destroy     - Destruir todas las VMs"
    echo "  help        - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 check"
    echo "  $0 deploy"
    echo "  $0 deploy-vm ubuntu-server"
    echo "  $0 test"
    echo "  $0 fix-windows"
    echo "  $0 snapshot 'Estado-Inicial-Limpio'"
    echo "  $0 export"
}

# Función principal
main() {
    local command="${1:-help}"
    
    case $command in
        "check")
            check_dependencies
            check_provision_scripts
            check_configs
            ;;
        "status")
            show_vm_status
            ;;
        "deploy")
            check_dependencies
            if check_provision_scripts; then
                deploy_all_vms
            else
                log_error "Corrige los scripts faltantes antes de continuar"
                exit 1
            fi
            ;;
        "deploy-vm")
            if [[ -z "$2" ]]; then
                log_error "Especifica el nombre de la VM"
                echo "VMs disponibles: ubuntu-server, windows-server, windows-client, storage-backup, kali-security"
                exit 1
            fi
            check_dependencies
            if check_provision_scripts; then
                deploy_vm "$2"
            else
                log_error "Corrige los scripts faltantes antes de continuar"
                exit 1
            fi
            ;;
        "test")
            test_connectivity
            ;;
        "fix-windows")
            fix_windows_connectivity
            ;;
        "snapshot")
            if [[ -n "$2" ]]; then
                create_snapshots "$2"
            else
                create_snapshots
            fi
            ;;
        "cleanup")
            cleanup_failed_vms
            ;;
        "export")
            export_ovas
            ;;
        "destroy")
            log_warning "Esto destruirá TODAS las VMs del laboratorio"
            read -p "¿Estás seguro? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                vagrant destroy -f
                log_success "Todas las VMs han sido destruidas"
            else
                log_info "Operación cancelada"
            fi
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Verificar que estamos en el directorio correcto
if [[ ! -f "Vagrantfile" ]]; then
    log_error "No se encontró Vagrantfile. Ejecuta este script desde el directorio del laboratorio."
    exit 1
fi

# Ejecutar función principal
main "$@"