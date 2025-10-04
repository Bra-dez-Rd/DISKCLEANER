@echo off
start compmgmt.msc
start perfmon.msc
:: Comprobando si el script se está ejecutando como Administrador
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo Requiriendo permisos de administrador...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

echo Reparando y limpiando el disco local C:
echo ===================================
echo 1. Ejecutando CHKDSK...
chkdsk C: /f /r 
echo ===================================
echo 2. Ejecutando SFC (System File Checker) para reparar archivos del sistema...
sfc /scannow
if %errorlevel% neq 0 (
    echo "El comando SFC no pudo completar correctamente, es posible que requiera permisos elevados o que haya algún problema con los archivos de sistema."
)
echo ===================================
echo 3. Ejecutando DISM para reparar la imagen de Windows...
DISM /Online /Cleanup-Image /ScanHealth
DISM /Online /Cleanup-Image /RestoreHealth
if %errorlevel% neq 0 (
    echo "El comando DISM no pudo completar correctamente."
)
echo ===================================
echo 4. Eliminando archivos temporales...
del /q/f/s %TEMP%\*
del /q/f/s C:\Windows\Temp\*
del /q/f/s C:\Windows\Prefetch\*
echo ===================================
echo 5. Eliminando puntos de restauración antiguos...
vssadmin delete shadows /for=C: /oldest
echo ===================================
echo 6. Ejecutando desfragmentación del disco...
defrag C: /O
echo Desfragmentación completada.
echo ===================================
echo 7. Liberando espacio en el disco...
cleanmgr /sagerun:1
echo Liberación de espacio completada.
echo ===================================
echo 8. Eliminando aplicaciones del inicio automático...

:: Eliminando entradas del registro que inician aplicaciones automáticamente
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /f
reg delete HKLM\Software\Microsoft\Windows\CurrentVersion\Run /f

:: Eliminando accesos directos de la carpeta de Inicio del usuario
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\*"

:: Eliminando accesos directos de la carpeta de Inicio común para todos los usuarios
del /f /q "%programdata%\Microsoft\Windows\Start Menu\Programs\Startup\*"
echo Aplicaciones de inicio eliminadas.
echo ===================================
echo 9. Reiniciando servicios de optimización del disco...
net stop defragsvc
net start defragsvc
echo ===================================
echo Siguenos en Instagram para más scripts: @bradez__rd
start https://www.instagram.com/bradez__rd/
echo [OK] Navegador lanzado correctamente.
echo Reparación y mantenimiento completados.
pause
