#!/bin/bash
# install-vulnerable-apps.sh - Instalar aplicaciones web vulnerables para práticas

echo "==========================================="
echo "Instalando aplicaciones web vulnerables"
echo "==========================================="

# DVWA (Damn Vulnerable Web Application)
echo "Instalando DVWA..."
cd /var/www/html
git clone https://github.com/digininja/DVWA.git dvwa
chown -R www-data:www-data dvwa
chmod -R 755 dvwa

# Configurar DVWA
cd dvwa/config
cp config.inc.php.dist config.inc.php

# Configurar base de datos para DVWA
mysql -e "CREATE DATABASE dvwa;"
mysql -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'labuser'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Crear aplicación web simple vulnerable
echo "Creando aplicación web vulnerable personalizada..."
mkdir -p /var/www/html/vulnerable-app

cat > /var/www/html/vulnerable-app/index.php << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Aplicación Vulnerable - Laboratorio SAD</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .form-box { background: #f9f9f9; padding: 20px; border: 1px solid #ddd; margin: 20px 0; }
        .warning { background: #fff3cd; border: 1px solid #ffeeba; color: #856404; padding: 15px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔓 Aplicación Web Vulnerable</h1>
        <div class="warning">
            <strong>⚠️ ATENCIÓN:</strong> Esta aplicación contiene vulnerabilidades intencionadas para fines educativos.
        </div>

        <div class="form-box">
            <h3>Login Vulnerable (SQL Injection)</h3>
            <form method="POST" action="">
                <p>Usuario: <input type="text" name="username" placeholder="admin"></p>
                <p>Contraseña: <input type="password" name="password" placeholder="password"></p>
                <input type="submit" name="login" value="Login">
            </form>

            <?php
            if (isset($_POST['login'])) {
                $username = $_POST['username'];
                $password = $_POST['password'];
                
                // VULNERABILIDAD: SQL Injection
                $query = "SELECT * FROM users WHERE username='$username' AND password='$password'";
                echo "<p><strong>Query ejecutada:</strong> $query</p>";
                
                // Simulación de login vulnerable
                if ($username && $password) {
                    echo "<p style='color: green;'>¡Login exitoso! (simulado)</p>";
                }
            }
            ?>
        </div>

        <div class="form-box">
            <h3>Búsqueda Vulnerable (XSS)</h3>
            <form method="GET" action="">
                <p>Buscar: <input type="text" name="search" placeholder="<script>alert('XSS')</script>"></p>
                <input type="submit" value="Buscar">
            </form>

            <?php
            if (isset($_GET['search'])) {
                $search = $_GET['search'];
                // VULNERABILIDAD: XSS Reflejado
                echo "<p>Resultados para: " . $search . "</p>";
            }
            ?>
        </div>

        <div class="form-box">
            <h3>Upload de Archivos Vulnerable</h3>
            <form method="POST" action="" enctype="multipart/form-data">
                <p>Archivo: <input type="file" name="upload"></p>
                <input type="submit" name="upload_submit" value="Subir">
            </form>

            <?php
            if (isset($_POST['upload_submit'])) {
                $target_dir = "/var/www/html/vulnerable-app/uploads/";
                if (!file_exists($target_dir)) {
                    mkdir($target_dir, 0777, true);
                }
                
                $target_file = $target_dir . basename($_FILES["upload"]["name"]);
                
                // VULNERABILIDAD: No validación de tipo de archivo
                if (move_uploaded_file($_FILES["upload"]["tmp_name"], $target_file)) {
                    echo "<p style='color: green;'>Archivo subido: " . basename($_FILES["upload"]["name"]) . "</p>";
                }
            }
            ?>
        </div>

        <div class="form-box">
            <h3>Inclusión de Archivos Vulnerable (LFI)</h3>
            <p><a href="?page=../../../etc/passwd">Ver /etc/passwd</a></p>
            <p><a href="?page=../../../var/log/apache2/access.log">Ver logs Apache</a></p>

            <?php
            if (isset($_GET['page'])) {
                $page = $_GET['page'];
                // VULNERABILIDAD: Local File Inclusion
                echo "<h4>Contenido de: $page</h4>";
                echo "<pre>" . htmlspecialchars(file_get_contents($page)) . "</pre>";
            }
            ?>
        </div>

        <h3>📚 Vulnerabilidades Incluidas:</h3>
        <ul>
            <li>SQL Injection en formulario de login</li>
            <li>XSS Reflejado en búsqueda</li>
            <li>Upload de archivos sin validación</li>
            <li>Local File Inclusion (LFI)</li>
            <li>Información sensible expuesta</li>
        </ul>
    </div>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/html/vulnerable-app
chmod -R 755 /var/www/html/vulnerable-app

echo "Aplicaciones vulnerables instaladas:"
echo "- DVWA: http://192.168.56.10/dvwa"
echo "- App personalizada: http://192.168.56.10/vulnerable-app"