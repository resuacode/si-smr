# Ejercicios Prácticos por Módulos

## 📚 Módulo 2: Clasificación de la Información y Análisis de Riesgos

### Ejercicio 2.1: Inventario y Clasificación de Activos
**Duración:** 90 minutos  
**Dificultad:** Básica

**Objetivo:** Identificar y clasificar los activos de información del laboratorio según su criticidad.

**Máquinas necesarias:**
- Ubuntu Server (192.168.56.10)
- Storage/Backup (192.168.56.13)
- Kali Linux (192.168.56.20)

**Pasos:**
1. **Reconocimiento inicial**
   ```bash
   # Desde Kali Linux
   nmap -sV -sC 192.168.56.10-13
   ```

2. **Identificación de servicios**
   - Acceder a cada servidor
   - Listar servicios ejecutándose
   - Identificar bases de datos, archivos compartidos, aplicaciones web

3. **Clasificación de activos**
   - Crear matriz de activos con niveles: Público, Interno, Confidencial, Restringido
   - Evaluar impacto por pérdida de: Confidencialidad, Integridad, Disponibilidad

4. **Documentación**
   - Completar inventario en plantilla proporcionada
   - Justificar clasificación asignada

**Entregables:**
- Inventario de activos del laboratorio
- Matriz de clasificación CIA
- Informe de hallazgos

### Ejercicio 2.2: Análisis de Vulnerabilidades Básico
**Duración:** 120 minutos  
**Dificultad:** Intermedia

**Objetivo:** Realizar análisis de vulnerabilidades y evaluar riesgos asociados.

**Herramientas:**
- Nmap, Nikto, OpenVAS (desde Kali)
- Navegador web para aplicaciones

**Procedimiento:**
1. **Escaneo de vulnerabilidades**
   ```bash
   # Escaneo completo de puertos
   nmap -sV -sC --script=vuln 192.168.56.10

   # Análisis web
   nikto -h http://192.168.56.10
   
   # Análisis de servicios SMB
   enum4linux 192.168.56.13
   ```

2. **Análisis de aplicaciones web**
   - Acceder a http://192.168.56.10 y http://192.168.56.11
   - Revisar código fuente
   - Probar formularios y parámetros

3. **Evaluación de riesgos**
   - Calcular riesgo: Impacto × Probabilidad
   - Priorizar vulnerabilidades encontradas
   - Proponer medidas de mitigación

**Entregables:**
- Reporte de vulnerabilidades
- Matriz de riesgos
- Plan de mitigación priorizado

---

## 🔐 Módulo 3: Criptografía y Certificados Digitales

### Ejercicio 3.1: Implementación de Cifrado Simétrico y Asimétrico
**Duración:** 100 minutos  
**Dificultad:** Intermedia

**Objetivo:** Implementar diferentes tipos de cifrado y analizar su seguridad.

**Máquinas:**
- Ubuntu Server (para implementación)
- Kali Linux (para análisis)

**Actividades:**

1. **Cifrado simétrico**
   ```bash
   # En Ubuntu Server
   # Cifrar archivo con AES
   openssl enc -aes-256-cbc -salt -in documento.txt -out documento.enc
   
   # Descifrar
   openssl enc -aes-256-cbc -d -in documento.enc -out documento_desc.txt
   ```

2. **Cifrado asimétrico**
   ```bash
   # Generar par de claves RSA
   openssl genrsa -out private.pem 2048
   openssl rsa -in private.pem -pubout -out public.pem
   
   # Cifrar con clave pública
   openssl rsautl -encrypt -inkey public.pem -pubin -in mensaje.txt -out mensaje.enc
   
   # Descifrar con clave privada
   openssl rsautl -decrypt -inkey private.pem -in mensaje.enc -out mensaje_desc.txt
   ```

3. **Análisis de fortaleza**
   - Comparar tiempos de cifrado
   - Analizar tamaños de archivos
   - Evaluar robustez de passwords

**Entregables:**
- Archivos cifrados con diferentes algoritmos
- Análisis comparativo de métodos
- Recomendaciones de uso

### Ejercicio 3.2: Certificados Digitales y PKI
**Duración:** 120 minutos  
**Dificultad:** Avanzada

**Objetivo:** Configurar una infraestructura PKI básica y gestionar certificados.

**Procedimiento:**
1. **Crear CA (Certificate Authority)**
   ```bash
   # Generar clave privada de CA
   openssl genrsa -out ca-key.pem 4096
   
   # Crear certificado autofirmado de CA
   openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
   ```

2. **Generar certificados de servidor**
   ```bash
   # Clave privada del servidor
   openssl genrsa -out server-key.pem 4096
   
   # CSR (Certificate Signing Request)
   openssl req -subj "/CN=server.lab.local" -sha256 -new -key server-key.pem -out server.csr
   
   # Firmar CSR con CA
   openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -out server-cert.pem -CAcreateserial
   ```

3. **Implementar HTTPS**
   - Configurar Apache con SSL
   - Instalar certificados
   - Verificar conexión segura

