# Script para inicializar la base de datos MySQL

# Configuración
$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"  # Ajusta esta ruta según tu instalación
$mysqlUser = "root"
$mysqlPassword = "dani"  # Usa la contraseña que configuraste
$databaseName = "gestor_horarios"

# Comando para ejecutar MySQL
$mysqlCmd = "$mysqlPath -u $mysqlUser -p$mysqlPassword"

# Comandos SQL a ejecutar
$sqlCommands = @"
-- Eliminar la base de datos si existe
DROP DATABASE IF EXISTS $databaseName;

-- Crear la base de datos con la configuración correcta de caracteres
CREATE DATABASE $databaseName 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE $databaseName;
"@

# Ejecutar los comandos SQL
try {
    # Ejecutar comandos para crear la base de datos
    $sqlCommands | & $mysqlPath -u $mysqlUser -p$mysqlPassword --execute="$sqlCommands"
    
    Write-Host "Base de datos '$databaseName' creada exitosamente." -ForegroundColor Green
    
    # Aplicar el esquema SQL
    $schemaFile = "$PSScriptRoot\src\main\resources\schema.sql"
    if (Test-Path $schemaFile) {
        Write-Host "Aplicando esquema desde: $schemaFile" -ForegroundColor Cyan
        & $mysqlPath -u $mysqlUser -p$mysqlPassword $databaseName < $schemaFile
        Write-Host "Esquema aplicado exitosamente." -ForegroundColor Green
        
        # Mostrar las tablas creadas
        Write-Host "`nTablas en la base de datos:" -ForegroundColor Cyan
        & $mysqlPath -u $mysqlUser -p$mysqlPassword --execute="USE $databaseName; SHOW TABLES;"
    } else {
        Write-Host "Error: No se encontró el archivo de esquema en $schemaFile" -ForegroundColor Red
    }
} catch {
    Write-Host "Error al ejecutar los comandos SQL: $_" -ForegroundColor Red
}

# Pausar para ver los resultados
Write-Host "`nPresiona cualquier tecla para continuar..." -NoNewline
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
