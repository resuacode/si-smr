# Configuración de Red para Laboratorio SAD

## Red Privada del Laboratorio
- **Red:** 192.168.56.0/24
- **Gateway:** 192.168.56.1 (VirtualBox)
- **Rango DHCP:** 192.168.56.100-254 (para otras VMs)

## Asignación de IPs Estáticas

| VM | Hostname | IP | Servicios |
|---|---|---|---|
| Ubuntu Server | ubuntu-server | 192.168.56.10 | Apache, MySQL, SSH, Docker |
| Windows Server | windows-server | 192.168.56.11 | AD DS, DNS, DHCP, IIS |
| Windows Client | windows-client | 192.168.56.12 | Cliente del dominio |
| Storage Backup | storage-backup | 192.168.56.13 | Samba, NFS, Bacula |
| Kali Security | kali-security | 192.168.56.20 | Herramientas de seguridad |

## Puertos Forwardeados al Host

| VM | Servicio | Puerto Guest | Puerto Host |
|---|---|---|---|
| Ubuntu Server | SSH | 22 | 2210 |
| Ubuntu Server | HTTP | 80 | 8010 |
| Ubuntu Server | HTTPS | 443 | 8443 |
| Windows Server | RDP | 3389 | 3389 |
| Windows Server | WinRM | 5985 | 5985 |
| Windows Server | IIS | 80 | 8011 |
| Windows Client | RDP | 3389 | 3390 |
| Storage Backup | SSH | 22 | 2213 |
| Storage Backup | SMB | 445 | 4445 |
| Storage Backup | NFS | 2049 | 2049 |
| Kali Security | SSH | 22 | 2220 |
| Kali Security | Metasploit | 4444 | 4444 |

## Credenciales por Defecto

### Ubuntu Server
- **Usuario:** vagrant / contraseña: vagrant
- **Usuario admin:** admin / contraseña: adminSAD2024!

### Windows Server  
- **Usuario:** vagrant / contraseña: vagrant
- **Administrador:** Administrator / contraseña: (configurar en primer arranque)

### Windows Client
- **Usuario:** vagrant / contraseña: vagrant  
- **Usuario cliente:** cliente / contraseña: User123!

### Storage Backup
- **Usuario:** vagrant / contraseña: vagrant
- **Usuario backup:** backup / contraseña: backup123

### Kali Security
- **Usuario:** kali / contraseña: kali