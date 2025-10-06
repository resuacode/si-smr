# Windows Client - Descarga OVA

## 📦 Windows 10/11 LTSC - Cliente SAD

**Archivo:** `Windows10-Client-SAD.ova`  
**Tamaño:** ~6 GB  
**Sistema:** Windows 10 LTSC 2021  
**Configuración:** 2 GB RAM, 1 vCPU, 20 GB disco  

## 🔐 Credenciales Preconfiguradas

- **Usuario principal:** `cliente`
- **Contraseña:** `User123!`
- **Usuario admin:** `clienteadmin`
- **Contraseña admin:** `User123!`

## 🔗 [Enlace de Descarga](https://iesarmandocotarelovall-my.sharepoint.com/:u:/g/personal/dresua_iescotarelo_org/EU4ZtKi5bzlEplQGBfbWww8Be0hgCNjFutHwpP_j-p6yUw?e=m21O8z)

## ✅ Verificación de Integridad

**SHA256 Checksum:**
```
3fa2d62ed596331a4da240de4e3270a662f2b3ad0ed5a76c93f60e76e9b827b4
```

**Verificar en Linux/macOS:**
```bash
sha256sum Windows10-Client-SAD.ova
```

**Verificar en Windows:**
```powershell
Get-FileHash -Path "Windows10-Client-SAD.ova" -Algorithm SHA256
```

## 📋 Software Preinstalado

- **Sistema base:** Windows 10 LTSC optimizado
- **Navegadores:** Edge, Firefox
- **Herramientas:** 7-Zip, Notepad++
- **Clientes:** PuTTY, WinSCP
- **Seguridad:** Windows Defender (configurado para laboratorio)
- **Red:** Configuración estática 192.168.56.12

## 🔧 Configuración Post-Importación

1. **Verificar red:** Debe estar en `vboxnet-sad` (192.168.56.0/24)
2. **Confirmar IP:** 192.168.56.12
3. **Probar RDP:** Debe aceptar conexiones remotas
4. **Verificar usuarios:** cliente y clienteadmin deben funcionar

## 📞 Soporte
- 📚 **Documentación:** [Troubleshooting](../../documentacion/troubleshooting.md)

---

**⚠️ Nota:** Esta OVA está configurada únicamente para fines educativos. No usar en entornos de producción.
