<#
.SYNOPSIS
    Удаляет русский перевод из Hermes Agent Desktop на Windows 11
    и отменяет регистрацию авто-обновления в Task Scheduler.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
#>

$ErrorActionPreference = 'Stop'

function Log([string]$msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn([string]$msg)  { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Err([string]$msg)   { Write-Host "[FAIL] $msg" -ForegroundColor Red; throw $msg }

function Find-HermesDir {
    $candidates = @(
        "$env:LOCALAPPDATA\hermes\hermes-agent",
        "$env:USERPROFILE\.hermes\hermes-agent",
        "$env:USERPROFILE\hermes-agent"
    )
    foreach ($d in $candidates) {
        if (Test-Path "$d\apps\desktop\src\i18n") { return $d }
    }
    return $null
}

Write-Host ""
Write-Host "Hermes Desktop Russian Locale Uninstaller (Windows)" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

$Hd = Find-HermesDir
if (-not $Hd) {
    Err "Hermes Agent не найден. Нечего удалять."
}
Log "Hermes найден: $Hd"

# Снять задачу авто-обновления
$taskName = "Hermes Desktop RU Auto-Patch"
$existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ($existing) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false | Out-Null
    Log "Авто-обновление снято: $taskName"
} else {
    Warn "Задача авто-обновления не найдена (пропускаем)."
}

# Восстановить из последнего бэкапа
$markerFile = Join-Path $Hd ".ru-last-backup"
if (Test-Path $markerFile) {
    $backupDir = Get-Content $markerFile -Encoding UTF8
    if (Test-Path $backupDir) {
        Log "Восстановление из бэкапа: $backupDir"
        Get-ChildItem -Path $backupDir -Recurse -File -Filter "*.ts*" | ForEach-Object {
            $rel = $_.FullName.Substring($backupDir.Length).TrimStart('\', '/')
            $target = Join-Path $Hd $rel
            if (Test-Path $target) {
                Copy-Item -Path $_.FullName -Destination $target -Force
            }
        }
        Log "Файлы восстановлены"
    } else {
        Warn "Бэкап-каталог $backupDir не существует, пропускаем восстановление."
    }
} else {
    Warn "Маркер .ru-last-backup не найден (ничего не было забэкаплено)."
}

# Удалить ru-файлы
$ruFile1 = Join-Path $Hd "apps\desktop\src\i18n\ru.ts"
$ruFile2 = Join-Path $Hd "apps\desktop\src\app\settings\ru-constants.ts"
foreach ($f in @($ruFile1, $ruFile2)) {
    if (Test-Path $f) { Remove-Item -Force $f }
}
if (Test-Path $markerFile) { Remove-Item -Force $markerFile }

# Удалить старые бэкапы
$backupGlob = Join-Path $Hd ".ru-backup-*"
Get-ChildItem -Path $backupGlob -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force

Log "Файлы русского перевода удалены"

# Пересборка
Log "Пересборка Hermes (несколько минут)..."
Push-Location (Join-Path $Hd "apps\desktop")
try {
    npm run pack 2>&1 | Select-Object -Last 5
    if ($LASTEXITCODE -ne 0) {
        Warn ("Сборка не удалась (см. лог выше). Hermes может не запуститься — запустите 'npm run pack' вручную в " + $Hd + "\apps\desktop.")
    } else {
        Log "Сборка завершена"
    }
} finally {
    Pop-Location
}

Write-Host ""
Log "Готово! Hermes восстановлен в оригинальное состояние."
Write-Host ""
