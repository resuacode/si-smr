#!/bin/bash
# Script para reparar VM storage-backup en emergency mode

echo "==========================================="
echo "Reparación de emergency mode - Storage VM"
echo "==========================================="

echo "1. Intentando acceso de emergencia..."
echo "   - NO introduzcas contraseña de root"
echo "   - Presiona Ctrl+D para continuar"
echo "   - O introduce: vagrant"

echo ""
echo "2. Una vez dentro, ejecuta estos comandos:"
echo ""
echo "# Verificar fstab problemático:"
echo "sudo cat /etc/fstab | grep sdc"
echo ""
echo "# Reparar fstab (eliminar línea problemática):"
echo "sudo sed -i '/sdc1/d' /etc/fstab"
echo ""
echo "# Agregar línea segura:"
echo "echo '/dev/sdc1 /backup ext4 defaults,nofail,x-systemd.device-timeout=10 0 2' | sudo tee -a /etc/fstab"
echo ""
echo "# Reiniciar:"
echo "sudo reboot"

echo ""
echo "==========================================="
echo "Alternativa: Recrear VM completamente"
echo "==========================================="
echo "cd /home/dani/sad/docs/laboratorio-sad/vagrant"
echo "vagrant destroy storage-backup -f"
echo "vagrant up storage-backup"