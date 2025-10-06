# Provisioning script para Windows Client
# Configuración básica de usuario

Write-Host "============================================" -ForegroundColor Green
Write-Host "Configurando Windows Client..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Configurar zona horaria
tzutil /s "Romance Standard Time"

# Configurar teclado español
Set-WinUserLanguageList -LanguageList es-ES -Force

# Crear usuario cliente
try {
    $Password = ConvertTo-SecureString "User123!" -AsPlainText -Force
    New-LocalUser -Name "cliente" -Password $Password -FullName "Usuario Cliente" -Description "Usuario cliente del laboratorio" -ErrorAction Stop
    Add-LocalGroupMember -Group "Usuarios" -Member "cliente" -ErrorAction Stop
    Write-Host "Usuario cliente creado" -ForegroundColor Green
} catch {
    Write-Host "Usuario cliente ya existe o error: $_" -ForegroundColor Yellow
}

# Habilitar RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Escritorio remoto"

# Configurar firewall - Permitir ping
netsh advfirewall firewall add rule name="Allow ICMPv4-In" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="Allow ICMPv4-Out" protocol=icmpv4:8,any dir=out action=allow

# Configurar WinRM
Write-Host "Configurando WinRM..." -ForegroundColor Cyan
winrm quickconfig -quiet -force
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Añadir entradas hosts
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$hostsEntries = @"

192.168.56.10 ubuntu-server
192.168.56.11 windows-server
192.168.56.12 windows-client
192.168.56.13 storage-backup
192.168.56.20 kali-security
"@
Add-Content -Path $hostsFile -Value $hostsEntries

# Configurar grupo de trabajo
$workgroup = "LAB-SAD"
Add-Computer -WorkgroupName $workgroup -Force -ErrorAction SilentlyContinue

Write-Host "============================================" -ForegroundColor Green
Write-Host "Windows Client configurado correctamente" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "Usuario: cliente / User123!" -ForegroundColor Cyan
Write-Host "RDP: 192.168.56.12:3389" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Green
