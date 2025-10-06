# Configuración básica de Windows Client

Write-Host "======================================="
Write-Host "Configurando Windows Client para lab"
Write-Host "======================================="

# Configurar zona horaria
Set-TimeZone -Name "Romance Standard Time"

# Configurar red estática
$adapter = Get-NetAdapter | Where-Object {$_.Name -like "*Ethernet*" -and $_.Status -eq "Up"} | Select-Object -First 1
if ($adapter) {
    Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.56.12" -PrefixLength 24 -DefaultGateway "192.168.56.1"
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "8.8.8.8", "8.8.4.4"
}

# Desactivar Windows Defender temporalmente (solo para laboratorio)
Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue

# Configurar usuarios de prueba
$Password = ConvertTo-SecureString "User123!" -AsPlainText -Force

# Usuario estándar
New-LocalUser -Name "cliente" -Password $Password -FullName "Usuario Cliente" -Description "Usuario cliente del laboratorio"
Add-LocalGroupMember -Group "Users" -Member "cliente"

# Usuario con privilegios locales
New-LocalUser -Name "clienteadmin" -Password $Password -FullName "Cliente Admin" -Description "Usuario administrador local"
Add-LocalGroupMember -Group "Administrators" -Member "clienteadmin"

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Configurar carpetas de usuario con archivos de ejemplo
$userDocs = "C:\Users\Public\Documents\Laboratorio"
New-Item -ItemType Directory -Path $userDocs -Force

@"
Documento personal - Cliente
=============================

Información de contacto:
- Email: cliente@empresa.local
- Teléfono: 555-0123
- Departamento: Ventas

Notas:
- Contraseña WiFi oficina: WiFi2023!
- VPN: vpn.empresa.com
- Servidor archivos: \\192.168.56.11\shares
"@ | Out-File -FilePath "$userDocs\info_personal.txt" -Encoding UTF8

@"
Historial de navegación simulado
================================

Sitios frecuentes:
- https://empresa.local/intranet
- https://webmail.empresa.com
- http://192.168.56.11/admin
- https://drive.google.com
- https://banking.ejemplo.com

Descargas recientes:
- informe_ventas_Q3.xlsx
- software_instalacion.exe
- manual_usuario.pdf
"@ | Out-File -FilePath "$userDocs\historial_navegacion.txt" -Encoding UTF8

# Instalar software adicional útil para ejercicios
Write-Host "Configurando software adicional..."

# Configurar navegador con historial y cookies de ejemplo
$chromePrefs = @"
{
   "bookmark_bar" : {
      "show_on_all_tabs" : true
   },
   "distribution" : {
      "make_chrome_default_for_user" : true,
      "system_level" : true
   },
   "dns_prefetching" : {
      "enabled" : false
   },
   "profile" : {
      "default_content_setting_values" : {
         "geolocation" : 1
      }
   }
}
"@

# Crear estructura de datos de navegador (simulada)
$browserData = "C:\Users\Public\AppData\Browser"
New-Item -ItemType Directory -Path $browserData -Force

@"
Historia de navegación (simulada para análisis forense):

2024-01-15 09:30:15 - https://empresa.local/login
2024-01-15 09:35:22 - http://192.168.56.11/admin
2024-01-15 10:15:45 - https://banking.ejemplo.com/login
2024-01-15 11:30:10 - https://webmail.empresa.com
2024-01-15 14:20:33 - http://192.168.56.11/config/
2024-01-15 15:45:12 - https://drive.google.com/shared_folder
"@ | Out-File -FilePath "$browserData\history.txt" -Encoding UTF8

# Configurar tareas programadas simuladas
Write-Host "Configurando tareas programadas..."

# Crear script de backup automático (simulado)
$backupScript = "C:\Scripts\backup_personal.bat"
New-Item -ItemType Directory -Path "C:\Scripts" -Force
@"
@echo off
REM Script de backup personal (ejemplo vulnerable)
echo Iniciando backup...
xcopy "C:\Users\Public\Documents" "\\192.168.56.13\backup\" /s /e /y
echo Backup completado
"@ | Out-File -FilePath $backupScript -Encoding ASCII

# Crear tarea programada
$action = New-ScheduledTaskAction -Execute $backupScript
$trigger = New-ScheduledTaskTrigger -Daily -At "18:00"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "BackupPersonal" -Action $action -Trigger $trigger -Settings $settings -User "SYSTEM"

Write-Host "Configuración de Windows Client completada"
