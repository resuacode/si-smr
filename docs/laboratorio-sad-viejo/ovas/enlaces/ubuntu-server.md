# Ubuntu Server - Descarga OVA

## 📦 Ubuntu Server 22.04 LTS - Servidor SAD

**Archivo:** `Ubuntu-Server-SAD.ova`  
**Tamaño:** ~3.5 GB  
**Sistema:** Ubuntu Server 22.04.3 LTS  
**Configuración:** 2 GB RAM, 1 vCPU, 25 GB disco  

## 🔐 Credenciales Preconfiguradas

- **Usuario principal:** `admin`
- **Contraseña:** `adminSAD2024!`
- **Usuario vagrant:** `vagrant`
- **Contraseña vagrant:** `vagrant`

## 🔗 [Enlace de Descarga](https://iesarmandocotarelovall-my.sharepoint.com/:u:/g/personal/dresua_iescotarelo_org/EejD2FSy7sFJtHfRKOCKc-8BujLzQi4icD-byoPU7KXDMQ?e=2cXqdX)


## ✅ Verificación de Integridad

**SHA256 Checksum:**
```
ef5e0e23324f271ccd6fcbac9bece799dd2e8333abb557f0717eb92b7457d343
```

**Verificar en Linux/macOS:**
```bash
sha256sum Ubuntu-Server-SAD.ova
```

**Verificar en Windows:**
```powershell
Get-FileHash -Path "Ubuntu-Server-SAD.ova" -Algorithm SHA256
```

## 📋 Software Preinstalado

- **Sistema base:** Ubuntu Server 22.04 LTS
- **Servicios:** SSH, Apache2, MySQL, PHP 8.1
- **Herramientas:** vim, htop, tree, curl, wget
- **Seguridad:** UFW, fail2ban
- **Certificados:** OpenSSL, CA personalizada para laboratorio
- **Red:** Configuración estática 192.168.56.10

## 🔧 Configuración Post-Importación

1. **Verificar red:** Debe estar en `vboxnet-sad` (192.168.56.0/24)
2. **Confirmar IP:** 192.168.56.10
3. **Probar SSH:** `ssh servidor@192.168.56.10`
4. **Verificar servicios:** Apache y MySQL deben estar activos
5. **Comprobar certificados:** CA debe estar instalada en `/etc/ssl/certs/`

## 🔑 Servicios de Certificados

Este servidor incluye:

- **Autoridad Certificadora (CA)** personalizada
- **Certificados** para servidor web (SSL/TLS)
- **Scripts** para generar certificados cliente
- **Configuración** Apache con SSL habilitado

### Certificados Preconfigurados

- **CA Root:** `/etc/ssl/certs/SAD-CA.crt`
- **Servidor Web:** `/etc/ssl/certs/servidor-sad.crt`
- **Clave privada:** `/etc/ssl/private/servidor-sad.key`

## 📞 Soporte

- 📚 **Documentación:** [Troubleshooting](../../documentacion/troubleshooting.md)

---

**⚠️ Nota:** Esta OVA está configurada únicamente para fines educativos. No usar en entornos de producción.
