# Chat failover and durable task state

## Цель

Работа не должна зависеть от одного длинного ChatGPT-чата.
Критическое состояние задачи хранится вне чата на Mac и восстанавливается новым рабочим чатом без пересказа пользователем.

## Роли

- `primary` — текущий Orchestrator / Executor.
- `reviewer` — независимый Planner / Reviewer.
- `standby` — резервный Orchestrator / Executor, готовый принять primary.
- Дополнительные worker-чаты допустимы, но не являются source of truth.

Source of truth для активной работы:
`runtime/active-task.json`.

Файл локальный и не коммитится.
Он не должен содержать секреты, токены, cookies или содержимое keychain.

## taskctl

Канонический helper: `scripts/taskctl`.
Инициализация задачи:

```bash
./scripts/taskctl init \
  --id baev-studio-v2 \
  --repo /path/to/repo \
  --goal "..." \
  --next "..."
```

Назначение чатов:

```bash
./scripts/taskctl role primary <chat-url-substring>
./scripts/taskctl role reviewer <chat-url-substring>
./scripts/taskctl role standby <chat-url-substring>
```

Безопасная точка:

```bash
./scripts/taskctl checkpoint \
  --next "следующий конкретный шаг" \
  --note "что только что проверено"
```
Проверка: `./scripts/taskctl doctor`.

Пакет для takeover: `./scripts/taskctl handoff`.

Переключение main-чата: `./scripts/taskctl promote standby`.

После promotion старый primary становится standby.

## Когда делать checkpoint

Обязательно:
1. сразу после восстановления задачи новым чатом;
2. перед долгой сборкой, deploy, миграцией или массовой правкой;
3. после успешного build/test;
4. после commit/push;
5. перед переключением на другой основной чат;
6. после каждого значимого UX/code slice, который нельзя терять.

Для длинных задач не держать единственный прогресс только в тексте ответа.
## Когда менять primary

Не ждать деградации чата бесконечно.
Если текущая сессия начинает повторно зависать, терять контекст или показывает длительную дополнительную обработку, сначала убедиться, что последний checkpoint актуален, затем передать `taskctl handoff` standby-чату и выполнить `taskctl promote standby`.

Новый primary обязан:
1. прочитать `AGENTS.md`;
2. прочитать `state/current.md`;
3. прочитать `runtime/active-task.json`;
4. выполнить `taskctl doctor`;
5. проверить реальное состояние repo/Mac;
6. продолжить с `next_action`.

## Ограничение

Failover не может гарантировать, что уже зависший сетевой response внезапно завершится.
Задача решается иначе: ни один незавершённый response не должен быть единственным местом, где существует состояние работы.

Поэтому код и файлы сохраняются сразу; git используется как durable checkpoint для завершённых срезов; `active-task.json` хранит operational checkpoint; reviewer и standby имеют отдельные chat URL; пользователь не обязан заново пересказывать задачу.