**Entregables:**
- Estructura PKI funcional
- Certificados generados
- Servidor web con HTTPS operativo

---

## 🛡️ Módulo 4: Sistemas de Autenticación y Control de Acceso

### Ejercicio 4.1: Configuración de Autenticación Multifactor
**Duración:** 90 minutos  
**Dificultad:** Intermedia

**Objetivo:** Implementar sistemas de autenticación robustos.

**Componentes:**
1. **Configurar SSH con autenticación por clave**
   ```bash
   # En Ubuntu Server
   # Generar par de claves en cliente
   ssh-keygen -t rsa -b 4096
   
   # Copiar clave pública al servidor
   ssh-copy-id admin@192.168.56.10
   
   # Configurar SSH para deshabilitar password
   sudo nano /etc/ssh/sshd_config
   # PasswordAuthentication no
   sudo systemctl restart ssh
   ```

2. **Implementar Google Authenticator (2FA)**
   ```bash
   # Instalar Google Authenticator
   sudo apt-get install libpam-google-authenticator
   
   # Configurar para usuario
   google-authenticator
   
   # Modificar PAM
   sudo nano /etc/pam.d/sshd
   # auth required pam_google_authenticator.so
   ```

3. **Pruebas de seguridad**
   - Intentos de login con credenciales incorrectas
   - Verificar logs de autenticación
   - Probar bypass de autenticación

### Ejercicio 4.2: Control de Acceso Basado en Roles
**Duración:** 100 minutos  
**Dificultad:** Avanzada

**Objetivo:** Implementar RBAC (Role-Based Access Control) en el sistema.

**Implementación:**
1. **Crear estructura de usuarios y grupos**
   ```bash
   # Crear grupos por roles
   sudo groupadd administradores
   sudo groupadd operadores
   sudo groupadd auditores
   sudo groupadd invitados
   
   # Crear usuarios
   sudo useradd -m -G administradores alice
   sudo useradd -m -G operadores bob
   sudo useradd -m -G auditores charlie
   sudo useradd -m -G invitados david
   ```

2. **Configurar permisos por directorio**
   ```bash
   # Estructura de directorios
   sudo mkdir -p /data/{admin,operations,audit,public}
   
   # Asignar permisos
   sudo chgrp administradores /data/admin
   sudo chmod 750 /data/admin
   
   sudo chgrp operadores /data/operations
   sudo chmod 750 /data/operations
   
   sudo chgrp auditores /data/audit
   sudo chmod 750 /data/audit
   
   sudo chmod 755 /data/public
   ```

3. **Implementar sudo granular**
   ```bash
   # Configurar sudoers
   sudo visudo
   
   # Ejemplos de reglas:
   # %administradores ALL=(ALL:ALL) ALL
   # %operadores ALL=(ALL) /bin/systemctl restart apache2, /bin/systemctl status *
   # %auditores ALL=(ALL) /bin/cat /var/log/*, /usr/bin/tail /var/log/*
   ```

**Entregables:**
- Sistema RBAC funcional
- Documentación de roles y permisos
- Pruebas de acceso por rol

---

## 🔍 Módulo 5: Auditoría y Monitoreo de Sistemas

### Ejercicio 5.1: Configuración de Auditoría del Sistema
**Duración:** 120 minutos  
**Dificultad:** Intermedia

**Objetivo:** Implementar sistema de auditoría completo con auditd.

**Configuración:**
1. **Instalar y configurar auditd**
   ```bash
   # Instalar auditd
   sudo apt-get install auditd audispd-plugins
   
   # Configurar reglas de auditoría
   sudo nano /etc/audit/rules.d/audit.rules
   ```

2. **Reglas de auditoría específicas**
   ```bash
   # Monitorear accesos a archivos sensibles
   -w /etc/passwd -p wa -k passwd_changes
   -w /etc/shadow -p wa -k shadow_changes
   -w /etc/group -p wa -k group_changes
   -w /etc/sudoers -p wa -k sudoers_changes
   
   # Monitorear comandos privilegiados
   -a always,exit -F arch=b64 -S execve -F euid=0 -k privileged_commands
   
   # Monitorear accesos de red
   -a always,exit -F arch=b64 -S socket -k network_access
   ```

3. **Análisis de logs**
   ```bash
   # Búsqueda de eventos específicos
   ausearch -k passwd_changes
   ausearch -k privileged_commands
   
   # Generar reportes
   aureport --summary
   aureport --login
   aureport --executable
   ```

### Ejercicio 5.2: Monitoreo en Tiempo Real
**Duración:** 100 minutos  
**Dificultad:** Avanzada

**Objetivo:** Implementar monitoreo en tiempo real de seguridad.

**Herramientas:**
1. **Configurar OSSEC/Wazuh**
   ```bash
   # Instalar Wazuh agent
   curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
   echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
   sudo apt-get update
   sudo apt-get install wazuh-agent
   ```

