@echo off
setlocal EnableExtensions

rem === EDIT THESE FOUR LINES ===
set "CONFIG_SOURCE=https://raw.githubusercontent.com/GamingBears/ValexUpdater/refs/heads/main/config.json"
set "INSTALL_FOLDER=ValexCracked"
set "UPDATER_CONFIG_SOURCE=https://raw.githubusercontent.com/GamingBears/ValexUpdater/refs/heads/main/updater-config.json"
set "UPDATER_VERSION=1.0.1"
rem =============================

set "SCRIPT_DIR=%~dp0"

rem --- Self-update check ---
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$src = '%UPDATER_CONFIG_SOURCE%';" ^
  "$currentVersion = '%UPDATER_VERSION%';" ^
  "$scriptDir = '%SCRIPT_DIR%';" ^
  "if ([string]::IsNullOrWhiteSpace($src)) { Write-Host '[UPDATER] No updater config URL set.'; exit 0 }" ^
  "Write-Host ('[UPDATER] Checking updater config: ' + $src);" ^
  "if ($src -match '^(http|https)://') {" ^
  "  try { $json = Invoke-WebRequest -UseBasicParsing -Uri $src | Select-Object -ExpandProperty Content } catch { Write-Host ('[UPDATER] Failed to download updater config: ' + $_.Exception.Message); exit 0 }" ^
  "} else {" ^
  "  if (-not (Test-Path -LiteralPath $src)) { Write-Host ('[UPDATER] Updater config not found: ' + $src); exit 0 }" ^
  "  $json = Get-Content -Raw -Encoding UTF8 -LiteralPath $src" ^
  "}" ^
  "try { $cfg = $json | ConvertFrom-Json } catch { Write-Host '[UPDATER] Invalid updater JSON.'; exit 0 }" ^
  "if (-not $cfg) { Write-Host '[UPDATER] Empty updater JSON.'; exit 0 }" ^
  "$latest = [string]$cfg.latestVersion; $url = [string]$cfg.updaterUrl;" ^
  "Write-Host ('[UPDATER] Current=' + $currentVersion + ' Latest=' + $latest);" ^
  "if ([string]::IsNullOrWhiteSpace($latest) -or [string]::IsNullOrWhiteSpace($url)) { Write-Host '[UPDATER] updater-config missing latestVersion or updaterUrl.'; exit 0 }" ^
  "if ($latest -ne $currentVersion) {" ^
  "  Write-Host ('[UPDATER] New version available: ' + $latest + ' (current ' + $currentVersion + ')');" ^
  "  $dest = Join-Path $scriptDir 'ValexExternalUpdater.new.bat';" ^
  "  Write-Host ('[UPDATER] Downloading latest updater to ' + $dest);" ^
  "  try { Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $dest } catch { Write-Host ('[UPDATER] Failed to download latest updater: ' + $_.Exception.Message); exit 0 }" ^
  "  Write-Host '[UPDATER] Ready to launch new updater in current window.';" ^
  "  exit 9" ^
  "} else {" ^
  "  Write-Host '[UPDATER] Updater is current.';" ^
  "  exit 0" ^
  "}"

set "RC=%ERRORLEVEL%"
if "%RC%"=="9" goto :SELF_UPDATED

echo ===============================
echo VALEX EXTERNAL CRACKED UPDATER
echo ===============================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$src = '%CONFIG_SOURCE%';" ^
  "$installDir = '%INSTALL_FOLDER%';" ^
  "New-Item -ItemType Directory -Force -Path $installDir | Out-Null;" ^
  "if ($src -match '^(http|https)://') {" ^
  "  $json = Invoke-WebRequest -UseBasicParsing -Uri $src | Select-Object -ExpandProperty Content" ^
  "} else {" ^
  "  if (-not (Test-Path -LiteralPath $src)) { throw \"Config not found: $src\" }" ^
  "  $json = Get-Content -Raw -Encoding UTF8 -LiteralPath $src" ^
  "}" ^
  "$cfg = $json | ConvertFrom-Json;" ^
  "if (-not $cfg) { throw 'Invalid JSON config' }" ^
  "if ($cfg.status) { Write-Host ('[STATUS] ' + $cfg.status) }" ^
  "$installer = [string]$cfg.installer;" ^
  "if ([string]::IsNullOrWhiteSpace($installer)) { throw \"Missing 'installer' in config\" }" ^
  "$fileName = if ($installer -match '^(http|https)://') { [IO.Path]::GetFileName([Uri]$installer) } else { [IO.Path]::GetFileName($installer) };" ^
  "if ([string]::IsNullOrWhiteSpace($fileName)) { $fileName = 'installer.exe' }" ^
  "$dest = Join-Path $installDir $fileName;" ^
  "if ($installer -match '^(http|https)://') {" ^
  "  Write-Host \"[INFO] Downloading from $installer...\";" ^
  "  Invoke-WebRequest -UseBasicParsing -Uri $installer -OutFile $dest" ^
  "} else {" ^
  "  if (-not (Test-Path -LiteralPath $installer)) { throw \"Installer not found: $installer\" }" ^
  "  Copy-Item -Force -LiteralPath $installer -Destination $dest" ^
  "}" ^
  "Write-Host '[INFO] Running installer...';" ^
  "Start-Process -FilePath $dest -Wait -PassThru | Out-Null;" ^
  "Write-Host '===============================';" ^
  "Write-Host '    New Version Installed!';" ^
  "Write-Host '===============================';"

echo.
pause

goto :EOF

:SELF_UPDATED
echo.
echo [UPDATER] Launching newer updater here so you can see its output...
call "%SCRIPT_DIR%ValexExternalUpdater.new.bat"
echo.
echo [UPDATER] New updater finished. Exiting this instance.
pause
exit /b