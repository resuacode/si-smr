#!/bin/bash
# setup-wireshark.sh - Configuración de Wireshark para laboratorio SAD

echo "============================="
echo "Configurando Wireshark"
echo "============================="

# Instalar Wireshark y dependencias
echo "Instalando Wireshark..."
sudo apt update
sudo apt install -y wireshark wireshark-common tshark

# Configurar permisos para captura sin sudo
echo "Configurando permisos de captura..."

# Añadir usuario kali al grupo wireshark
sudo usermod -a -G wireshark kali

# Configurar dumpcap para usar sin sudo
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap

# Verificar configuración
sudo getcap /usr/bin/dumpcap

# Crear directorio para capturas del laboratorio
mkdir -p ~/lab-captures
chmod 755 ~/lab-captures

# Crear perfil personalizado para laboratorio SAD
WIRESHARK_CONFIG_DIR="$HOME/.config/wireshark"
mkdir -p "$WIRESHARK_CONFIG_DIR/profiles/SAD-Lab"

# Configuración del perfil SAD-Lab
cat > "$WIRESHARK_CONFIG_DIR/profiles/SAD-Lab/preferences" <<'EOF'
# Configuración personalizada para laboratorio SAD

# Configuración de columnas
gui.column.format: 
	"No.", "%m", 
	"Time", "%t", 
	"Source", "%s", 
	"Destination", "%d", 
	"Protocol", "%p", 
	"Length", "%L", 
	"Info", "%i"

# Configuración de captura
capture.auto_scroll: TRUE
capture.show_info: TRUE

# Configuración de red del laboratorio
name_resolve_all_hosts: TRUE
name_resolve_transport: TRUE
name_resolve_network: TRUE

# Filtros por defecto para red del laboratorio
gui.filter_expressions.label: "Red Lab SAD"
gui.filter_expressions.expr: "ip.addr == 192.168.56.0/24"
EOF

# Crear filtros personalizados para el laboratorio
cat > "$WIRESHARK_CONFIG_DIR/profiles/SAD-Lab/dfilters" <<'EOF'
# Filtros personalizados para laboratorio SAD
"Red Lab" ip.addr == 192.168.56.0/24
"Ubuntu Server" ip.addr == 192.168.56.10
"Windows Server" ip.addr == 192.168.56.11
"Windows Client" ip.addr == 192.168.56.12
"Storage" ip.addr == 192.168.56.13
"Kali" ip.addr == 192.168.56.20
"HTTP Traffic" http
"HTTPS Traffic" tls
"SSH Traffic" ssh
"DNS Traffic" dns
"DHCP Traffic" dhcp
"SMB Traffic" smb || smb2
"ICMP Traffic" icmp
"Suspicious Traffic" not (arp or dhcp or dns or ntp or icmp)
EOF

# Crear configuración de colores
cat > "$WIRESHARK_CONFIG_DIR/profiles/SAD-Lab/colorfilters" <<'EOF'
# Reglas de colores para laboratorio SAD
@HTTP@http@[0,65535,0][0,0,0]
@HTTPS/TLS@tls@[0,0,65535][65535,65535,65535]
@SSH@ssh@[65535,32896,32896][0,0,0]
@DNS@dns@[32896,32896,65535][65535,65535,65535]
@SMB@smb || smb2@[65535,65535,0][0,0,0]
@Error@tcp.analysis.flags@[65535,0,0][65535,65535,65535]
@Warning@tcp.analysis.window_update@[65535,32896,0][0,0,0]
EOF

# Crear scripts útiles para capturas
mkdir -p ~/wireshark-scripts

# Script para captura automática de red del laboratorio
cat > ~/wireshark-scripts/capture-lab.sh <<'EOF'
#!/bin/bash
# Script para capturar tráfico del laboratorio SAD

CAPTURE_DIR="$HOME/lab-captures"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
INTERFACE="eth1"  # Interfaz de red del laboratorio

echo "Iniciando captura de laboratorio SAD..."
echo "Directorio: $CAPTURE_DIR"
echo "Interfaz: $INTERFACE"

