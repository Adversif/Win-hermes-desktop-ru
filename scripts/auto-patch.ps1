# Hermes Desktop Russian Locale Auto-Patcher (Windows)
# Запускается через Task Scheduler каждые 15 минут. Если en.ts в Hermes
# изменился (значит апдейт), и если у нас ещё нет ru.ts — переприменяет
# патч.

$ErrorActionPreference = 'SilentlyContinue'

$RepoDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$HermesDir = $null

function Find-HermesDir {
    $candidates = @(
        "$env:LOCALAPPDATA\hermes\hermes-agent",
        "$env:USERPROFILE\.hermes\hermes-agent",
        "$env:USERPROFILE\hermes-agent",
        "$env:USERPROFILE\Dev\hermes-agent",
        "$env:USERPROFILE\projects\hermes-agent"
    )
    foreach ($d in $candidates) {
        if (Test-Path "$d\apps\desktop\src\i18n") { return $d }
    }
    return $null
}

$Hd = Find-HermesDir
if (-not $Hd) {
    # Hermes ещё не установлен / не найден — тихо выходим. Ничего страшного.
    exit 0
}

# Маркер предыдущей успешной установки
$markerFile = Join-Path $Hd ".ru-last-backup"
if (-not (Test-Path $markerFile)) {
    exit 0
}

$ruFile = Join-Path $Hd "apps\desktop\src\i18n\ru.ts"
if (Test-Path $ruFile) {
    exit 0
}

# ru.ts пропал — значит апдейт. Запускаем тот же Python-применитель.
$logDir = Join-Path $RepoDir "logs"
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
$logFile = Join-Path $logDir "auto-patch.log"

$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logFile -Value "[$ts] ru.ts missing, re-applying Russian translation..."

# Зовём apply-i18n-patches.py через Python
$pyCandidates = @('python', 'python3', 'py')
$py = $null
foreach ($c in $pyCandidates) {
    $found = Get-Command $c -ErrorAction SilentlyContinue
    if ($found) { $py = $c; break }
}
if (-not $py) {
    Add-Content -Path $logFile -Value "  [FAIL] no python on PATH"
    exit 1
}

$applyScript = Join-Path $RepoDir "scripts\apply-i18n-patches.py"
if (-not (Test-Path $applyScript)) {
    Add-Content -Path $logFile -Value "  [FAIL] apply-i18n-patches.py not found at $applyScript"
    exit 1
}

Set-Location $RepoDir
$output = & $py $applyScript $RepoDir $Hd 2>&1
Add-Content -Path $logFile -Value $output

# Сборка приложения
Add-Content -Path $logFile -Value "[$ts] rebuilding..."
Push-Location (Join-Path $Hd "apps\desktop")
$buildOutput = npm run pack 2>&1 | Select-Object -Last 10
Add-Content -Path $logFile -Value $buildOutput
Pop-Location

Add-Content -Path $logFile -Value "[$ts] done"
