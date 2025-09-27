# 🔧 Solución de Problemas - Configuración de Proxy

## 🚨 Problemas Más Comunes

### 1. "No se puede conectar a Internet"

#### Síntomas:
- `curl: (7) Failed to connect to...`
- `apt update` falla
- Navegadores no cargan páginas

#### Soluciones:

**A. Verificar configuración actual**
```bash
# Ver variables de proxy
env | grep -i proxy

# Debe mostrar algo como:
# http_proxy=http://proxy.centro.edu:8080
# https_proxy=http://proxy.centro.edu:8080
```

**B. Aplicar configuración**
```bash
source /etc/environment
```

**C. Verificar datos del proxy**
```bash
# Ping al proxy del centro
ping proxy.centro.edu

# Si no responde, preguntar al administrador:
# - IP correcta del proxy
# - Puerto correcto
# - Si requiere autenticación
```

**D. Configuración manual paso a paso**
```bash
# 1. Configurar temporalmente
export http_proxy="http://proxy.centro.edu:8080"
export https_proxy="http://proxy.centro.edu:8080"

# 2. Probar
curl http://httpbin.org/ip

# 3. Si funciona, hacer permanente
sudo nano /etc/environment
```

### 2. "Permission denied" o errores de sudo

#### Síntomas:
- Script no puede escribir en `/etc/environment`
- No puede crear archivos en `/etc/apt/apt.conf.d/`

#### Soluciones:

**A. Verificar que NO eres root**
```bash
# Esto debe mostrar un número > 0
echo $UID

# Si muestra 0, estás como root (MALO)
# Salir y entrar como usuario normal
```

**B. Verificar sudo disponible**
```bash
# Probar sudo
sudo whoami
# Debe mostrar: root
```

**C. Si no tienes sudo, usar su**
```bash
su -
# Introducir contraseña de root
# Ejecutar configuración manual
```

### 3. APT no funciona después de configurar proxy

#### Síntomas:
- `sudo apt update` falla
- Errores como "Could not resolve proxy"

#### Soluciones:

**A. Verificar configuración APT**
```bash
cat /etc/apt/apt.conf.d/95proxies

# Debe contener:
# Acquire::http::Proxy "http://proxy.centro.edu:8080";
# Acquire::https::Proxy "http://proxy.centro.edu:8080";
```

**B. Probar configuración manual**
```bash
# Eliminar configuración automática
sudo rm /etc/apt/apt.conf.d/95proxies

# Crear nueva configuración
sudo nano /etc/apt/apt.conf.d/95proxies

# Añadir (ajustar según tu centro):
Acquire::http::Proxy "http://proxy.centro.edu:8080";
Acquire::https::Proxy "http://proxy.centro.edu:8080";
```

**C. Verificar con curl primero**
```bash
# Si curl funciona, APT debería funcionar
curl -I http://archive.ubuntu.com/ubuntu/dists/jammy/Release
```

### 4. Navegadores no funcionan

#### Síntomas:
- Firefox/Chrome no cargan páginas
- Error "No se puede conectar al servidor proxy"

#### Soluciones:

**A. Firefox - Configuración manual**
1. Ir a: `about:preferences#general`
2. Buscar: "Network Settings"
3. Configurar:
   - Manual proxy configuration
   - HTTP Proxy: `proxy.centro.edu` Port: `8080`
   - Use this proxy server for all protocols: ✓
   - No proxy for: `localhost, 127.0.0.1, 192.168.*`

**B. Chrome/Chromium - Usar proxy del sistema**
```bash
# Lanzar Chrome con proxy específico
google-chrome --proxy-server="proxy.centro.edu:8080"
```

**C. Verificar variables de entorno para aplicaciones gráficas**
```bash
# En archivos de sesión (.bashrc, .profile)
echo 'export http_proxy="http://proxy.centro.edu:8080"' >> ~/.bashrc
echo 'export https_proxy="http://proxy.centro.edu:8080"' >> ~/.bashrc
```

### 5. Herramientas específicas de Kali no funcionan

#### Síntomas:
- `msfconsole` no puede descargar módulos
- Burp Suite no navega
- `nmap` con scripts falla

#### Soluciones:

**A. Metasploit**
```bash
# Configurar proxy en Metasploit
echo 'setg Proxies http:proxy.centro.edu:8080' >> ~/.msf4/msfconsole.rc

# O dentro de msfconsole:
msf6 > setg Proxies http:proxy.centro.edu:8080
```

**B. Burp Suite**
```bash
# Configurar JVM con proxy
export JAVA_OPTS="-Dhttp.proxyHost=proxy.centro.edu -Dhttp.proxyPort=8080 -Dhttps.proxyHost=proxy.centro.edu -Dhttps.proxyPort=8080"

# Lanzar Burp
burpsuite
```

**C. nmap con proxy**
```bash
# nmap no soporta proxy HTTP directamente
# Usar proxychains
sudo apt install proxychains4

# Configurar proxychains
sudo nano /etc/proxychains4.conf
# Añadir: http proxy.centro.edu 8080

# Usar nmap con proxychains
proxychains4 nmap target.com
```

