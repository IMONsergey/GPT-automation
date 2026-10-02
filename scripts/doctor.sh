#!/bin/bash
set -u

echo '== SYSTEM =='
sw_vers
uname -m
echo "shell=$SHELL"
echo

echo '== DESKTOP/GUI =='
osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>&1 || true
command -v screencapture >/dev/null && echo 'screencapture: OK' || echo 'screencapture: MISSING'
command -v cliclick >/dev/null && cliclick -V || echo 'cliclick: MISSING'
command -v mactl >/dev/null && echo "mactl: $(command -v mactl)" || echo 'mactl: MISSING'

echo
echo '== CLI =='
for c in git gh node npm pnpm bun python3 uv rg fd jq yq fzf bat shellcheck shfmt git-lfs vercel wrangler docker; do
  if command -v "$c" >/dev/null 2>&1; then
    printf '%-12s %s\n' "$c" "$(command -v "$c")"
  else
    printf '%-12s MISSING\n' "$c"
  fi
done

run_timeout() {
  python3 - "$@" <<'PY'
import subprocess, sys
try:
    p = subprocess.run(sys.argv[1:], text=True, capture_output=True, timeout=8)
    out = (p.stdout + p.stderr).strip()
    print(out if out else f"exit={p.returncode}")
except subprocess.TimeoutExpired:
    print("TIMEOUT after 8s")
except FileNotFoundError:
    print("MISSING")
PY
}

echo
echo '== AUTH =='
run_timeout gh auth status | sed -n '1,8p'
echo
printf 'vercel: '
run_timeout vercel whoami | sed -n '1,4p'
echo
run_timeout wrangler whoami | sed -n '1,12p'

echo
echo '== VOICE / DICTATION =='
defaults read com.apple.assistant.support 'Dictation Enabled' 2>/dev/null || echo 'Dictation preference not readable'

echo
echo '== GPT AUTOMATION REPO =='
REPO="$HOME/Documents/GPT-automation"
if [ -d "$REPO/.git" ]; then
  git -C "$REPO" status --short --branch
  git -C "$REPO" remote -v | head -2
else
  echo 'local repo missing'
fi
