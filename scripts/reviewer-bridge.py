#!/usr/bin/env python3
import argparse
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "runtime"
CONFIG = RUNTIME / "reviewer.json"
LOG = RUNTIME / "reviewer-bridge.log"
MACTL = str(Path.home() / ".local" / "bin" / "mactl")

def run(cmd, *, capture=False, check=False, input_text=None):
    return subprocess.run(
        cmd,
        text=True,
        capture_output=capture,
        check=check,
        input=input_text,
    )

def osa(script, *args):
    p = run(["osascript", "-e", script, *args], capture=True)
    if p.returncode:
        raise RuntimeError(p.stderr.strip() or "AppleScript failed")
    return p.stdout.strip()

def configured_match(explicit=None):
    if explicit:
        return explicit
    if not CONFIG.exists():
        raise RuntimeError(
            "Reviewer is not configured. Create runtime/reviewer.json "
            'with {"match":"<unique chat URL substring>"}'
        )
    data = json.loads(CONFIG.read_text(encoding="utf-8"))
    match = data.get("match")
    if not match:
        raise RuntimeError("runtime/reviewer.json has no 'match'")
    return match

def activate_tab(match):
    script = """on run argv
set needle to item 1 of argv
tell application "Google Chrome"
 repeat with wi from 1 to count of windows
  repeat with ti from 1 to count of tabs of window wi
   set u to URL of tab ti of window wi
   if u contains needle then
    set active tab index of window wi to ti
    set index of window wi to 1
    activate
    return u
   end if
  end repeat
 end repeat
end tell
error "Reviewer tab not found: " & needle
end run"""
    return osa(script, match)

def js_active(source):
    script = """on run argv
tell application "Google Chrome"
 return execute active tab of front window javascript (item 1 of argv)
end tell
end run"""
    return osa(script, source)

def state(match):
    activate_tab(match)
    source = r"""(() => {
 const nodes = [...document.querySelectorAll(
   '[data-message-author-role="assistant"]'
 )];
 const last = nodes.length ? nodes[nodes.length - 1] : null;
 const generating = !!document.querySelector(
   'button[data-testid="stop-button"]'
 );
 return JSON.stringify({
   text: last ? (last.innerText || last.textContent || '').trim() : '',
   generating
 });
})()"""
    raw = js_active(source)
    return json.loads(raw or '{"text":"","generating":false}')

def focus_composer(match):
    activate_tab(match)
    source = r"""(() => {
 const el = document.querySelector('#prompt-textarea')
   || document.querySelector('textarea')
   || document.querySelector('[contenteditable="true"]');
 if (!el) return 'NO_COMPOSER';
 el.focus();
 el.scrollIntoView({block: 'center'});
 return 'OK';
})()"""
    if js_active(source) != "OK":
        raise RuntimeError("ChatGPT composer not found")

def send(match, message):
    focus_composer(match)
    run(["pbcopy"], check=True, input_text=message)
    run([MACTL, "key", "v", "cmd"], check=True)
    time.sleep(0.2)
    run([MACTL, "press", "enter"], check=True)

def wait_reply(match, before, timeout=600, poll=1.5):
    deadline = time.time() + timeout
    previous = None
    stable = 0
    while time.time() < deadline:
        current = state(match)
        text = current["text"]
        if text and text != before and not current["generating"]:
            if text == previous:
                stable += 1
            else:
                previous = text
                stable = 1
            if stable >= 2:
                return text
        else:
            stable = 0
        time.sleep(poll)
    raise TimeoutError("Timed out waiting for Reviewer reply")

def log_exchange(kind, text):
    RUNTIME.mkdir(parents=True, exist_ok=True)
    stamp = time.strftime("%Y-%m-%d %H:%M:%S")
    with LOG.open("a", encoding="utf-8") as f:
        f.write(f"\n\n## {stamp} {kind}\n{text}\n")

def ask(match, message, timeout):
    before = state(match)["text"]
    log_exchange("A_TO_B", message)
    send(match, message)
    reply = wait_reply(match, before, timeout=timeout)
    log_exchange("B_TO_A", reply)
    return reply

def doctor(match=None):
    checks = []
    checks.append((
        "Chrome running",
        run(["pgrep", "-x", "Google Chrome"], capture=True).returncode == 0,
    ))
    checks.append(("mactl installed", Path(MACTL).exists()))
    try:
        osa('tell application "Google Chrome" to get URL of every tab of every window')
        checks.append(("Chrome AppleScript tabs", True))
    except Exception:
        checks.append(("Chrome AppleScript tabs", False))
    try:
        js_active("document.title")
        checks.append(("Chrome JavaScript from Apple Events", True))
    except Exception:
        checks.append(("Chrome JavaScript from Apple Events", False))
    if match:
        try:
            activate_tab(match)
            checks.append(("Reviewer tab found", True))
        except Exception:
            checks.append(("Reviewer tab found", False))
    for label, ok in checks:
        print(("PASS " if ok else "FAIL ") + label)
    return 0 if all(ok for _, ok in checks) else 1

def main():
    parser = argparse.ArgumentParser(
        description="Synchronous bridge from current Chat A to Reviewer Chat B"
    )
    sub = parser.add_subparsers(dest="cmd", required=True)

    pdoc = sub.add_parser("doctor")
    pdoc.add_argument("--match")

    pinit = sub.add_parser("init")
    pinit.add_argument("--match")
    pinit.add_argument("--timeout", type=int, default=600)

    pask = sub.add_parser("ask")
    pask.add_argument("message")
    pask.add_argument("--match")
    pask.add_argument("--timeout", type=int, default=600)

    plast = sub.add_parser("last")
    plast.add_argument("--match")

    args = parser.parse_args()

    if args.cmd == "doctor":
        match = None
        try:
            match = configured_match(args.match)
        except Exception:
            match = args.match
        return doctor(match)

    match = configured_match(args.match)

    if args.cmd == "init":
        prompt = (ROOT / "prompts" / "reviewer.md").read_text(
            encoding="utf-8"
        )
        print(ask(match, prompt, args.timeout))
        return 0

    if args.cmd == "ask":
        print(ask(match, args.message, args.timeout))
        return 0

    if args.cmd == "last":
        print(state(match)["text"])
        return 0

    return 1

if __name__ == "__main__":
    raise SystemExit(main())
