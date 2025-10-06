# Configuración básica de Windows Server 2019/2022

Write-Host "======================================="
Write-Host "Configurando Windows Server para lab"
Write-Host "======================================="

try {
    # Configurar zona horaria
    Write-Host "Configurando zona horaria..."
    Set-TimeZone -Name "Romance Standard Time" -ErrorAction SilentlyContinue
    
    # NO configurar red estática - dejar que Vagrant lo maneje
    Write-Host "Saltando configuración de red (manejada por Vagrant)..."
    
    # Desactivar Windows Defender (solo para laboratorio)
    Write-Host "Configurando Windows Defender..."
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableIOAVProtection $true -ErrorAction SilentlyContinue
    
    # Habilitar RDP
    Write-Host "Habilitando RDP..."
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0 -ErrorAction SilentlyContinue
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

    
    # Configurar usuarios de laboratorio
    Write-Host "Configurando usuarios..."
    $Password = ConvertTo-SecureString "Password123!" -AsPlainText -Force
    
    # Usuario administrador de laboratorio (solo si no existe)
    if (!(Get-LocalUser -Name "labadmin" -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name "labadmin" -Password $Password -FullName "Lab Administrator" -Description "Administrador del laboratorio" -ErrorAction SilentlyContinue
        Add-LocalGroupMember -Group "Administrators" -Member "labadmin" -ErrorAction SilentlyContinue
    }
    
    # Usuario estándar para pruebas (solo si no existe)
    if (!(Get-LocalUser -Name "labuser" -ErrorAction SilentlyContinue)) {
        New-LocalUser -Name "labuser" -Password $Password -FullName "Lab User" -Description "Usuario estándar del laboratorio" -ErrorAction SilentlyContinue
        Add-LocalGroupMember -Group "Users" -Member "labuser" -ErrorAction SilentlyContinue
    }
    
    # Configurar carpetas compartidas vulnerables para ejercicios
    Write-Host "Configurando recursos compartidos..."
    New-Item -ItemType Directory -Path "C:\Shares\Public" -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path "C:\Shares\Admin" -Force -ErrorAction SilentlyContinue
    
    # Crear shares solo si no existen
    if (!(Get-SmbShare -Name "Public" -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name "Public" -Path "C:\Shares\Public" -FullAccess "Everyone" -ErrorAction SilentlyContinue
    }
    if (!(Get-SmbShare -Name "Admin" -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name "Admin" -Path "C:\Shares\Admin" -FullAccess "Administrators" -ErrorAction SilentlyContinue
    }
    
    # Crear archivos de ejemplo con información sensible (para ejercicios)
    Write-Host "Creando archivos de ejemplo..."
    @"
Archivo de configuración del servidor
Usuario: admin
Password: admin123
Base de datos: server-db
"@ | Out-File -FilePath "C:\Shares\Public\config.txt" -Encoding UTF8 -ErrorAction SilentlyContinue
    
    @"
Lista de usuarios del dominio:
- Administrator
- labadmin (Administrador)
- labuser (Usuario estándar)
- guest (Deshabilitado)
"@ | Out-File -FilePath "C:\Shares\Admin\users.txt" -Encoding UTF8 -ErrorAction SilentlyContinue
    
    Write-Host "Configuración básica completada exitosamente"
    
} catch {
    Write-Host "Error en configuración básica: $($_.Exception.Message)"
    Write-Host "Continuando con el proceso..."
}