### 6. Git no funciona

#### Síntomas:
- `git clone` falla
- `git pull/push` no funciona

#### Soluciones:

**A. Configurar git con proxy**
```bash
git config --global http.proxy http://proxy.centro.edu:8080
git config --global https.proxy http://proxy.centro.edu:8080
```

**B. Para repositorios específicos**
```bash
# Solo para un repositorio
cd /path/to/repo
git config http.proxy http://proxy.centro.edu:8080
```

**C. Verificar configuración**
```bash
git config --list | grep proxy
```

### 7. Script automático no funciona

#### Síntomas:
- `./configure-proxy.sh` da errores
- Script no detecta el sistema correctamente

#### Soluciones:

**A. Verificar permisos**
```bash
ls -l configure-proxy.sh
# Debe mostrar: -rwxr-xr-x

# Si no es ejecutable:
chmod +x configure-proxy.sh
```

**B. Ejecutar con bash explícitamente**
```bash
bash configure-proxy.sh
```

**C. Verificar dependencias**
```bash
# Instalar herramientas necesarias
sudo apt update
sudo apt install curl wget
```

**D. Ejecutar paso a paso (debug)**
```bash
bash -x configure-proxy.sh
# Muestra cada comando ejecutado
```

## 🔍 Herramientas de Diagnóstico

### Verificar estado actual

```bash
# 1. Variables de entorno
env | grep -i proxy

# 2. Configuración APT
cat /etc/apt/apt.conf.d/95proxies

# 3. Conectividad básica
ping proxy.centro.edu

# 4. Conectividad HTTP
curl -I http://httpbin.org/ip

# 5. Test de APT
sudo apt update --dry-run
```

### Script de diagnóstico completo

```bash
#!/bin/bash
# diagnostic.sh - Diagnóstico completo de proxy

echo "=== DIAGNÓSTICO DE PROXY ==="
echo "Fecha: $(date)"
echo

echo "1. Variables de entorno:"
env | grep -i proxy || echo "No configuradas"
echo

echo "2. Configuración APT:"
if [ -f /etc/apt/apt.conf.d/95proxies ]; then
    cat /etc/apt/apt.conf.d/95proxies
else
    echo "No configurado"
fi
echo

echo "3. Red actual:"
echo "Gateway: $(ip route | grep default | awk '{print $3}')"
echo "DNS: $(cat /etc/resolv.conf | grep nameserver | head -1)"
echo

echo "4. Conectividad:"
if ping -c 1 proxy.centro.edu &>/dev/null; then
    echo "✓ Proxy accesible"
else
    echo "✗ Proxy no accesible"
fi

if curl -s --connect-timeout 5 http://httpbin.org/ip &>/dev/null; then
    echo "✓ Internet funcional"
else
    echo "✗ Sin acceso a Internet"
fi

echo
echo "5. Configuración de usuario:"
echo "Usuario: $(whoami)"
echo "Home: $HOME"
if [ -f ~/.curlrc ]; then
    echo "curl config: $(cat ~/.curlrc)"
fi
```

## 📋 Configuraciones Típicas por Centro

### Centro Tipo A (Básico)
```bash
PROXY_HOST="proxy.centro.edu"
PROXY_PORT="8080"
NO_AUTH=true
```

### Centro Tipo B (Con autenticación)
```bash
PROXY_HOST="10.0.0.1"
PROXY_PORT="3128"
PROXY_USER="estudiante"
PROXY_PASS="password123"
```

### Centro Tipo C (Múltiples proxies)
```bash
HTTP_PROXY="proxy-http.centro.edu:8080"
HTTPS_PROXY="proxy-https.centro.edu:8443"
FTP_PROXY="proxy-ftp.centro.edu:21"
```

## 🆘 Escalación de Problemas

### Nivel 1: Auto-diagnóstico
1. Ejecutar script de diagnóstico
2. Verificar configuración básica
3. Probar configuración manual

### Nivel 2: Ayuda del profesor
1. Verificar datos del proxy del centro
2. Confirmar que otros estudiantes tienen el mismo problema
3. Verificar configuración específica del aula

### Nivel 3: Administrador del centro
1. Verificar estado del proxy del centro
2. Confirmar reglas de firewall
3. Verificar logs del proxy

### Información a proporcionar

Cuando pidas ayuda, incluye:

```bash
# Ejecutar y compartir resultado:
echo "Sistema: $(lsb_release -d)"
echo "Usuario: $(whoami)"
echo "Red: $(ip route | grep default)"
env | grep -i proxy
cat /etc/apt/apt.conf.d/95proxies 2>/dev/null
ping -c 1 proxy.centro.edu
curl -I http://httpbin.org/ip
```

---

💡 **Consejo**: La mayoría de problemas se resuelven verificando que los datos del proxy (host y puerto) son correctos para tu centro específico.
