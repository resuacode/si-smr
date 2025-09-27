# install-ad-services.ps1 - Versión simplificada sin conflictos

Write-Host "================================================"
Write-Host "Instalando servicios básicos de Windows Server"
Write-Host "================================================"

# Instalar solo DNS Server
Write-Host "Instalando DNS Server..."
Install-WindowsFeature -Name DNS -IncludeManagementTools

# Instalar DHCP Server
Write-Host "Instalando DHCP Server..."
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Instalar File Services
Write-Host "Instalando File Services..."
Install-WindowsFeature -Name FS-FileServer -IncludeManagementTools

# NO instalar AD DS ni Certificate Services para evitar conflictos
Write-Host "NOTA: AD DS y Certificate Services se instalarán manualmente después"

# Configurar DHCP básico
Write-Host "Configurando DHCP básico..."
try {
    Add-DhcpServerv4Scope -Name "Lab Network" -StartRange 192.168.56.50 -EndRange 192.168.56.100 -SubnetMask 255.255.255.0 -ErrorAction SilentlyContinue
    Set-DhcpServerv4OptionValue -DnsServer 192.168.56.11 -Router 192.168.56.1 -ErrorAction SilentlyContinue
} catch {
    Write-Host "Error configurando DHCP: $($_.Exception.Message)"
}

Write-Host "Servicios básicos instalados correctamente"
Write-Host "Para instalar AD DS manualmente después del reinicio:"
Write-Host "Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools"