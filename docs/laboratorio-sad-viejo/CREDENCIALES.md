# Credenciales Definitivas del Laboratorio SAD

## 📋 **Credenciales por VM (según Vagrantfile y scripts)**

### 🐧 **Ubuntu Server (192.168.56.10)**
- **vagrant** / `vagrant` - Usuario Vagrant (acceso SSH automático)
- **admin** / `adminSAD2024!` - Usuario administrador con sudo

### 🥷 **Kali Security (192.168.56.20)**  
- **vagrant** / `vagrant` - Usuario Vagrant (acceso SSH automático)
- **kali** / `kali` - Usuario principal de Kali

### 💾 **Storage Backup (192.168.56.13)**
- **vagrant** / `vagrant` - Usuario Vagrant (acceso SSH automático) 
- **backup** / `backup123` - Usuario para servicios de backup

### 🪟 **Windows Server (192.168.56.11)**
- **vagrant** / `vagrant` - Usuario Vagrant (WinRM y RDP)
- **labadmin** / `Password123!` - Administrador del laboratorio
- **labuser** / `Password123!` - Usuario estándar

### 💻 **Windows Client (192.168.56.12)**
- **vagrant** / `vagrant` - Usuario Vagrant (WinRM y RDP)
- **cliente** / `User123!` - Usuario cliente
- **clienteadmin** / `User123!` - Administrador local

## 🔗 **Accesos por puerto (forwarded)**

| VM | Servicio | Puerto | Usuario recomendado |
|----|----------|--------|-------------------|
| Ubuntu Server | SSH | 2210 | admin |
| Kali Security | SSH | 2220 | kali |  
| Storage Backup | SSH | 2213 | backup |
| Windows Server | RDP | 3389 | labadmin |
| Windows Client | RDP | 3390 | cliente |

## ⚠️ **Notas importantes:**

1. **Usuario vagrant**: Existe en todas las VMs, pero es para uso interno de Vagrant
2. **Acceso SSH directo**: Usar `vagrant ssh <nombre-vm>` para acceso automático
3. **Para estudiantes**: Usar los usuarios específicos (admin, kali, backup, labadmin, cliente)
4. **Cambio de contraseñas**: Se pueden cambiar después del despliegue inicial

## 🔧 **Comandos de conexión:**

```bash
# SSH directo (sin Vagrant)
ssh admin@192.168.56.10        # Ubuntu (adminSAD2024!)
ssh kali@192.168.56.20         # Kali (kali)
ssh backup@192.168.56.13       # Storage (backup123)

# SSH por puerto forwarded
ssh -p 2210 admin@localhost    # Ubuntu
ssh -p 2220 kali@localhost     # Kali  
ssh -p 2213 backup@localhost   # Storage

# RDP (usar cliente RDP)
localhost:3389                 # Windows Server (labadmin:Password123!)
localhost:3390                 # Windows Client (cliente:User123!)

# Vagrant SSH (automático, usa usuario vagrant)
vagrant ssh ubuntu-server
vagrant ssh kali-security
vagrant ssh storage-backup
# (Windows no soporta vagrant ssh, usar RDP)
```