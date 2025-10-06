#!/bin/bash
# Script para generar checksums SHA256 de las OVAs y actualizar documentación

echo "============================================="
echo "Generando checksums SHA256 de archivos OVA"
echo "============================================="

# Directorio donde están las OVAs
OVA_DIR="/home/dani/sad/docs/laboratorio-sad/vagrant"
DOCS_DIR="/home/dani/sad/docs/laboratorio-sad/documentacion"

cd "$OVA_DIR" || exit 1

# Verificar que existen archivos OVA
if ! ls *.ova >/dev/null 2>&1; then
    echo "❌ No se encontraron archivos .ova en $OVA_DIR"
    echo "💡 Ejecuta primero: ./deploy-lab.sh export"
    exit 1
fi

echo "📁 Archivos OVA encontrados:"
ls -lh *.ova

echo ""
echo "🔢 Calculando checksums SHA256..."

# Generar checksums en formato legible
{
    echo "# Checksums SHA256 - Laboratorio SAD"
    echo "# Generado: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# ========================================"
    echo ""
    
    for ova in *.ova; do
        if [[ -f "$ova" ]]; then
            echo "## $ova"
            checksum=$(sha256sum "$ova" | cut -d' ' -f1)
            size=$(ls -lh "$ova" | awk '{print $5}')
            echo "**SHA256:** \`$checksum\`"
            echo "**Tamaño:** $size"
            echo ""
        fi
    done
} > checksums-report.md

# Generar también formato tradicional
sha256sum *.ova > checksums.sha256

echo "✅ Checksums generados:"
echo "  📄 checksums-report.md (formato Markdown)"
echo "  📄 checksums.sha256 (formato tradicional)"

echo ""
echo "📋 Resumen de checksums:"
cat checksums.sha256

echo ""
echo "🔧 Para verificar un archivo:"
echo "  sha256sum -c checksums.sha256"

echo ""
echo "📝 Contenido para documentación:"
echo "============================================="
cat checksums-report.md