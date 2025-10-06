# Instalación y configuración de servicios en Windows Server

Write-Host "======================================="
Write-Host "Instalando servicios de Windows Server"
Write-Host "======================================="

# Instalar IIS con características básicas
Write-Host "Instalando IIS..."
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

# Configurar sitio web vulnerable para ejercicios
$webRoot = "C:\inetpub\wwwroot"
@"
<!DOCTYPE html>
<html>
<head>
    <title>Servidor Web del Laboratorio</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .info-box { background: #f0f8ff; padding: 20px; border-left: 4px solid #007acc; margin: 20px 0; }
        .warning { background: #fff3cd; border-left: 4px solid #ffc107; color: #856404; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Servidor Web del Laboratorio SAD</h1>
        
        <div class="info-box">
            <h3>Información del Sistema</h3>
            <p><strong>Servidor:</strong> Windows Server 2019/2022</p>
            <p><strong>IP:</strong> 192.168.56.11</p>
            <p><strong>Servicios:</strong> IIS, SMB, RDP</p>
        </div>

        <div class="info-box warning">
            <h3>⚠️ Aviso</h3>
            <p>Este servidor contiene vulnerabilidades intencionadas para fines educativos.</p>
            <p>No usar en entornos de producción.</p>
        </div>

        <h3>Recursos Disponibles:</h3>
        <ul>
            <li><a href="/admin/">Panel de Administración</a></li>
            <li><a href="/info.php">Información del Sistema</a></li>
            <li><a href="/config/">Configuración</a></li>
        </ul>
    </div>
</body>
</html>
"@ | Out-File -FilePath "$webRoot\index.html" -Encoding UTF8

# Crear directorio admin con contenido vulnerable
New-Item -ItemType Directory -Path "$webRoot\admin" -Force
@"
<!DOCTYPE html>
<html>
<head><title>Admin Panel</title></head>
<body>
    <h1>Panel de Administración</h1>
    <form method="POST" action="login.php">
        <p>Usuario: <input type="text" name="user"></p>
        <p>Password: <input type="password" name="pass"></p>
        <p><input type="submit" value="Login"></p>
    </form>
    <!-- TODO: Implementar autenticación segura -->
    <!-- admin:admin123 -->
</body>
</html>
"@ | Out-File -FilePath "$webRoot\admin\index.html" -Encoding UTF8

# Crear archivo de configuración expuesto
New-Item -ItemType Directory -Path "$webRoot\config" -Force
@"
<?php
// Configuración de la base de datos
define('DB_HOST', '192.168.56.11');
define('DB_USER', 'admin');
define('DB_PASS', 'admin123');
define('DB_NAME', 'laboratorio');

// Configuración de depuración (NO usar en producción)
define('DEBUG', true);
define('SHOW_ERRORS', true);

if (DEBUG) {
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
}
?>
"@ | Out-File -FilePath "$webRoot\config\config.php" -Encoding UTF8

# Instalar servicio FTP (vulnerable para ejercicios)
Write-Host "Configurando FTP..."
Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPSvc
Enable-WindowsOptionalFeature -Online -FeatureName IIS-FTPExtensibility

# Crear sitio FTP básico
Import-Module WebAdministration
New-WebFtpSite -Name "FTP-Lab" -PhysicalPath "C:\inetpub\ftproot" -Port 21

# Configurar FTP con autenticación básica
Set-ItemProperty -Path "IIS:\Sites\FTP-Lab" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
Set-ItemProperty -Path "IIS:\Sites\FTP-Lab" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $true

# Crear contenido FTP
$ftpRoot = "C:\inetpub\ftproot"
New-Item -ItemType Directory -Path $ftpRoot -Force
@"
Archivos disponibles en FTP:
- readme.txt (este archivo)
- backup.zip (copia de seguridad)
- logs/ (directorio de logs)

Credenciales de ejemplo:
Usuario: ftpuser
Password: ftp123
"@ | Out-File -FilePath "$ftpRoot\readme.txt" -Encoding UTF8

# Configurar eventos de Windows para ejercicios
Write-Host "Configurando auditoría..."
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
auditpol /set /category:"Object Access" /success:enable /failure:enable
auditpol /set /category:"Policy Change" /success:enable /failure:enable

Write-Host "Servicios instalados y configurados"
