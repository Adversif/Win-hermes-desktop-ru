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

### Windows 11

```powershell
git clone https://github.com/Adversif/Win-hermes-desktop-ru.git
cd Win-hermes-desktop-ru
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

> **Требования:** Windows 10/11, Python 3.10+ в PATH (`winget install Python.Python.3.11`), Node.js (ставится вместе с Hermes), установленный [Hermes Agent Desktop](https://hermes-agent.nousresearch.com/) (по умолчанию в `%LOCALAPPDATA%\hermes\hermes-agent`).

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

### Вкладка «Шлюз» (Gateway) падает с `Cannot read properties of undefined (reading 'remoteUrlPlaceholder')`

**Симптом:** При выборе русского языка и переходе на вкладку Шлюз в `desktop.log` появляется ошибка:

```
[renderer console] TypeError: Cannot read properties of undefined (reading 'remoteUrlPlaceholder')
[renderer console] TypeError: Cannot read properties of undefined (reading 'createTitle')
```

**Что работает:** Russian UI работает на ~70% (везде где warment перевёл ключи). Затронуты только компоненты, ссылающиеся на ключи, которых нет в `ru.ts` (в основном `gatewayPage.*`, частично `sidebar.*`).

**Workaround:** Переключиться на английский при работе со вкладкой Шлюз (Settings → Appearance → Language → English, потом обратно на Русский).

**Корневая причина:** Hermes Desktop 0.17 имеет дополнительные namespace'ы (`gatewayPage`, `fileMenu`, `remoteDisplayBanner`, `starmap`, `statusStack`) и расширенные ключи внутри существующих (`sidebar.createTitle`, `cron.createTitle` — не в warment-версии, но в en.ts). `apply-i18n-patches.py` патчит `catalog.ts` через `deepMerge(en, _ru)` для fallback'а — это работает для `fileMenu`/`remoteDisplayBanner`/`starmap`/`statusStack`, **но runtime берёт `gatewayPage.remoteUrlPlaceholder` где-то не через `TRANSLATIONS.ru` глубокого слияния**. Подозрение: Hermes server-side (Python backend) имеет свою runtime-таблицу i18n, либо есть второй source-of-truth для переводов, который не покрыт нашим `catalog.ts` патчем.

**Куда смотреть для дальнейшего дебага:**
- `apps/desktop/src/i18n/context.tsx` — React-context с `t`
- `apps/desktop/src/i18n/runtime.ts` — path-based lookup `translateNow('foo.bar.baz')` (это graceful, не падает)
- `apps/desktop/src/i18n/catalog.ts` — наш `deepMerge(en, _ru)` после `apply-i18n-patches.py`
- `apps/desktop/src/app/settings/gateway-settings.tsx` — потребитель `t.gatewayPage.*` (на нём стоит `@ts-nocheck`)
- Hermes Python backend (`apps/desktop/...`) — может отдавать свой `t` через IPC

**Возможные направления фикса:**
1. Добавить недостающие ключи в `patches/ru.ts` напрямую (например `gatewayPage.remoteUrlPlaceholder: 'https://...'`), без ожидания что `deepMerge` их подхватит
2. Найти renderer-side источник `t` (возможно, отдельный файл `apps/desktop/dist/...` который генерируется при `npm run postbuild`) и убедиться что он использует наш `TRANSLATIONS.ru`
3. Сделать PR в `NousResearch/hermes-agent` который добавит пустые дефолты для всех используемых ключей
4. Репортить баг в warment/hermes-desktop-ru issue tracker

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
