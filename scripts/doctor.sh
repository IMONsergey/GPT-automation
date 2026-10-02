#!/bin/bash
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
warn=0

ok()   { printf "PASS  %s\n" "$1"; }
bad()  { printf "FAIL  %s\n" "$1"; fail=1; }
note() { printf "WARN  %s\n" "$1"; warn=1; }

need_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 -> $(command -v "$1")"
  else
    bad "$1 missing"
  fi
}

echo "GPT Automation doctor"
echo "====================="
echo "macOS: $(sw_vers -productVersion 2>/dev/null || echo unknown)"
echo "arch:  $(uname -m)"
echo
for c in git gh node npm pnpm bun python3 uv rg fd jq yq fzf bat shellcheck shfmt git-lfs vercel wrangler codex docker osascript shortcuts mactl cliclick; do
  need_cmd "$c"
done

if [ -x "$ROOT/scripts/reviewer-bridge.py" ]; then
  ok "reviewer-bridge.py present"
else
  bad "reviewer-bridge.py missing or not executable"
fi

echo
if osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' >/dev/null 2>&1; then
  ok "System Events GUI automation"
else
  bad "System Events GUI automation unavailable"
fi

if gh auth status >/dev/null 2>&1; then
  ok "GitHub CLI authenticated"
else
  note "GitHub CLI not authenticated"
fi

note "Vercel/Cloudflare remote auth is checked only when deploying"

if [ "$(defaults read com.apple.assistant.support 'Dictation Enabled' 2>/dev/null || echo 0)" = "1" ]; then
  ok "macOS Dictation enabled"
else
  note "macOS Dictation disabled or preference unreadable"
fi

if pgrep -x "Google Chrome" >/dev/null 2>&1; then
  if osascript -e 'tell application "Google Chrome" to execute active tab of front window javascript "document.title"' >/dev/null 2>&1; then
    ok "Chrome JavaScript from Apple Events"
  else
    note "Chrome JS from Apple Events disabled; relay DOM read is not ready"
  fi
else
  note "Chrome not running; skipped Chrome JS test"
fi

echo
if (( fail )); then
  echo "RESULT: FAIL"
  exit 1
elif (( warn )); then
  echo "RESULT: READY WITH WARNINGS"
  exit 0
else
  echo "RESULT: READY"
  exit 0
fi
