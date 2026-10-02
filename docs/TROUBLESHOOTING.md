# Troubleshooting

## Desktop Commander не видит Mac

1. `list_devices`.
2. Проверить `MacBook-Pro-erdc.local` = Online.
3. `ping`.
4. Только затем диагностировать shell/filesystem.

## Команда установлена, но `command -v` не видит

Проверить через login shell: `zsh -lic 'command -v TOOL'`.
Пути user tools: `~/.local/bin`, `~/.npm-global/bin`, `~/.bun/bin`.

## Homebrew хочет собрать половину мира

На Intel macOS это ожидаемый риск.
Остановить установку до тяжёлой сборки, если она не нужна.
Искать официальный x86_64 release binary.
Не тянуть LLVM/Rust/GHC ради простого helper tool.

## GUI-команда не срабатывает

Проверить frontmost app: `mactl front`.
Проверить screenshot.
Проверить, что `System Events` имеет Accessibility permission.
Если menu item локализован, учитывать русское имя.
Если Accessibility tree не отдаёт web content, использовать браузерный способ или визуальный fallback.

## `cliclick` click промахивается

Не считать координаты стабильными между окнами/масштабами.
Сначала screenshot и положение окна.
Предпочитать element/menu/keyboard action.

## Chrome AppleScript JavaScript

Текущий Chrome: 154.0.8037.92.

Уже проверены и **не помогли**, поэтому не повторять:
- System Events click по menu item;
- `cliclick` по фактической координате menu item;
- `defaults write com.google.Chrome AppleScriptExecuteJavaScriptEnabled -bool true`;
- полный restart Chrome.

Даже при preference=1 Chrome runtime возвращает AppleScript error 12.

Нужен один физический ручной клик:
`Вид → Разработчикам → Разрешить JavaScript из событий Apple`.

После него:
`./scripts/reviewer-bridge.py doctor`.

## Ping-pong отправляет, но не умеет читать ответ

Исходящая часть уже проверена через clipboard + Enter.
Нельзя считать цикл автономным, пока последний assistant response не извлекается надёжно.
Не использовать случайные координаты Copy как production path.
См. `docs/PING_PONG.md` для вариантов входящего канала.

## Wrangler

Если `wrangler whoami` пишет `not authenticated`, инструмент установлен корректно, но Cloudflare account не подключён.
Не путать install с auth.

## Репозиторий automation

Локальная копия: `~/Documents/GPT-automation`.
Remote: `git@github.com:IMONsergey/GPT-automation.git`.
После изменения knowledge base: `git status`, commit, push `main`.