2. **Configurar reglas personalizadas**
   ```xml
   <!-- Detectar intentos de login fallidos -->
   <rule id="100001" level="5">
     <if_matched_sid>5716</if_matched_sid>
     <match>authentication failure</match>
     <description>Multiple authentication failures</description>
   </rule>
   ```

3. **Dashboard y alertas**
   - Configurar Kibana/Grafana
   - Crear dashboards de seguridad
   - Configurar alertas por email/Slack

**Entregables:**
- Sistema de auditoría configurado
- Dashboard de monitoreo funcional
- Reportes de eventos de seguridad

---

## 🕵️ Módulo 6: Análisis Forense Digital

### Ejercicio 6.1: Análisis Forense de Sistema de Archivos
**Duración:** 150 minutos  
**Dificultad:** Avanzada

**Objetivo:** Realizar análisis forense completo de un sistema comprometido.

**Escenario:** Se sospecha que el servidor Ubuntu ha sido comprometido. Realizar investigación forense.

**Procedimiento:**
1. **Adquisición de evidencia**
   ```bash
   # Crear imagen forense
   sudo dd if=/dev/sda of=/evidence/server_image.dd bs=4096 conv=noerror,sync
   
   # Calcular hash para integridad
   sha256sum /evidence/server_image.dd > /evidence/server_image.sha256
   ```

2. **Análisis del sistema de archivos**
   ```bash
   # Montar imagen en modo solo lectura
   sudo mount -o ro,loop /evidence/server_image.dd /mnt/forensics/
   
   # Buscar archivos modificados recientemente
   find /mnt/forensics -type f -mtime -7 -ls
   
   # Análisis de logs
   grep -r "authentication failure" /mnt/forensics/var/log/
   ```

3. **Análisis de memoria y procesos**
   ```bash
   # Capturar memoria (si es posible)
   sudo dd if=/proc/kcore of=/evidence/memory.dump
   
   # Análizar procesos sospechosos
   ps aux --sort=-%cpu | head -20
   netstat -tuln | grep LISTEN
   ```

4. **Línea de tiempo forense**
   - Crear timeline de eventos
   - Correlacionar logs de diferentes fuentes
   - Identificar momento del compromiso

### Ejercicio 6.2: Análisis de Tráfico de Red
**Duración:** 120 minutos  
**Dificultad:** Intermedia

**Objetivo:** Analizar tráfico de red para detectar actividad maliciosa.

**Herramientas:** Wireshark, tcpdump, tshark

**Actividades:**
1. **Captura de tráfico**
   ```bash
   # Capturar tráfico en tiempo real
   sudo tcpdump -i eth0 -w /tmp/capture.pcap
   
   # Captura específica (HTTP)
   sudo tcpdump -i eth0 'port 80' -w /tmp/http_traffic.pcap
   ```

2. **Análisis con Wireshark**
   - Filtrar tráfico sospechoso
   - Identificar conexiones anómalas
   - Extraer archivos transmitidos
   - Analizar protocolos

3. **Búsqueda de IOCs (Indicators of Compromise)**
   ```bash
   # Buscar patrones maliciosos
   tshark -r capture.pcap -Y "http contains \"malware\""
   tshark -r capture.pcap -Y "dns.qry.name contains \"suspicious\""
   ```

**Entregables:**
- Imagen forense del sistema
- Reporte de análisis forense
- Timeline de eventos
- Análisis de tráfico de red
- Recomendaciones de remediación

---

## 📋 Evaluación y Rúbricas

### Criterios de Evaluación Generales

**Técnica (40%)**
- Correcta ejecución de procedimientos
- Uso apropiado de herramientas
- Calidad de la implementación

**Análisis (30%)**
- Profundidad del análisis realizado
- Identificación de vulnerabilidades/evidencias
- Correlación de información

**Documentación (20%)**
- Claridad y completitud de informes
- Evidencias y capturas de pantalla
- Metodología documentada

**Seguridad (10%)**
- Consideraciones éticas
- Preservación de evidencias
- Buenas prácticas de seguridad

### Matriz de Calificación

| Criterio | Excelente (9-10) | Bueno (7-8) | Satisfactorio (5-6) | Insuficiente (0-4) |
|----------|------------------|-------------|---------------------|-------------------|
| **Ejecución** | Procedimientos ejecutados perfectamente, sin errores | Procedimientos ejecutados correctamente con errores menores | Procedimientos ejecutados con algunos errores significativos | Procedimientos no ejecutados o con errores graves |
| **Análisis** | Análisis profundo y exhaustivo, insights valiosos | Análisis correcto y completo | Análisis básico pero correcto | Análisis superficial o incorrecto |
| **Documentación** | Documentación profesional, clara y completa | Documentación buena con detalles menores faltantes | Documentación básica pero comprensible | Documentación deficiente o incompleta |

Cada módulo incluye ejercicios progresivos que permiten a los estudiantes desarrollar habilidades prácticas mientras aplican los conocimientos teóricos en un entorno controlado y realista.
