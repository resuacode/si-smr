# Provisioning script para Windows Server
# Configuración mínima de IIS y SMB

Write-Host "============================================" -ForegroundColor Green
Write-Host "Configurando Windows Server..." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Configurar zona horaria
tzutil /s "Romance Standard Time"

# Configurar teclado español
Set-WinUserLanguageList -LanguageList es-ES -Force

# Crear usuario labadmin
try {
    $Password = ConvertTo-SecureString "Password123!" -AsPlainText -Force
    New-LocalUser -Name "labadmin" -Password $Password -FullName "Lab Administrator" -Description "Administrador del laboratorio" -ErrorAction Stop
    Add-LocalGroupMember -Group "Administradores" -Member "labadmin" -ErrorAction Stop
    Write-Host "Usuario labadmin creado" -ForegroundColor Green
} catch {
    Write-Host "Usuario labadmin ya existe o error: $_" -ForegroundColor Yellow
}

# Instalar IIS
Write-Host "Instalando IIS..." -ForegroundColor Cyan
try {
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools -ErrorAction Stop
    Write-Host "IIS instalado correctamente" -ForegroundColor Green
} catch {
    Write-Host "Error instalando IIS: $_" -ForegroundColor Yellow
}

# Crear página web simple
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Windows Server - Lab SAD</title>
</head>
<body>
    <h1>Windows Server - Laboratorio SAD</h1>
    <p>IIS funcionando correctamente</p>
    <p>IP: 192.168.56.11</p>
</body>
</html>
"@

$htmlContent | Out-File -FilePath "C:\inetpub\wwwroot\index.html" -Encoding UTF8

# Crear directorio compartido SMB
$sharePath = "C:\Shares\Public"
if (!(Test-Path $sharePath)) {
    New-Item -Path $sharePath -ItemType Directory -Force
    
    # Crear share SMB
    New-SmbShare -Name "Public" -Path $sharePath -FullAccess "Everyone" -ErrorAction SilentlyContinue
    
    # Permisos NTFS
    $acl = Get-Acl $sharePath
    $permission = "Everyone","FullControl","Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($accessRule)
    Set-Acl $sharePath $acl
    
    Write-Host "Share SMB creado: \\192.168.56.11\Public" -ForegroundColor Green
}

# Configurar firewall - Permitir ping
netsh advfirewall firewall add rule name="Allow ICMPv4-In" protocol=icmpv4:8,any dir=in action=allow
netsh advfirewall firewall add rule name="Allow ICMPv4-Out" protocol=icmpv4:8,any dir=out action=allow

# Configurar firewall - Permitir HTTP
netsh advfirewall firewall add rule name="Allow HTTP" protocol=TCP dir=in localport=80 action=allow

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
Write-Host "Windows Server configurado correctamente" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host "Usuario: labadmin / Password123!" -ForegroundColor Cyan
Write-Host "IIS: http://192.168.56.11" -ForegroundColor Cyan
Write-Host "SMB: \\192.168.56.11\Public" -ForegroundColor Cyan
Write-Host "RDP: 192.168.56.11:3389" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Green
