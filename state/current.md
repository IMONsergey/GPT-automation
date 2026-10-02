# Current state

Последняя проверка: 2026-10-02.

## Mac

- Host: `MacBook-Pro-erdc.local`
- macOS: `26.5.1`
- Architecture: `x86_64` (Intel)
- Shell: `/bin/zsh`
- Desktop Commander: `0.2.52`
- Desktop Commander `allowedDirectories`: `[]` = полный filesystem access в рамках разрешений процесса.

## Базовый dev stack

- Git: Apple Git `2.50.1`
- GitHub CLI: `2.92.0`
- GitHub account: `IMONsergey`
- Git protocol: SSH
- Node: `22.22.2` в обычном shell
- npm: `10.9.7`
- pnpm: `11.1.0`
- Bun: `1.3.6`
- Python: `3.13.5`
- uv: `0.9.25`
- Docker: `29.5.3`

## User-local CLI

Установлены в `~/.local/bin`, чтобы не зависеть от Homebrew на Intel macOS:

- `rg 15.2.0`
- `fd 10.5.0`
- `yq 4.54.1`
- `fzf 0.74.4`
- `bat 0.26.1`
- `shellcheck 0.11.0`
- `shfmt 3.14.1`
- `git-lfs 3.8.0`
- `cliclick 5.1`
- `mactl` — локальный helper

## Deploy tooling

- Vercel CLI: `62.1.0`, авторизация VERIFIED, account `cdo-2844`.
- Wrangler: `4.146.0`, установлен, но Cloudflare login отсутствует.
- Git LFS глобально инициализирован.

## GUI / desktop

- `System Events` видит frontmost process и список GUI-приложений: VERIFIED.
- `screencapture` работает: VERIFIED.
- Full-screen screenshot 3584x2240 был получен: VERIFIED.
- `cliclick` position/move: VERIFIED.
- ChatGPT Desktop имеет включённый UI toggle `Полный доступ`, но основной workflow этого репозитория — обычный ChatGPT-чат.

## Voice

- macOS Dictation: enabled (`Dictation Enabled = 1`).
- Предпочтение пользователя: говорить именно в обычный текущий чат.
- Рекомендованный вход: Dictation -> composer -> send.

## Two-chat orchestration

- Создание/выбор отдельной обычной вкладки ChatGPT: VERIFIED.
- Отправка текста через clipboard + Enter: VERIFIED.
- Тестовый чат ответил `PING-PONG READY`: VERIFIED.
- Надёжное чтение ответа обратно программно: PARTIAL.
- Chrome option `Allow JavaScript from Apple Events` видна, но программный toggle не применился: PARTIAL.
- Координатное нажатие Copy для ответа пока ненадёжно: PARTIAL.

## Homebrew caveat

На этом Intel Mac Homebrew предупреждает, что конфигурация больше не поддерживается и новые formulae могут собираться из исходников.
Не устанавливать тяжёлые цепочки зависимостей через Homebrew без проверки.
Для небольших CLI предпочитать официальные x86_64 release binaries в `~/.local/bin`.
