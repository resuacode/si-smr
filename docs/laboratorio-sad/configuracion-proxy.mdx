# Configuración de Proxy

Esta guía explica cómo configurar un proxy en cada VM del laboratorio si tu centro educativo o empresa usa uno.

## 📋 Información del Proxy

Antes de empezar, necesitas:
- **URL del proxy**: `http://proxy.ejemplo.com:8080`
- **Usuario** (si requiere autenticación): `usuario`
- **Contraseña** (si requiere autenticación): `password`

---

## 🐧 Ubuntu Server

### 1. Configurar proxy del sistema

```bash
sudo nano /etc/environment
```

Añadir:
```bash
http_proxy="http://usuario:password@proxy.ejemplo.com:8080"
https_proxy="http://usuario:password@proxy.ejemplo.com:8080"
ftp_proxy="http://usuario:password@proxy.ejemplo.com:8080"
no_proxy="localhost,127.0.0.1,192.168.56.0/24"

HTTP_PROXY="http://usuario:password@proxy.ejemplo.com:8080"
HTTPS_PROXY="http://usuario:password@proxy.ejemplo.com:8080"
FTP_PROXY="http://usuario:password@proxy.ejemplo.com:8080"
NO_PROXY="localhost,127.0.0.1,192.168.56.0/24"
```

Aplicar:
```bash
source /etc/environment
```

### 2. Configurar APT (gestor de paquetes)

```bash
sudo nano /etc/apt/apt.conf.d/95proxies
```

Añadir:
```
Acquire::http::Proxy "http://usuario:password@proxy.ejemplo.com:8080";
Acquire::https::Proxy "http://usuario:password@proxy.ejemplo.com:8080";
Acquire::ftp::Proxy "http://usuario:password@proxy.ejemplo.com:8080";
```

### 3. Configurar proxy para usuario específico

```bash
nano ~/.bashrc
```

Añadir al final:
```bash
export http_proxy="http://usuario:password@proxy.ejemplo.com:8080"
export https_proxy="http://usuario:password@proxy.ejemplo.com:8080"
export ftp_proxy="http://usuario:password@proxy.ejemplo.com:8080"
export no_proxy="localhost,127.0.0.1,192.168.56.0/24"
```

Aplicar:
```bash
source ~/.bashrc
```

### 4. Configurar MySQL (si necesita acceso externo)

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

No suele necesitar configuración de proxy.

---

## 🥷 Kali Linux

Mismo procedimiento que Ubuntu Server (es basado en Debian).

### Configuración adicional para herramientas:

**Metasploit**:
```bash
echo "setg Proxies http:usuario:password@proxy.ejemplo.com:8080" >> ~/.msf4/msfconsole.rc
```

**Nmap** (proxy SOCKS si está disponible):
```bash
nmap --proxies http://usuario:password@proxy.ejemplo.com:8080 <target>
```

---

## 💾 Storage Backup (Debian)

Mismo procedimiento que Ubuntu Server.

### Configuración adicional para Samba:

Samba no usa proxy (es protocolo local), pero si necesitas actualizaciones:

```bash
sudo nano /etc/apt/apt.conf.d/95proxies
```

Añadir la misma configuración que Ubuntu.

---

## 🪟 Windows Server

### 1. Configurar proxy del sistema

**PowerShell como Administrador**:
```powershell
# Configurar proxy
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyServer -Value "proxy.ejemplo.com:8080"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 1

# Excepciones (red local)
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyOverride -Value "192.168.56.*;localhost;127.0.0.1"
```

### 2. Configurar proxy con autenticación

**GUI**:
1. Panel de Control → Opciones de Internet
2. Conexiones → Configuración de LAN
3. Marcar "Usar un servidor proxy"
4. Servidor: `proxy.ejemplo.com` Puerto: `8080`
5. Avanzadas → Excepciones: `192.168.56.*;localhost;127.0.0.1`

### 3. Configurar proxy para WinRM/PowerShell

```powershell
netsh winhttp set proxy proxy.ejemplo.com:8080 bypass-list="192.168.56.*;localhost;127.0.0.1"
```

### 4. Variables de entorno (Windows)

