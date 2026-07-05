<p align="center">
  <img src="https://img.shields.io/badge/🇭🇷_Hermes_Desktop-Russian_locale-FFD700?style=for-the-badge&labelColor=1a1a2e" alt="Hermes Desktop Russian Locale" width="100%">
</p>

<h1 align="center">🇭🇷 Hermes Desktop — Русский язык</h1>

<p align="center">
  <a href="https://github.com/NousResearch/hermes-agent"><img src="https://img.shields.io/badge/Hermes_Agent-Official_Repo-FFD700?style=for-the-badge&logo=github" alt="Hermes Agent"></a>
  <a href="https://github.com/warment/hermes-desktop-ru/releases"><img src="https://img.shields.io/github/v/release/warment/hermes-desktop-ru?style=for-the-badge&color=green" alt="Release"></a>
  <a href="https://github.com/warment/hermes-desktop-ru/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License: MIT"></a>
  <a href="https://discord.gg/NousResearch"><img src="https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white" alt="Discord"></a>
</p>

<p align="center">
  <b>Автоматическая установка русского языка в десктопном приложении Hermes Agent.</b><br>
  Одна команда — и весь интерфейс на русском. Поддержка Windows 11 и macOS.
</p>

---

## ⚡ Быстрая установка

### Windows 11 — три варианта

#### ⚡ Вариант 1: однофайловый патчер (104 KB) — *рекомендуется*

