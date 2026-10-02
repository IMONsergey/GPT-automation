# Decisions

## 2026-10-02

### D001 — ordinary ChatGPT + Desktop Commander is the default
Не переводить задачу в Work/Codex только потому, что они доступны.

### D002 — Chat A executes, Chat B reviews
Текущий пользовательский чат сохраняет Desktop Commander и является Orchestrator / Executor. Второй обычный чат — независимый Planner / Reviewer.

### D003 — synchronous reviewer bridge
Chat A обращается к Chat B через локальный bridge и получает ответ в tool output. Не автоматизировать обратную отправку сообщения в текущий Chat A через браузер.

### D004 — max 8 review iterations
Нет бесконечного ping-pong. Повтор замечания без новых фактов требует смены стратегии проверки.

### D005 — user-local CLI on this Intel Mac
Для небольших CLI использовать официальные x86_64 release binaries в `~/.local/bin`, а не тяжёлую Homebrew-сборку неподдерживаемых formulae.

### D006 — Chrome JavaScript toggle is manual
На Chrome 154 проверены System Events, `cliclick`, `defaults write ... AppleScriptExecuteJavaScriptEnabled=true` и restart. Runtime всё равно блокирует `execute javascript`.

Не повторять. Пользователь один раз вручную включает:
`Вид → Разработчикам → Разрешить JavaScript из событий Apple`.

### D007 — doctor must stay fast
Обычный doctor не делает долгие remote `vercel whoami` / `wrangler whoami`. Remote auth проверяется перед конкретным deploy.

### D008 — secrets never enter the repository
Токены, cookies, chat URL identifiers, keychain data и локальные relay logs остаются в `runtime/` или credential stores и не коммитятся.

### D009 — one canonical local clone
Канонический clone: `~/Documents/GPT-automation`.

`~/Projects/GPT-automation` — symlink на него. Старая конфликтная копия сохранена как локальный backup, но не используется для работы. Это исключает параллельные расходящиеся commit histories.
