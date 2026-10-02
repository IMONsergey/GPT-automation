# Mac setup and control

## Цель

Максимально быстрый и воспроизводимый контроль Mac из обычного ChatGPT через Remote Desktop Commander.
CLI используется там, где он быстрее GUI. GUI нужен для приложений без подходящего CLI/API.

## Desktop Commander

Текущее устройство: `MacBook-Pro-erdc.local`.
Файловая область не ограничена списком каталогов (`allowedDirectories=[]`).
Системные опасные команды всё равно могут блокироваться самим Desktop Commander.

Рекомендуемый порядок:
1. `list_devices` / `get_config` при сомнении в соединении.
2. filesystem tools для чтения/редактирования файлов.
3. process tools для shell/SSH/dev servers.
4. GUI helper только когда задача действительно требует интерфейс.

## GUI stack

Основа: AppleScript + `System Events`.
Fallback: `cliclick` для pointer/mouse.
Визуальная проверка: `screencapture -x ...` + чтение изображения.
Clipboard: `pbcopy` / `pbpaste` для быстрых и надёжных текстовых передач.

## mactl

Рабочая копия: `~/.local/bin/mactl`.
Версия в репозитории: `scripts/mactl`.

Поддерживаемые команды:
- `mactl front` — frontmost app.
- `mactl apps` — GUI apps.
- `mactl open APP` — открыть приложение.
- `mactl activate APP` — вывести приложение вперёд.
- `mactl quit APP` — штатно закрыть.
- `mactl windows APP` — список окон.
- `mactl paste TEXT` — clipboard + Cmd+V.
- `mactl key KEY [cmd,shift,...]` — текстовый keystroke.
- `mactl press enter|esc|tab|...` — физическая клавиша через cliclick.
- `mactl click X Y` / `move X Y` / `pos` — pointer.
- `mactl menu APP MENU ITEM` — menu action.
- `mactl shot [PATH]` — screenshot.
- `mactl shortcut NAME` — macOS Shortcut.
- `mactl chrome-tabs` — адресный список Chrome tabs.
- `mactl chrome-tab MATCH` — активировать вкладку по URL substring.
- `mactl chrome-js-active JS` — выполнить JS в active tab, если Chrome permission включён.

## GUI reliability rules

Не делай blind click, если можно проверить окно/скриншот.
После изменения UI получай screenshot или считывай состояние через Accessibility.
Не фиксируй координаты как основной API: координаты — последний fallback.
Перед координатным кликом удостоверяйся в размере экрана/окна и активном приложении.

## CLI installation policy

Из-за Intel/macOS Homebrew может собирать современные formulae из исходников.
Это создаёт лишние зависимости и задержки.
Для маленьких self-contained CLI: брать официальный `x86_64-apple-darwin`/`darwin_amd64` release binary.
Устанавливать в `~/.local/bin`.
Не заменять работающий системный tool без необходимости.

## PATH

Новый login shell видит:
- `~/.local/bin`
- `~/.npm-global/bin`
- `~/.bun/bin`
и стандартные системные каталоги.

## Git / deployments

`gh` уже авторизован как `IMONsergey`; protocol SSH.
Vercel CLI уже авторизован.
Wrangler установлен, но перед реальным Cloudflare deploy требуется `wrangler login` или другой разрешённый auth path.

## Безопасность

Не хранить access tokens в этом репозитории.
Не коммитить содержимое keychain, cookies, browser profile и секретные `.env`.
Не отключать системные защиты ради удобства GUI-автоматизации.
Если macOS показывает системный permission dialog, пользователь может потребоваться только для самого TCC-confirmation.

## Canonical automation repo

Локальная source-of-truth копия: `~/Documents/GPT-automation`.

Если найдена другая копия, не работать параллельно в двух клонах. Сначала сверить её с canonical repo.

## Chrome reviewer bridge

Для DOM-чтения Chat B нужен один ручной toggle:
`Вид → Разработчикам → Разрешить JavaScript из событий Apple`.

Автоматические способы на Chrome 154 уже проверены и не сработали. Не повторять — см. `docs/DECISIONS.md`.
