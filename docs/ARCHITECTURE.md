# Architecture

## Канонический контур

**Chat A — текущий обычный ChatGPT-чат.**  
Роль: Orchestrator / Executor. Имеет Desktop Commander и доступные инструменты текущего чата. Сам инспектирует Mac, меняет файлы, управляет приложениями, тестирует и публикует.

**Chat B — отдельный обычный ChatGPT-чат.**  
Роль: Planner / Reviewer. Не выполняет локальные изменения. Получает компактный пакет фактов, критикует решение и возвращает следующий шаг или verdict.

Пользователь общается только с Chat A.

## Почему bridge синхронный

Chat A не должен пытаться отправлять сообщение самому себе через браузер.

Вместо этого Chat A вызывает локальный `scripts/reviewer-bridge.py` через Desktop Commander. Bridge:
1. активирует вкладку Chat B;
2. вставляет PLAN_REQUEST / REVIEW_REQUEST;
3. ждёт завершения ответа;
4. читает последний ответ из DOM;
5. возвращает текст в stdout;
6. Chat A продолжает выполнение в том же turn.

Так сохраняется единый execution context Desktop Commander и не нужен Work/Codex.

## Приоритет управления Mac

`connector/API → CLI/Git/SSH → AppleScript/Shortcuts → mactl → cliclick coordinates`.

Координатные клики — только fallback.

## Voice

Голос — вход в тот же Chat A, а не отдельный агент:
`Dictation / push-to-talk → composer текущего ChatGPT → обычное сообщение → Desktop Commander`.

## Persisted state

Публичный source of truth:
- `AGENTS.md`
- `state/current.md`
- `docs/`
- `scripts/`

Локальное состояние, которое нельзя публиковать:
- `runtime/reviewer.json`
- relay logs
- временные screenshots
- auth / tokens / cookies