📥 Скачай **[Hermes-Desktop-0.17.3-ru-patcher.bat](https://github.com/Adversif/Win-hermes-desktop-ru/releases/download/v0.17.3-ru/Hermes-Desktop-0.17.3-ru-patcher.bat)** (~104 KB) → двойной клик → нажми `Y`.

Это **самораспаковывающийся .bat** с базой64-пейлоадом. Скачал → запустил → готово. Внутри:
- Python-скрипт `apply-i18n-patches.py` (кросс-платформенный патчер)
- `patches/ru.ts` + `patches/ru-constants.ts` — 130+ ключей перевода
- Подпатчи для Settings, Gateway, Skills, etc.

Показывает:
```
============================================================
 Hermes Desktop Russian Locale Patcher v0.17.3
============================================================
 Detecting Python...
 Python:  OK
 Hermes:  C:\Users\adversif\AppData\Local\hermes\hermes-agent

Continue? (Y/N): _
 Extracting patcher...
Applying Russian patches to: ...
[OK] All Russian i18n patches applied successfully
```

Идемпотентно — можно запускать после каждого обновления Hermes.

> **Когда использовать:** если Hermes Desktop уже установлен.
> **Требования:** Windows 10/11, **Python 3.10+** в PATH (`winget install Python.Python.3.11`), [Hermes Agent Desktop](https://hermes-agent.nousresearch.com/) установленный.

#### 🔧 Вариант 2: полный .exe installer (112 MB) — впервые ставишь Hermes

📦 Скачай **[Hermes-Desktop-0.17.3-ru-win-x64-installer.exe](https://github.com/Adversif/Win-hermes-desktop-ru/releases/download/v0.17.3-ru/Hermes-Desktop-0.17.3-ru-win-x64-installer.exe)** (~112 MB) → запусти → следуй инструкциям установщика.

Содержит Hermes Desktop целиком + русские патчи. Не нужно ничего ставить предварительно.

#### 📦 Вариант 3: лёгкий `.zip` (66 KB) — для любителей распаковки

📦 Скачай **[Hermes-Desktop-0.17.3-ru-patcher.zip](https://github.com/Adversif/Win-hermes-desktop-ru/releases/download/v0.17.3-ru/Hermes-Desktop-0.17.3-ru-patcher.zip)** (~66 KB) → распакуй → двойной клик `install-ru.cmd`.

Содержимое идентично патчер-у внутри .bat, но в виде обычных файлов для аудита.

### Из исходников (PowerShell)

```powershell
git clone https://github.com/Adversif/Win-hermes-desktop-ru.git
cd Win-hermes-desktop-ru
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

> Если Python нет в PATH: `winget install Python.Python.3.11`.

### macOS

```bash
git clone https://github.com/warment/hermes-desktop-ru.git
cd hermes-desktop-ru
./install.sh
```

Или одной командой:

```bash
curl -sSL https://raw.githubusercontent.com/warment/hermes-desktop-ru/main/install.sh | bash
```

После установки (любая ОС): **Settings** → **Appearance** → **Русский**

---

## ✨ Что переведено

<table>
<tr><td><b>Навигация настроек</b></td><td>Провайдеры, Аккаунты, API-ключи, Инструменты, Шлюз, MCP, Архивные чаты, О приложении</td></tr>
<tr><td><b>Поля настроек</b></td><td>Все названия и описания (~60 ключей): Окно контекста, Личность, Рабочая директория, Режим выполнения кода и т.д.</td></tr>
<tr><td><b>Состояния загрузки</b></td><td>Загрузка конфигурации, ключей, модели, шлюза, MCP-серверов, провайдеров, сессий</td></tr>
<tr><td><b>Архивные сессии</b></td><td>Заголовок, описание, пустое состояние, кнопки, уведомления</td></tr>
<tr><td><b>Директория проекта</b></td><td>Заголовок, описание, кнопки выбора/очистки</td></tr>
<tr><td><b>MCP серверы</b></td><td>Создание, редактирование, перезагрузка, уведомления (~24 ключа)</td></tr>
<tr><td><b>Шлюз</b></td><td>Локальный/удалённый, URL, аутентификация, диагностика (~35 ключей)</td></tr>
<tr><td><b>Boot экран</b></td><td>Шаги загрузки, ошибки, экран восстановления</td></tr>
<tr><td><b>Titlebar</b></td><td>Кнопки заголовка окна</td></tr>
<tr><td><b>Composer</b></td><td>Поле ввода, голос, вложения, команды, подсказки</td></tr>
<tr><td><b>Sidebar</b></td><td>Навигация по сессиям, поиск, группировка</td></tr>
<tr><td><b>Описания навыков</b></td><td>apple-notes, apple-reminders, findmy, imessage, macos-operations и др.</td></tr>
</table>

---

## 🛡️ Автоматическое обновление

- **macOS:** через `LaunchAgent` (`~/Library/LaunchAgents/com.hermes-desktop-ru.patcher.plist`). Срабатывает при изменении файлов Hermes.
- **Windows 11:** через **Task Scheduler** (задача `Hermes Desktop RU Auto-Patch`), повтор каждые 15 минут. Срабатывает, если `ru.ts` пропал (Hermes обновился и затер файлы). Лог в `Win-hermes-desktop-ru/logs/auto-patch.log`.

При обновлении Hermes русский перевод пере-применяется автоматически на обеих платформах.

---

## 🗑️ Удаление

### Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

### macOS

```bash
./uninstall.sh
```

В обоих случаях: восстановятся оригинальные файлы из последнего бэкапа, удалится русский перевод и снимется регистрация авто-обновления.

---

## 📁 Структура

```
Win-hermes-desktop-ru/
├── install.sh              # Установщик (macOS)
├── install.ps1             # Установщик (Windows)       ← форк Adversif
├── uninstall.sh            # Удаление (macOS)
├── uninstall.ps1           # Удаление (Windows)         ← форк Adversif
├── README.md               # Документация
├── patches/
│   ├── ru.ts               # Русский перевод интерфейса (~850 строк)
│   ├── ru-constants.ts     # Русские названия полей настроек
│   ├── en.ts.reference     # Снимок оригинального en.ts (для отката)
│   └── types.ts.reference  # Снимок оригинального types.ts (для отката)
└── scripts/
    ├── apply-i18n-patches.py # Кросс-платформенный применитель всех патчей
    ├── patch-components.py  # Патч компонентов настроек
    ├── patch-skills.py      # Патч описаний навыков
    ├── auto-patch.sh        # Auto-reapply (macOS, через LaunchAgent)
    └── auto-patch.ps1       # Auto-reapply (Windows, через Task Scheduler)   ← форк Adversif
```

---

## 🔧 Как это работает

1. `install.{sh,ps1}` находит установку Hermes в стандартных расположениях  
   (macOS: `~/.hermes/hermes-agent`; Windows: `%LOCALAPPDATA%\hermes\hermes-agent`)
2. Создаёт бэкап оригинальных файлов в `.ru-backup-<timestamp>/`
3. Копирует `ru.ts` и `ru-constants.ts` в дерево исходников
4. Запускает `scripts/apply-i18n-patches.py` (единый кросс-платформенный скрипт), который:
   - Регистрирует `ru` в i18n-системе (`types.ts`, `languages.ts`, `catalog.ts`)
   - Патчит компоненты настроек (заменяет захардкоженные строки на `t.*`)
   - Патчит `skills/index.tsx` для перевода описаний навыков
5. Пересобирает приложение (`npm run pack`)
6. Регистрирует авто-обновление:
   - macOS: LaunchAgent
   - Windows: задача Task Scheduler (интервал 15 минут)

---

## 📋 Требования

| Платформа | Требования |
|---|---|
| **macOS** | Hermes Agent Desktop, Node.js и npm, стандартный bash |
| **Windows 11** | Hermes Agent Desktop (`%LOCALAPPDATA%\hermes`), Node.js/npm (ставится с Hermes), **Python 3.10+** в PATH |

---

## ⚠️ Известные ограничения

### История: баг `Cannot read properties of undefined (reading 'remoteUrlPlaceholder')`

**Статус:** ✅ **ИСПРАВЛЕНО** (коммит после `0.17.0`, форк `Adversif/Win-hermes-desktop-ru`).

**Симптом:** при русской локали и переходе на **Settings → Шлюз** `desktop.log` падал:

```
[renderer console] TypeError: Cannot read properties of undefined (reading 'remoteUrlPlaceholder')
```

**Корневая причина:** в исходниках Hermes `apps/desktop/src/app/settings/gateway-settings.tsx` обращается к `t.gatewayPage.remoteUrlPlaceholder`, но **upstream `en.ts` этот top-level ключ уже удалил** при рефакторинге в `settings.gateway`. На любой локали обращение к `t.gatewayPage.*` падает, потому что `t.gatewayPage === undefined`.

`apply-i18n-patches.py` ставит `deepMerge(en, _ru)` в `catalog.ts`, но **это бы помогло только если бы `ru.ts` имел `gatewayPage`**, чего в warment-версии тоже не было.

**Фикс** (зашит в `apply-i18n-patches.py`, идемпотентно):
1. Добавляет блок `gatewayPage: { ... }` в **сам `en.ts`** (раньше блок был только в ru-версии Hermes, после рефакторинга исчез из обеих).
2. Префиксует `// @ts-nocheck` к `en.ts` (тип `Translations` не знает про `gatewayPage`).

После билда Hermes renderer видит `t.gatewayPage.remoteUrlPlaceholder` как `'https://gateway.example.com/hermes'` для **любой локали**, вкладка Шлюз открывается.

**Сценарий обновления:** при `npm update hermes-agent` upstream перезапишет `en.ts`. После обновления снова запусти `install.ps1` — `apply-i18n-patches.py` переустановит блок автоматически (идемпотентно).

### Логирование

- Ошибки рендерера: `%LOCALAPPDATA%\hermes\logs\desktop.log` (см. `[renderer console]` строки)
- Ошибки Python backend: `%LOCALAPPDATA%\hermes\logs\agent.log`
- Hermes GUI логи: `%LOCALAPPDATA%\hermes\logs\gui.log`

Включить DevTools: в `apps/desktop/src/main/index.ts` найти `BrowserWindow` и временно добавить `webPreferences: { devTools: true }`, потом View → Toggle Developer Tools (Ctrl+Shift+I).

---

## 🤝 Вклад

Приветствуются:
- Переводы на другие языки
- Исправления ошибок
- Улучшения скрипта установки

## 📣 Официальное обсуждение

Issue в основном репозитории Hermes: [#40347](https://github.com/NousResearch/hermes-agent/issues/40347)

---

## 📄 Лизензия

MIT License

---

<p align="center">
  <sub>Built with ❤️ for the <a href="https://github.com/NousResearch/hermes-agent">Hermes Agent</a> community</sub>
</p>
