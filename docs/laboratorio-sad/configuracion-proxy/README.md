# Configuración de Proxy del Centro Educativo

## 📋 Información General

Esta sección está específicamente diseñada para cuando el laboratorio SAD se utilice **dentro de la red del centro educativo** que requiere configuración de proxy para acceso a Internet.

> ⚠️ **Importante**: Esta configuración solo es necesaria cuando las máquinas virtuales se ejecutan en la red del centro. Para uso doméstico, omitir esta sección.

## 🏢 Configuración del Centro

### Datos del Proxy (Ejemplo - Ajustar según tu centro)

```bash
# Configuración típica de centro educativo
PROXY_HOST="proxy.centro.edu"
PROXY_PORT="8080"
PROXY_USER="usuario_centro"
PROXY_PASS="password_centro"

# Algunos centros usan:
# PROXY_HOST="10.0.0.1" o "192.168.1.1"
# PROXY_PORT="3128" o "8080"
```

### Dominios Exentos (No Proxy)

```bash
# Red interna del centro (ajustar según tu configuración)
NO_PROXY="localhost,127.0.0.1,10.*,192.168.*,.centro.edu,.local"
```

## 🔧 Métodos de Configuración

### Opción A: Script Automático (Recomendado)

Ejecutar en cada VM después de la importación:

```bash
# Descargar y ejecutar script de configuración
curl -fsSL https://raw.githubusercontent.com/tu-usuario/sad/master/scripts/proxy-setup.sh | bash

# O si el script está en el laboratorio:
cd /home/usuario/sad-scripts
sudo ./configure-proxy.sh
```

### Opción B: Configuración Manual por VM

#### Ubuntu Server / Debian Storage

```bash
# 1. Configurar proxy del sistema
sudo nano /etc/environment

# Añadir estas líneas:
export http_proxy="http://usuario:password@proxy.centro.edu:8080"
export https_proxy="http://usuario:password@proxy.centro.edu:8080"
export ftp_proxy="http://usuario:password@proxy.centro.edu:8080"
export no_proxy="localhost,127.0.0.1,10.*,192.168.*,.centro.edu,.local"

# 2. Configurar APT
sudo nano /etc/apt/apt.conf.d/95proxies

# Añadir:
Acquire::http::Proxy "http://usuario:password@proxy.centro.edu:8080";
Acquire::https::Proxy "http://usuario:password@proxy.centro.edu:8080";

# 3. Aplicar cambios
source /etc/environment
sudo apt update
```

#### Kali Linux

```bash
# 1. Configurar proxy del sistema
sudo nano /etc/environment

# Añadir configuración de proxy (igual que Ubuntu)

# 2. Configurar herramientas específicas
# Burp Suite
nano ~/.java/.userPrefs/burp/prefs.xml

# Metasploit
echo 'setg Proxies http:proxy.centro.edu:8080' >> ~/.msf4/msfconsole.rc

# 3. Configurar navegadores
# Firefox: Configuración manual en Preferences > Network Settings
```

#### Windows Server / Windows Client

```powershell
# 1. Configurar proxy via registro (PowerShell como Administrador)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d "proxy.centro.edu:8080"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "localhost;127.*;10.*;192.168.*;*.centro.edu;*.local"

# 2. Configurar proxy con autenticación (si es necesario)
# Windows pedirá credenciales automáticamente

# 3. Verificar configuración
netsh winhttp show proxy
```

## 📄 Scripts de Automatización

### Script Principal: configure-proxy.sh

