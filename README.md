# GPT Automation

Автоматизация Mac Сергея из обычного ChatGPT-чата через Remote Desktop Commander.
Репозиторий хранит рабочие правила, состояние окружения, runbook'и, промпты и локальные helper-скрипты.

## Быстрый старт для нового чата

Если ты новый ChatGPT-чат:
1. прочитай `AGENTS.md`;
2. прочитай `state/current.md`;
3. используй Remote Desktop Commander, а не проси пользователя повторять настройку;
4. выбери нужный runbook из `docs/`;
5. после улучшений обнови этот репозиторий.

## Что уже работает

- Управление файлами, процессами, shell, Git/SSH через Desktop Commander.
- GUI Automation через macOS `System Events`.
- Скриншоты экрана и визуальная проверка.
- Управление курсором через `cliclick`.
- Единый helper `mactl`.
- GitHub CLI авторизован как `IMONsergey`, SSH включён.
- Vercel CLI установлен и авторизован.
- Диктовка macOS включена.
- Создание второго обычного ChatGPT-чата и отправка ему сообщений проверены.

## Что пока не считается готовым

Двухчатовый контур имеет статус `PARTIAL` только из-за одного Chrome permission.
Исходящий канал в Reviewer работает и тестовый чат ответил `PING-PONG READY`.
Синхронный `scripts/reviewer-bridge.py` уже создан; после ручного включения Chrome JavaScript from Apple Events он должен закрыть машинное чтение ответа Reviewer.
Подробности: `docs/PING_PONG.md`.

## Структура

- `AGENTS.md` — обязательные правила для любого нового агента/чата.
- `state/current.md` — фактическое состояние Mac и установленных инструментов.
- `docs/ARCHITECTURE.md` — канонические роли и слои управления.
- `docs/DECISIONS.md` — решения, которые не надо переобсуждать.
- `docs/MAC_SETUP.md` — окружение и GUI-управление.
- `docs/PING_PONG.md` — архитектура и протокол двухчатового контура.
- `docs/VOICE.md` — голосовой ввод в обычный чат.
- `docs/TROUBLESHOOTING.md` — известные проблемы и обходы.
- `prompts/reviewer.md` — prompt Planner / Reviewer (Chat B).
- `prompts/executor.md` — prompt Orchestrator / Executor (Chat A).
- `scripts/reviewer-bridge.py` — синхронный мост Chat A → Chat B → stdout.
- `scripts/mactl` — helper для GUI/macOS.
- `scripts/bootstrap.sh` — восстановление пользовательских CLI-инструментов.

## Главная договорённость

Не использовать Codex как замену обычному ChatGPT-чату для этого контура, если Сергей прямо этого не попросил.
Основная идея: Сергей ставит задачу в обычном чате; ChatGPT сам использует Desktop Commander и при необходимости второй обычный ChatGPT-чат для независимой проверки.
