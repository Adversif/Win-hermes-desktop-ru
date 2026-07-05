<#
.SYNOPSIS
    Устанавливает русский язык в Hermes Agent Desktop на Windows 11.

.DESCRIPTION
    Зеркало install.sh для Windows: находит установку Hermes в %LOCALAPPDATA%\hermes,
    делает бэкап, накатывает патчи через Python, пересобирает приложение и
    регистрирует периодический auto-patch через Task Scheduler (аналог macOS LaunchAgent).

.PARAMETER Silent
    Пропустить интерактивные подтверждения (для auto-patch).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    git clone https://github.com/Adversif/Win-hermes-desktop-ru.git
    cd Win-hermes-desktop-ru
    powershell -ExecutionPolicy Bypass -File .\install.ps1
#>

[CmdletBinding()]
param(
    [switch]$Silent
)

$ErrorActionPreference = 'Stop'

# --- Цвета / логгеры ---
function Log([string]$msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn([string]$msg)  { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Err([string]$msg)   { Write-Host "[FAIL] $msg" -ForegroundColor Red; throw $msg }

# --- Расположение скрипта (репозиторий) ---
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }

# --- Поиск Python ---
function Find-Python {
    foreach ($cmd in @('python', 'python3', 'py')) {
        $found = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($found) {
            try {
                $ver = & $cmd --version 2>&1
                if ($LASTEXITCODE -eq 0) {
                    return @{ Cmd = $cmd; Version = ($ver -join ' ') }
                }
            } catch { }
        }
    }
    return $null
}

# --- Поиск Hermes ---
function Find-HermesDir {
    $candidates = @(
        "$env:LOCALAPPDATA\hermes\hermes-agent",
        "$env:USERPROFILE\.hermes\hermes-agent",
        "$env:USERPROFILE\hermes-agent",
        "$env:USERPROFILE\Dev\hermes-agent",
        "$env:USERPROFILE\projects\hermes-agent"
    )
    foreach ($d in $candidates) {
        if (Test-Path "$d\apps\desktop\src\i18n") {
            return $d
        }
    }

    # Через `hermes` в PATH
    $hermesBin = Get-Command hermes -ErrorAction SilentlyContinue
    if ($hermesBin) {
        try {
            $resolved = Resolve-Path -LiteralPath $hermesBin.Path -ErrorAction SilentlyContinue
            if ($resolved) {
                $candidate = Split-Path (Split-Path $resolved.Path -Parent) -Parent
                if (Test-Path "$candidate\apps\desktop\src\i18n") {
                    return $candidate
                }
            }
        } catch { }
    }

    return $null
}

# --- Бэкап ---
function Backup-Files {
    param([string]$hermesDir)

    $stamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupDir = Join-Path $hermesDir ".ru-backup-$stamp"
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

    $files = @(
        "apps\desktop\src\i18n\types.ts",
        "apps\desktop\src\i18n\languages.ts",
        "apps\desktop\src\i18n\catalog.ts",
        "apps\desktop\src\i18n\en.ts",
        "apps\desktop\src\i18n\zh.ts",
        "apps\desktop\src\app\settings\index.tsx",
        "apps\desktop\src\app\settings\config-settings.tsx",
        "apps\desktop\src\app\settings\keys-settings.tsx",
        "apps\desktop\src\app\settings\model-settings.tsx",
        "apps\desktop\src\app\settings\gateway-settings.tsx",
        "apps\desktop\src\app\settings\mcp-settings.tsx",
        "apps\desktop\src\app\settings\providers-settings.tsx",
        "apps\desktop\src\app\settings\sessions-settings.tsx",
        "apps\desktop\src\app\settings\toolset-config-panel.tsx",
        "apps\desktop\src\app\skills\index.tsx"
    )

    foreach ($f in $files) {
        $src = Join-Path $hermesDir $f
        if (Test-Path $src) {
            $dst = Join-Path $backupDir $f
            $dstDir = Split-Path $dst -Parent
            if (-not (Test-Path $dstDir)) {
                New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
            }
            Copy-Item -Path $src -Destination $dst -Force
        }
    }

    Log "Бэкап создан: $backupDir"
    $markerFile = Join-Path $hermesDir ".ru-last-backup"
    Set-Content -Path $markerFile -Value $backupDir -Encoding UTF8

    return $backupDir
}

# --- Применение патчей (через Python) ---
function Apply-Patches {
    param([string]$hermesDir, [string]$repoDir, [string]$pythonCmd)

    Log "Копирование файлов перевода..."
    $patchesDir = Join-Path $repoDir "patches"
    Copy-Item -Path (Join-Path $patchesDir "ru.ts") -Destination (Join-Path $hermesDir "apps\desktop\src\i18n\ru.ts") -Force
    Copy-Item -Path (Join-Path $patchesDir "ru-constants.ts") -Destination (Join-Path $hermesDir "apps\desktop\src\app\settings\ru-constants.ts") -Force

    Log "Запуск Python-применителя патчей..."
    $applyScript = Join-Path $repoDir "scripts\apply-i18n-patches.py"
    Set-Location $repoDir
    & $pythonCmd $applyScript $repoDir $hermesDir
    if ($LASTEXITCODE -ne 0) {
        Err "Python-применитель завершился с ошибкой. См. лог выше."
    }
}

# --- Сборка ---
function Build-App {
    param([string]$hermesDir)

    Log "Сборка приложения (это займёт несколько минут)..."
    Push-Location (Join-Path $hermesDir "apps\desktop")
    try {
        npm run pack 2>&1 | Select-Object -Last 8
        if ($LASTEXITCODE -ne 0) {
            Err ("Ошибка сборки. Откройте " + $hermesDir + "\apps\desktop и выполните 'npm run pack' вручную для деталей.")
        }
        Log "Сборка завершена успешно"
    } finally {
        Pop-Location
    }
}

# --- Регистрация auto-patch в Task Scheduler ---
function Install-AutoPatch {
    param([string]$repoDir)

    $autoScript = Join-Path $repoDir "scripts\auto-patch.ps1"
    $taskName = "Hermes Desktop RU Auto-Patch"

    # Unregister existing if any
    $existing = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existing) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false | Out-Null
    }

    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$autoScript`""

    # Триггер: начиная с этого момента, повтор каждые 15 минут, на всё время.
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Minutes 15) `
        -RepetitionDuration ([TimeSpan]::MaxValue)

    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
        -Settings $settings -Description "Автоматически пере-применяет русский перевод после обновления Hermes" `
        | Out-Null

    Log "Auto-patcher зарегистрирован (Task Scheduler task: $taskName)"
    Log "Интервал проверки: каждые 15 минут"
}

# --- Главная ---
Write-Host ""
Write-Host "Hermes Desktop Russian Locale Installer (Windows)" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

# Python
$py = Find-Python
if (-not $py) {
    Write-Host ""
    Err @"
Python не найден в PATH. Установите Python 3.10+ одной из команд:
  winget install Python.Python.3.11
  choco install python
  скачайте с https://python.org/downloads/
После установки перезапустите этот скрипт.
"@
}
Log ("Python найден: {0} ({1})" -f $py.Cmd, $py.Version)

# Hermes
$Hd = Find-HermesDir
if (-not $Hd) {
    Write-Host ""
    Err @"
Hermes Agent не найден. Установите его:
  iex (irm https://hermes-agent.nousresearch.com/install.ps1)
Затем запустите этот скрипт снова.
"@
}
Log "Hermes найден: $Hd"

# Если уже установлено — спросить
$ruFile = Join-Path $Hd "apps\desktop\src\i18n\ru.ts"
if ((Test-Path $ruFile) -and (-not $Silent)) {
    Warn "Русский перевод уже установлен."
    $answer = Read-Host "Переустановить? (y/N)"
    if (($answer -ne 'y') -and ($answer -ne 'Y')) {
        Write-Host "Установка отменена."
        exit 0
    }
}

$backupPath = Backup-Files -hermesDir $Hd
Apply-Patches -hermesDir $Hd -repoDir $ScriptDir -pythonCmd $py.Cmd
Build-App -hermesDir $Hd
Install-AutoPatch -repoDir $ScriptDir

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Log "Готово! Русский язык установлен."
Write-Host ""
Write-Host "Запустите Hermes Desktop и выберите:"
Write-Host "  Settings -> Appearance -> Русский"
Write-Host ""
Write-Host "Бэкап оригинальных файлов: $backupPath"
Write-Host "Авто-обновление: Task Scheduler -> '$taskName'"
Write-Host "Полное удаление: powershell -ExecutionPolicy Bypass -File .\uninstall.ps1"
Write-Host ""
