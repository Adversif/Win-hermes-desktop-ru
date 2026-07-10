"""Build single-file uninstall-ru.bat — uses embedded PowerShell.

Just delete the patcher.bat -> 1 click.
Full revert Russian -> this .bat removes ru.* files, reverts to last backup,
disables Task Scheduler auto-patch, and rebuilds Hermes.
"""
import os, base64, zipfile, subprocess, time, json

WS = r'C:\Users\adversif\.mavis\sessions\mvs_81feacf1a17a4ff7b8c329c165b9e71d\workspace'
BUILD = os.path.join(WS, 'uninstaller-build')
OUT_BAT = os.path.join(WS, 'releases', 'Hermes-Desktop-0.17.3-ru-uninstaller.bat')
os.makedirs(os.path.dirname(OUT_BAT), exist_ok=True)
if os.path.exists(OUT_BAT):
    os.remove(OUT_BAT)
os.makedirs(BUILD, exist_ok=True)

# Bundle a small PS1 with the full uninstall logic (replaces the .ts files,
# unschedules the Task Scheduler job, rebuilds Hermes, then deletes the
# patcher copies of files it tracks).
uninstall_ps1 = r'''# Hermes Desktop Russian Locale Uninstaller
$ErrorActionPreference = 'Stop'
$homedir = Join-Path $env:LOCALAPPDATA 'hermes\hermes-agent'
if (-not (Test-Path $homedir)) {
  Write-Host "[FAIL] Hermes not found at $homedir" -ForegroundColor Red
  exit 1
}
Write-Host "Hermes: $homedir" -ForegroundColor Cyan

# 1) Remove auto-patch task
$tn = 'Hermes Desktop RU Auto-Patch'
$existed = $null
try { $existed = Get-ScheduledTask -TaskName $tn -ErrorAction Stop } catch {}
if ($existed) {
  Unregister-ScheduledTask -TaskName $tn -Confirm:$false | Out-Null
  Write-Host '[OK] Unregistered scheduled task' -ForegroundColor Green
} else {
  Write-Host '[OK] No scheduled task to remove'
}

# 2) Revert .ts / .tsx files from last backup (if exists)
$marker = Join-Path $homedir '.ru-last-backup'
if (Test-Path $marker) {
  $backup = Get-Content $marker -Raw -Encoding UTF8
  if (Test-Path $backup) {
    Write-Host "[OK] Restoring from backup: $backup"
    Get-ChildItem -Path $backup -Recurse -File | ForEach-Object {
      $rel = $_.FullName.Substring($backup.Length).TrimStart('\','/')
      $dst = Join-Path $homedir $rel
      if (Test-Path $dst) {
        Copy-Item $_.FullName $dst -Force
      }
    }
  }
}

# 3) Remove ru.* files added by patcher
$ruFiles = @(
  'apps\desktop\src\i18n\ru.ts',
  'apps\desktop\src\app\settings\ru-constants.ts'
)
foreach ($r in $ruFiles) {
  $p = Join-Path $homedir $r
  if (Test-Path $p) { Remove-Item -Force $p; Write-Host "[OK] Removed $r" -ForegroundColor Green }
}

# 4) Remove .ru-backup-* dirs
Get-ChildItem -Path (Join-Path $homedir '.ru-backup-*') -ErrorAction SilentlyContinue |
  ForEach-Object { Remove-Item -Recurse -Force $_.FullName; Write-Host "[OK] Removed $($_.Name)" -ForegroundColor Green }
if (Test-Path $marker) { Remove-Item -Force $marker }

# 5) Rebuild Hermes
Write-Host ''
Write-Host 'Rebuilding Hermes (this may take 2-3 minutes)...' -ForegroundColor Cyan
$pack = Join-Path $homedir 'apps\desktop'
Push-Location $pack
try {
  $p = Start-Process -FilePath 'cmd.exe' -ArgumentList '/c','npm run pack' -Wait -PassThru -NoNewWindow
  if ($p.ExitCode -ne 0) {
    Write-Host "[FAIL] npm run pack exited with code $($p.ExitCode)" -ForegroundColor Red
    Write-Host '        You can rebuild manually later from Hermes settings.' -ForegroundColor Yellow
  } else {
    Write-Host '[OK] Hermes rebuilt successfully' -ForegroundColor Green
  }
} finally { Pop-Location }

Write-Host ''
Write-Host '[DONE] Russian locale removed.' -ForegroundColor Green
Write-Host '       You can also run the official Nous Research Hermes installer for a fully clean state.'
'''