```bash
#!/bin/bash
# configure-proxy.sh - Configuración automática de proxy para laboratorio SAD

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuración del proxy (AJUSTAR SEGÚN TU CENTRO)
PROXY_HOST="proxy.centro.edu"
PROXY_PORT="8080"
PROXY_USER=""  # Dejar vacío si no requiere autenticación
PROXY_PASS=""
NO_PROXY="localhost,127.0.0.1,10.*,192.168.*,.centro.edu,.local"

echo -e "${GREEN}=== Configurador de Proxy para Laboratorio SAD ===${NC}"
echo -e "${YELLOW}Solo usar dentro de la red del centro educativo${NC}"
echo

# Detectar sistema operativo
if [ -f /etc/debian_version ]; then
    OS="debian"
    echo -e "${GREEN}Sistema detectado: Debian/Ubuntu${NC}"
elif [ -f /etc/redhat-release ]; then
    OS="redhat"
    echo -e "${GREEN}Sistema detectado: RedHat/CentOS${NC}"
else
    echo -e "${RED}Sistema no soportado por este script${NC}"
    exit 1
fi

# Función para configurar proxy del sistema
configure_system_proxy() {
    echo -e "${GREEN}Configurando proxy del sistema...${NC}"
    
    if [ -n "$PROXY_USER" ]; then
        PROXY_URL="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST:$PROXY_PORT"
    else
        PROXY_URL="http://$PROXY_HOST:$PROXY_PORT"
    fi
    
    # Backup del archivo original
    sudo cp /etc/environment /etc/environment.backup.$(date +%Y%m%d)
    
    # Configurar variables de entorno
    sudo tee -a /etc/environment > /dev/null <<EOF

# Proxy del centro educativo (configurado automáticamente)
export http_proxy="$PROXY_URL"
export https_proxy="$PROXY_URL"
export ftp_proxy="$PROXY_URL"
export no_proxy="$NO_PROXY"
export HTTP_PROXY="$PROXY_URL"
export HTTPS_PROXY="$PROXY_URL"
export FTP_PROXY="$PROXY_URL"
export NO_PROXY="$NO_PROXY"
EOF
    
    echo -e "${GREEN}✓ Proxy del sistema configurado${NC}"
}

# Función para configurar APT (Debian/Ubuntu)
configure_apt_proxy() {
    if [ "$OS" = "debian" ]; then
        echo -e "${GREEN}Configurando proxy para APT...${NC}"
        
        sudo mkdir -p /etc/apt/apt.conf.d
        sudo tee /etc/apt/apt.conf.d/95proxies > /dev/null <<EOF
Acquire::http::Proxy "$PROXY_URL";
Acquire::https::Proxy "$PROXY_URL";
EOF
        
        echo -e "${GREEN}✓ Proxy APT configurado${NC}"
    fi
}

# Función para configurar herramientas específicas de Kali
configure_kali_tools() {
    if command -v kali-linux-default &> /dev/null || [ -f /etc/kali_version ]; then
        echo -e "${GREEN}Configurando herramientas de Kali...${NC}"
        
        # Configurar curl
        mkdir -p ~/.curlrc
        echo "proxy = $PROXY_HOST:$PROXY_PORT" > ~/.curlrc
        
        # Configurar wget
        mkdir -p ~/.wgetrc
        echo "http_proxy = $PROXY_URL" > ~/.wgetrc
        echo "https_proxy = $PROXY_URL" > ~/.wgetrc
        
        echo -e "${GREEN}✓ Herramientas de Kali configuradas${NC}"
    fi
}

# Función para verificar conectividad
test_connectivity() {
    echo -e "${GREEN}Verificando conectividad...${NC}"
    
    # Aplicar configuración actual
    source /etc/environment
    
    # Test básico
    if curl -s --connect-timeout 10 http://httpbin.org/ip > /dev/null; then
        echo -e "${GREEN}✓ Conectividad a Internet OK${NC}"
    else
        echo -e "${RED}✗ Error de conectividad${NC}"
        echo -e "${YELLOW}Verificar configuración del proxy del centro${NC}"
    fi
}

# Función principal
main() {
    # Verificar si se ejecuta como usuario con privilegios
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}No ejecutar como root. Usar sudo cuando sea necesario.${NC}"
        exit 1
    fi
    
    # Preguntar confirmación
    echo -e "${YELLOW}¿Configurar proxy del centro? (s/N):${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Ss]$ ]]; then
        echo "Cancelado por el usuario"
        exit 0
    fi
    
    # Ejecutar configuraciones
    configure_system_proxy
    configure_apt_proxy
    configure_kali_tools
    
    echo
    echo -e "${GREEN}=== Configuración completada ===${NC}"
    echo -e "${YELLOW}Reiniciar la sesión o ejecutar: source /etc/environment${NC}"
    echo
    
    test_connectivity
}

# Ejecutar función principal
main "$@"
```

## 🔄 Integración en las OVAs

### Para Preconfigurar en las OVAs

Si quieres que las OVAs vengan **ya configuradas** con el proxy:

1. **Durante la creación de la OVA:**
   ```bash
   # Ejecutar antes de exportar la OVA
   sudo ./configure-proxy.sh
   
   # Crear script de activación
   sudo nano /etc/systemd/system/proxy-detector.service
   ```

2. **Servicio de detección automática:**
   ```ini
   [Unit]
   Description=Detectar red del centro y configurar proxy
   After=network-online.target
   Wants=network-online.target
   
   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/proxy-auto-detect.sh
   RemainAfterExit=yes
   
   [Install]
   WantedBy=multi-user.target
   ```

3. **Script de detección:**
   ```bash
   #!/bin/bash
   # proxy-auto-detect.sh
   
   # Detectar si estamos en red del centro
   if ping -c 1 proxy.centro.edu &> /dev/null; then
       echo "Red del centro detectada - Activando proxy"
       source /etc/environment
   else
       echo "Red externa - Proxy no necesario"
   fi
   ```

## 📚 Documentación para Estudiantes

### Archivo: proxy-estudiantes.md

```markdown
# 🏢 Uso del Laboratorio en el Centro Educativo

## ¿Cuándo necesito configurar el proxy?

**SOLO** cuando uses las máquinas virtuales **dentro del centro educativo**.

En casa o redes externas: **NO es necesario**.

## Configuración Rápida

### Método 1: Script Automático
```bash
cd ~/sad-scripts
./configure-proxy.sh
```

### Método 2: Manual (Ubuntu/Debian)
```bash
export http_proxy="http://proxy.centro.edu:8080"
export https_proxy="http://proxy.centro.edu:8080"
source /etc/environment
```

## Verificar si funciona
```bash
curl http://httpbin.org/ip
```

## Problemas Comunes

**Error**: "No se puede conectar a Internet"
**Solución**: Verificar que el proxy esté configurado correctamente

**Error**: "Comando no encontrado"
**Solución**: Aplicar configuración: `source /etc/environment`
```

## 🚀 Implementación en el Laboratorio

### Ubicación de archivos:

```
docs/laboratorio-sad/
├── configuracion-proxy/
│   ├── README.md                    # Esta documentación
│   ├── proxy-estudiantes.md         # Guía simple para estudiantes
│   ├── configure-proxy.sh           # Script principal
│   ├── proxy-auto-detect.sh         # Detección automática
│   └── troubleshooting-proxy.md     # Solución de problemas
```

¿Te parece bien esta estructura? ¿Quieres que cree los archivos y scripts adicionales?
