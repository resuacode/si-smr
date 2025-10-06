# Script para reparar WinRM en Windows Server
# Este script debe ejecutarse como administrador

Write-Host "Iniciando reparación de WinRM..." -ForegroundColor Green

try {
    # Detener y reiniciar el servicio WinRM
    Write-Host "Reiniciando servicio WinRM..."
    Stop-Service WinRM -Force -ErrorAction SilentlyContinue
    Start-Service WinRM
    
    # Configurar WinRM básico
    Write-Host "Configurando WinRM..."
    winrm quickconfig -q -force
    
    # Habilitar PowerShell Remoting
    Write-Host "Habilitando PowerShell Remoting..."
    Enable-PSRemoting -Force -SkipNetworkProfileCheck
    
    # Configurar autenticación básica (solo para laboratorio)
    Write-Host "Configurando autenticación..."
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    
    # Configurar hosts confiables
    Write-Host "Configurando hosts confiables..."
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
    
    # Verificar configuración
    Write-Host "Verificando configuración WinRM..."
    winrm get winrm/config/service
    
    # Test de conectividad local
    Write-Host "Probando conectividad local..."
    Test-WSMan -ComputerName localhost
    
    Write-Host "Reparación de WinRM completada exitosamente!" -ForegroundColor Green
    
} catch {
    Write-Host "Error durante la reparación: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}