# Crear captura con rotación automática cada 100MB
tshark -i "$INTERFACE" \
       -b filesize:100000 \
       -b files:10 \
       -w "$CAPTURE_DIR/lab_capture_$TIMESTAMP.pcapng" \
       -f "net 192.168.56.0/24"
EOF

chmod +x ~/wireshark-scripts/capture-lab.sh

# Script para análisis básico
cat > ~/wireshark-scripts/analyze-capture.sh <<'EOF'
#!/bin/bash
# Script para análisis básico de capturas

if [ $# -eq 0 ]; then
    echo "Uso: $0 <archivo.pcapng>"
    exit 1
fi

CAPTURE_FILE="$1"

echo "=== Análisis de Captura: $CAPTURE_FILE ==="
echo

echo "=== Estadísticas Generales ==="
tshark -r "$CAPTURE_FILE" -z io,stat,1 -q | head -20

echo
echo "=== Top 10 Protocolos ==="
tshark -r "$CAPTURE_FILE" -z ptype,tree -q | head -15

echo
echo "=== Top 10 Conversaciones ==="
tshark -r "$CAPTURE_FILE" -z conv,ip -q | head -15

echo
echo "=== Hosts más activos ==="
tshark -r "$CAPTURE_FILE" -z endpoints,ip -q | head -15

echo
echo "=== Análisis HTTP ==="
tshark -r "$CAPTURE_FILE" -Y "http" -T fields -e http.host -e http.request.uri | sort | uniq -c | sort -nr | head -10

echo
echo "=== Análisis DNS ==="
tshark -r "$CAPTURE_FILE" -Y "dns.flags.response == 0" -T fields -e dns.qry.name | sort | uniq -c | sort -nr | head -10
EOF

chmod +x ~/wireshark-scripts/analyze-capture.sh

# Configurar arranque de interfaz en modo promiscuo (para capturas)
cat > ~/wireshark-scripts/setup-promiscuous.sh <<'EOF'
#!/bin/bash
# Configurar interfaz en modo promiscuo para capturas

INTERFACE="eth1"

echo "Configurando interfaz $INTERFACE en modo promiscuo..."
sudo ip link set dev "$INTERFACE" promisc on

echo "Estado de las interfaces:"
ip link show
EOF

chmod +x ~/wireshark-scripts/setup-promiscuous.sh

# Crear documentación rápida
cat > ~/wireshark-scripts/README.md <<'EOF'
# Wireshark para Laboratorio SAD

## Scripts Disponibles

### capture-lab.sh
Inicia captura automática del tráfico del laboratorio con rotación de archivos.

### analyze-capture.sh
Realiza análisis básico de un archivo de captura.

### setup-promiscuous.sh
Configura la interfaz de red en modo promiscuo para capturas.

## Uso Rápido

```bash
# Iniciar captura del laboratorio
~/wireshark-scripts/capture-lab.sh

# Analizar una captura
~/wireshark-scripts/analyze-capture.sh ~/lab-captures/archivo.pcapng

# Configurar interfaz para capturas
~/wireshark-scripts/setup-promiscuous.sh
```

## Filtros Útiles

- `ip.addr == 192.168.56.0/24` - Todo el tráfico del laboratorio
- `http and ip.addr == 192.168.56.10` - HTTP del servidor Ubuntu
- `smb and ip.addr == 192.168.56.11` - SMB del Windows Server
- `ssh and ip.addr == 192.168.56.20` - SSH hacia/desde Kali

## Perfil SAD-Lab

Wireshark incluye el perfil "SAD-Lab" con:
- Filtros predefinidos para el laboratorio
- Configuración de colores por protocolo
- Columnas optimizadas para análisis
EOF

echo "✓ Wireshark instalado y configurado"
echo "✓ Permisos de captura configurados"
echo "✓ Perfil 'SAD-Lab' creado"
echo "✓ Scripts de captura y análisis instalados"
echo ""
echo "Reiniciar sesión para aplicar permisos de grupo"
echo "Scripts disponibles en: ~/wireshark-scripts/"