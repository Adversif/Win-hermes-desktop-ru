"""Build a single self-contained .bat file using PowerShell to extract.

Strategy: mark the payload with sentinel strings @@@PAYLOAD@@@...@@@/PAYLOAD@@@.
The .bat file is mostly PowerShell that:
  1. Reads itself
  2. Strips payload
  3. Decodes base64 -> zip
  4. Extracts zip -> temp
  5. Runs install-ru.cmd
"""
import os, base64, zipfile

WS = r'C:\Users\adversif\.mavis\sessions\mvs_81feacf1a17a4ff7b8c329c165b9e71d\workspace'
BUILD = os.path.join(WS, 'patcher-build')
OUT_BAT = os.path.join(WS, 'releases', 'Hermes-Desktop-0.17.3-ru-patcher.bat')
os.makedirs(os.path.dirname(OUT_BAT), exist_ok=True)
if os.path.exists(OUT_BAT):
    os.remove(OUT_BAT)

# Build a stage zip first
ZIP_PATH = os.path.join(BUILD, 'ru-patcher-stage.zip')
if os.path.exists(ZIP_PATH):
    os.remove(ZIP_PATH)

with zipfile.ZipFile(ZIP_PATH, 'w', zipfile.ZIP_DEFLATED) as zf:
    keep_root_files = {'apply-i18n-patches.py', 'install-ru.cmd', 'README-FIRST.txt'}
    keep_scripts_files = {'apply-i18n-patches.py', 'patch-components.py', 'patch-skills.py'}
    for root, dirs, files in os.walk(BUILD):
        rel_root = os.path.relpath(root, BUILD).replace('\\', '/')
        if rel_root == '.':
            keep = keep_root_files
            prefix = ''
        elif rel_root == 'scripts':
            keep = keep_scripts_files
            prefix = 'scripts/'
        elif rel_root == 'patches':
            keep = None
            prefix = 'patches/'
        else:
            continue
        for f in sorted(files):
            if keep and f not in keep:
                continue
            full = os.path.join(root, f)
            zf.write(full, prefix + f)

zip_size = os.path.getsize(ZIP_PATH)
print(f'Stage zip: {zip_size} bytes')

with open(ZIP_PATH, 'rb') as f:
    zip_b64 = base64.b64encode(f.read()).decode('ascii')
print(f'Base64: {len(zip_b64)} chars')

# Generate the .bat — header (PowerShell self-extract) + b64 + footer
b64_lines = []
for i in range(0, len(zip_b64), 76):
    b64_lines.append(zip_b64[i:i+76])

header = '''@echo off
setlocal
rem ====================================================================
rem  Hermes Desktop Russian Locale Patcher v0.17.3
rem  Self-contained: ~104 KB. Just double-click to run.
rem  Source: https://github.com/Adversif/Win-hermes-desktop-ru
rem  Idempotent: safe to re-run after Hermes updates.
rem ====================================================================

echo.
echo ============================================================
echo  Hermes Desktop Russian Locale Patcher v0.17.3
echo ============================================================
echo  Detecting Python...

where python >nul 2>&1
if errorlevel 1 (
  echo.
  echo  [NOT FOUND] Python 3.10+ not in PATH.
  echo  Install via:  winget install Python.Python.3.11
  echo  Or download:  https://www.python.org/downloads/
  echo.
  pause
  exit /b 1
)

echo  Python:  OK
echo  Hermes:  %LOCALAPPDATA%\\hermes\\hermes-agent
echo.
set /p "CONFIRM=Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" exit /b

echo.
echo  Extracting patcher...

set "BAT_PATH=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$myPath = $env:BAT_PATH;" ^
  "$raw = [IO.File]::ReadAllText($myPath);" ^
  "$m = [regex]::Match($raw, '(?ms)@@@PAYLOAD@@@\\r?\\n(.*?)\\r?\\n@@@/PAYLOAD@@@');" ^
  "if (-not $m.Success) { throw 'Payload markers not found in script.' };" ^
  "$b64 = $m.Groups[1].Value -replace '\\s','';" ^
  "$zipPath = Join-Path $env:TEMP ('hermes_ru_' + [guid]::NewGuid() + '.zip');" ^
  "$extractDir = Join-Path $env:TEMP ('hermes_ru_' + [guid]::NewGuid());" ^
  "try {" ^
  "  [IO.File]::WriteAllBytes($zipPath, [Convert]::FromBase64String($b64));" ^
  "  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir -Force;" ^
  "  $cmd = Join-Path $extractDir 'install-ru.cmd';" ^
  "  $p = Start-Process -FilePath $cmd -Wait -PassThru -NoNewWindow;" ^
  "  exit $p.ExitCode" ^
  "} finally {" ^
  "  Remove-Item $zipPath -ErrorAction SilentlyContinue;" ^
  "  Remove-Item $extractDir -Recurse -ErrorAction SilentlyContinue" ^
  "}"

set RC=%errorlevel%
echo.
if %RC% == 0 (
  echo  [OK] Russian patches applied.
  echo  Next step: rebuild Hermes. Either:
  echo    Option 1 - Prebuilt installer:
  echo       https://github.com/Adversif/Win-hermes-desktop-ru/releases/latest
  echo    Option 2 - Run install.ps1 from the full repo
) else (
  echo  [FAIL] Patcher exited with code %RC%.
)

echo.
pause
endlocal
exit /b %RC%

@@@PAYLOAD@@@
'''

footer = '''
@@@/PAYLOAD@@@
'''

with open(OUT_BAT, 'w', encoding='utf-8', newline='') as f:
    f.write(header)
    f.write('\n'.join(b64_lines))
    f.write(footer)

bat_size = os.path.getsize(OUT_BAT)
print(f'\nBAT: {OUT_BAT} ({bat_size/1024:.1f} KB, {bat_size/zip_size:.1f}x)')
