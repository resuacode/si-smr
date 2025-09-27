# 🏢 Configuración de Proxy - Guía para Estudiantes

## ¿Cuándo necesito esto?

**SOLO** cuando uses las máquinas virtuales **dentro del centro educativo**.

- ✅ **En el centro**: Sí, necesitas configurar el proxy
- ❌ **En casa**: No es necesario
- ❌ **Otras redes**: No es necesario

## 🚀 Configuración Rápida (Método Recomendado)

### 1. Abrir terminal en la VM

```bash
# Ubuntu Server / Debian Storage
ssh usuario@192.168.56.X

# Kali Linux (desde escritorio)
Ctrl + Alt + T
```

### 2. Ejecutar script automático

```bash
# Ir a la carpeta de scripts
cd ~/sad-scripts

# Ejecutar configurador
./configure-proxy.sh
```

### 3. Seguir las instrucciones

El script te preguntará:
- **Host del proxy**: Normalmente `proxy.centro.edu` (preguntar al profesor)
- **Puerto**: Normalmente `8080` 
- **Usuario/contraseña**: Si el centro lo requiere

### 4. Verificar que funciona

```bash
# Probar conectividad
curl http://httpbin.org/ip

# Si funciona, verás algo como:
# {
#   "origin": "X.X.X.X"
# }
```

## 🔧 Configuración Manual (Si el script no funciona)

### Para Ubuntu Server / Debian Storage

```bash
# 1. Configurar variables de entorno
sudo nano /etc/environment

# 2. Añadir estas líneas (ajustar según tu centro):
export http_proxy="http://proxy.centro.edu:8080"
export https_proxy="http://proxy.centro.edu:8080"
export no_proxy="localhost,127.0.0.1,192.168.*"

# 3. Configurar APT
sudo nano /etc/apt/apt.conf.d/95proxies

# 4. Añadir:
Acquire::http::Proxy "http://proxy.centro.edu:8080";
Acquire::https::Proxy "http://proxy.centro.edu:8080";

# 5. Aplicar cambios
source /etc/environment
sudo apt update
```

### Para Kali Linux

```bash
# 1. Configurar sistema (igual que Ubuntu)
sudo nano /etc/environment
# (mismas líneas que arriba)

# 2. Configurar herramientas adicionales
echo "proxy = proxy.centro.edu:8080" > ~/.curlrc

# 3. Aplicar
source /etc/environment
```

### Para Windows Server / Windows Client

1. **Abrir configuración de red**:
   - Panel de Control → Opciones de Internet → Conexiones → Configuración de LAN

2. **Marcar**: "Usar un servidor proxy para la LAN"

3. **Configurar**:
   - Dirección: `proxy.centro.edu`
   - Puerto: `8080`
   - Marcar: "No usar servidor proxy para direcciones locales"

4. **Aplicar** y reiniciar navegador

## ❌ Eliminar Configuración de Proxy

Si ya no estás en el centro o quieres quitar la configuración:

```bash
# Usar script de eliminación automática
~/remove-proxy.sh

# O manual:
sudo sed -i '/proxy/d' /etc/environment
sudo rm -f /etc/apt/apt.conf.d/95proxies
rm -f ~/.curlrc ~/.wgetrc
```

## 🔍 Solución de Problemas

### Problema: "No se puede conectar a Internet"

**Solución 1**: Verificar configuración
```bash
echo $http_proxy
# Debe mostrar: http://proxy.centro.edu:8080
```

**Solución 2**: Aplicar configuración
```bash
source /etc/environment
```

**Solución 3**: Verificar datos del proxy
- Preguntar al profesor/administrador del centro
- Host correcto (puede ser IP: `10.0.0.1`)
- Puerto correcto (puede ser `3128`)

### Problema: "Comando no encontrado"

```bash
# Primero aplicar configuración
source /etc/environment

# Luego probar comando
```

### Problema: APT no funciona

```bash
# Verificar configuración APT
cat /etc/apt/apt.conf.d/95proxies

# Debe contener líneas como:
# Acquire::http::Proxy "http://proxy.centro.edu:8080";
```

### Problema: Navegador no navega

- **Firefox**: Ir a Preferencias → Red → Configuración de conexión
- **Configurar manualmente**:
  - HTTP: `proxy.centro.edu` puerto `8080`
  - HTTPS: `proxy.centro.edu` puerto `8080`
  - Sin proxy para: `localhost, 127.0.0.1, 192.168.*`

## 📞 ¿Necesitas Ayuda?

1. **Primero**: Verifica que estás usando la configuración correcta del centro
2. **Pregunta al profesor**: Los datos exactos del proxy
3. **Compañeros**: Pregunta si a otros les funciona
4. **Último recurso**: Usar método manual paso a paso

## 📋 Datos Típicos de Centros Educativos

**Configuraciones comunes**:
- `proxy.centro.edu:8080`
- `proxy.edu:3128`
- `10.0.0.1:8080`
- `192.168.1.1:3128`

**Sin autenticación**: La mayoría de centros no requieren usuario/contraseña

---

💡 **Truco**: Si nada funciona, pregunta al administrador del centro por los datos exactos del proxy.