ps1_path = os.path.join(BUILD, 'uninstall-ru.ps1')
with open(ps1_path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(uninstall_ps1)

# Encode
with open(ps1_path, 'rb') as f:
    ps_b64 = base64.b64encode(f.read()).decode('ascii')

# Generate the .bat — header (PowerShell self-extract) + b64 + footer
b64_lines = []
for i in range(0, len(ps_b64), 76):
    b64_lines.append(ps_b64[i:i+76])

header = '''@echo off
setlocal
rem ====================================================================
rem  Hermes Desktop Russian Locale UNINSTALLER v0.17.3
rem  Removes Russian patches + disables auto-patch + rebuilds Hermes.
rem  Self-contained ~16 KB. Just double-click to run.
rem ====================================================================

echo.
echo ============================================================
echo  Hermes Desktop Russian Locale Uninstaller v0.17.3
echo ============================================================
echo  This will:
echo    1. Disable the auto-patch scheduled task
echo    2. Restore patched files from backup (if any)
echo    3. Delete ru.ts / ru-constants.ts
echo    4. Rebuild Hermes
echo.
set /p "CONFIRM=Continue? (Y/N): "
if /i not "%CONFIRM%"=="Y" exit /b

set "BAT_PATH=%~f0"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$myPath = $env:BAT_PATH;" ^
  "$raw = [IO.File]::ReadAllText($myPath);" ^
  "$m = [regex]::Match($raw, '(?ms)@@@PAYLOAD@@@\\r?\\n(.*?)\\r?\\n@@@/PAYLOAD@@@');" ^
  "if (-not $m.Success) { throw 'Payload markers not found in script.' };" ^
  "$b64 = $m.Groups[1].Value -replace '\\s','';" ^
  "$tmp = Join-Path $env:TEMP ('hermes_uninst_' + [guid]::NewGuid() + '.ps1');" ^
  "try {" ^
  "  [IO.File]::WriteAllBytes($tmp, [Convert]::FromBase64String($b64));" ^
  "  $p = Start-Process -FilePath 'powershell' -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',$tmp -Wait -PassThru -NoNewWindow;" ^
  "  exit $p.ExitCode" ^
  "} finally { Remove-Item $tmp -ErrorAction SilentlyContinue }"

set RC=%errorlevel%
echo.
if %RC% == 0 (
  echo  [OK] Uninstaller finished.
) else (
  echo  [FAIL] Uninstaller exited with code %RC%.
)
echo.
pause
endlocal
exit /b %RC%

@@@PAYLOAD@@@
'''
footer = '\n@@@/PAYLOAD@@@\n'

with open(OUT_BAT, 'w', encoding='utf-8', newline='') as f:
    f.write(header)
    f.write('\n'.join(b64_lines))
    f.write(footer)

print(f'Built: {OUT_BAT} ({os.path.getsize(OUT_BAT)/1024:.1f} KB)')

# Smoke-test
print('Smoke testing...')
import tempfile
r = subprocess.run(
    ['cmd.exe', '/c', OUT_BAT],
    input='Y\n', capture_output=True, text=True,
    timeout=600, encoding='cp1251', errors='replace',
    cwd=os.path.dirname(OUT_BAT)
)
print(f'\nrc={r.returncode}, elapsed={time.time()-time.time():.0f}s')
print('--- STDOUT (last 3500) ---')
print(r.stdout[-3500:])
if r.stderr:
    print('--- STDERR (last 800) ---')
    print(r.stderr[-800:])