**PowerShell**:
```powershell
[Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://usuario:password@proxy.ejemplo.com:8080", "Machine")
[Environment]::SetEnvironmentVariable("HTTPS_PROXY", "http://usuario:password@proxy.ejemplo.com:8080", "Machine")
```

---

## 💻 Windows Client

Mismo procedimiento que Windows Server.

**Método rápido con GUI**:
1. Configuración → Red e Internet → Proxy
2. Configuración manual de proxy
3. Dirección: `proxy.ejemplo.com`
4. Puerto: `8080`
5. Excepciones: `192.168.56.*;localhost;127.0.0.1`

---

## 🔧 Vagrant con Proxy

Si usas Vagrant detrás de un proxy:

### 1. Instalar plugin:
```bash
vagrant plugin install vagrant-proxyconf
```

### 2. Configurar en Vagrantfile:

```ruby
if Vagrant.has_plugin?("vagrant-proxyconf")
  config.proxy.http     = "http://usuario:password@proxy.ejemplo.com:8080"
  config.proxy.https    = "http://usuario:password@proxy.ejemplo.com:8080"
  config.proxy.no_proxy = "localhost,127.0.0.1,192.168.56.0/24"
end
```

### 3. O configurar globalmente:

```bash
export VAGRANT_HTTP_PROXY="http://usuario:password@proxy.ejemplo.com:8080"
export VAGRANT_HTTPS_PROXY="http://usuario:password@proxy.ejemplo.com:8080"
export VAGRANT_NO_PROXY="localhost,127.0.0.1,192.168.56.0/24"
```

---

## ✅ Verificar Configuración

### Linux:
```bash
# Ver variables de entorno
env | grep -i proxy

# Test de conectividad
curl -I http://www.google.com

# Test con wget
wget -O- http://www.google.com

# Ver configuración APT
apt-config dump | grep -i proxy
```

### Windows:
```powershell
# Ver configuración de proxy
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer, ProxyEnable

# Test de conectividad
Invoke-WebRequest -Uri "http://www.google.com"

# Ver configuración WinRM
netsh winhttp show proxy
```

---

## 🚫 Desactivar Proxy

### Linux:
```bash
# Eliminar variables de entorno
unset http_proxy https_proxy ftp_proxy

# Eliminar de archivos de configuración
sudo rm /etc/apt/apt.conf.d/95proxies
sudo rm /etc/environment
```

### Windows:
```powershell
# Desactivar proxy
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable -Value 0

# WinRM
netsh winhttp reset proxy
```

---

## 📝 Excepciones Importantes

**Siempre excluir de proxy**:
- `localhost`
- `127.0.0.1`
- `192.168.56.0/24` (red del laboratorio)
- `*.local` (si usas Active Directory)

**Formato de excepciones**:
- Linux: `localhost,127.0.0.1,192.168.56.0/24`
- Windows: `192.168.56.*;localhost;127.0.0.1`

---

## 🔐 Seguridad

**⚠️ Advertencia**: Escribir credenciales en texto plano es un riesgo de seguridad.

**Alternativas más seguras**:

1. **Proxy sin autenticación** (configurar en el proxy mismo)
2. **Usar variables de sesión** en lugar de archivos permanentes
3. **Proxy transparente** (configurado a nivel de red)
4. **Kerberos/NTLM** para autenticación Windows integrada

---

## 🆘 Problemas Comunes

### Error: "407 Proxy Authentication Required"
- Verificar usuario/contraseña
- Verificar formato: `http://user:pass@proxy:port`
- Caracteres especiales en contraseña: codificar en URL

### Error: "Timeout" o "Connection refused"
- Verificar que el proxy está accesible: `ping proxy.ejemplo.com`
- Verificar puerto correcto
- Verificar firewall local

### Proxy funciona en navegador pero no en terminal
- Configurar variables de entorno específicas
- Reiniciar sesión/terminal

---

## 📞 Contacto

Si tu centro educativo usa proxy:
- Solicitar configuración exacta al departamento de IT
- Preguntar si hay excepciones para laboratorios virtuales
- Solicitar documentación específica del proxy usado

---

**Nota**: Esta configuración es necesaria solo si tu red requiere proxy. La mayoría de redes domésticas no lo necesitan.

---

**Versión**: 2.0  
**Última actualización**: Octubre 2025
