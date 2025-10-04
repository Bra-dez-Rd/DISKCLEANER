# DiskRepairer — Script de mantenimiento y reparación para Windows

> Autor: BRA DEZ
> Versión: 1.0  
> SO objetivo: Windows 10/11 (x64)

## Descripción
`DiskRepairer` es un script por lotes (`.bat`) para **mantenimiento preventivo** y **reparación básica** de Windows en el disco **C:**. Ejecuta una serie de utilidades nativas (sin software externo) para diagnosticar, reparar archivos del sistema, limpiar basura y optimizar el rendimiento. Ideal para equipos que llevan tiempo sin mantenimiento. Sí, es como llevar tu PC al spa… pero con CHKDSK.

## Qué hace (paso a paso)
1. **Abre herramientas de diagnóstico**: `compmgmt.msc` y `perfmon.msc` (vista rápida del sistema).
2. **Eleva a Administrador** si no lo está (re-lanza el script con `Start-Process -Verb runAs`).
3. **CHKDSK** a `C:` con corrección y recuperación: `chkdsk C: /f /r`.
4. **SFC (System File Checker)**: `sfc /scannow` para reparar archivos del sistema.
5. **DISM (imagen de Windows)**: `DISM /Online /Cleanup-Image /ScanHealth` + `... /RestoreHealth`.
6. **Limpieza de temporales**: borra `%TEMP%`, `C:\Windows\Temp\` y `C:\Windows\Prefetch\`.
7. **Borra puntos de restauración antiguos**: `vssadmin delete shadows /for=C: /oldest`.
8. **Desfragmenta / optimiza**: `defrag C: /O` (volúmenes HDD; en SSD no es desfragmentación clásica).
9. **Liberador de espacio**: `cleanmgr /sagerun:1` (requiere haber configurado `sageset` previamente; ver notas).
10. **Deshabilita aplicaciones de inicio** (⚠️ agresivo): elimina claves `Run` en HKCU y HKLM y accesos directos en *Startup* de usuario y *All Users*.
11. **Reinicia servicio de desfragmentación**: `defragsvc`.
12. **Pausa final** para ver resultados.

## Requisitos
- Windows 10/11 con consola **CMD**.
- **Permisos de Administrador**.
- Ejecutar en una **ventana de CMD** con privilegios elevados.
- Conexión a internet recomendada para DISM (puede requerir descarga de componentes).

## Advertencias importantes (léelas, de verdad)
- **Pérdida de configuraciones de inicio**: el script **elimina TODAS** las entradas de arranque automático (HKCU/HKLM `...\Run`) y accesos directos en las carpetas *Startup*. Si necesitas conservar algunas apps, edita el script antes de correrlo.
- **Puntos de restauración**: elimina sombras antiguas de volumen; podrías perder puntos de restauración previos.
- **CHKDSK /r** puede tardar bastante y requerir **reinicio** si el volumen está en uso.
- **SSD**: Windows gestiona TRIM/Optimize; `defrag /O` no “desfragmenta” como en HDD, pero ejecuta optimizaciones.
- **cleanmgr /sagerun:1** exige haber ejecutado una vez `cleanmgr /sageset:1` para definir qué limpiar.

## Uso
1. Haz **copia de seguridad** de tus datos. Sí, esto siempre va primero.
2. Abre **CMD como Administrador**.
3. Ejecuta:
   ```bat
   diskrepairer.bat
   ```
4. Sigue la salida en pantalla. Si CHKDSK pide **programar en reinicio**, acepta y reinicia cuando termine el lote.

### Logs esperados (ejemplo)
```
[INFO] Elevación: OK (modo Administrador)
[STEP 1] CHKDSK /f /r en C: iniciado...
[STEP 2] SFC /scannow ejecutándose...
[STEP 3] DISM ScanHealth + RestoreHealth en progreso...
[STEP 4] Limpieza de temporales...
[STEP 5] Eliminación de puntos de restauración antiguos (vssadmin)...
[STEP 6] Optimización (defrag /O)...
[STEP 7] Liberador de espacio (cleanmgr /sagerun:1)...
[STEP 8] Limpieza de inicio (HKCU/HKLM Run + carpetas Startup)...
[OK] Mantenimiento completado. Presiona una tecla para cerrar.
```

## Personalización (opcional)
- **Conservar apps de inicio**: elimina o comenta las líneas `reg delete ...\Run` y las `del ...\Startup\*` que no quieras aplicar.


## Estructura del script (resumen técnico)
- Elevación con `openfiles` + `Start-Process -Verb runAs`.
- Secuencia: CHKDSK → SFC → DISM → Limpieza temp → Borrado sombras → Defrag/Optimize → CleanMgr → Limpieza Startup → Reinicio `defragsvc`.
- Salida por `echo` para cada etapa (fácil de auditar).

## Palabras clave (SEO/documentación)
Windows, mantenimiento, reparación de disco, CHKDSK, SFC, DISM, defrag, optimización, limpieza de temporales, liberar espacio, cleanmgr, vssadmin, inicio automático, registro, HKCU, HKLM, Prefetch, Windows 10, Windows 11, administrador, batch, script .bat, automatización, rendimiento, solución de problemas.

## Licencia
Este proyecto se publica “tal cual”, sin garantías. Úsalo bajo tu propio riesgo. Puedes adaptarlo para uso personal o interno.

---