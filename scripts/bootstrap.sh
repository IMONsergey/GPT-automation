#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$HOME/.local/bin"
NPMBIN="$HOME/.npm-global/bin"
mkdir -p "$BIN" "$NPMBIN"

ensure_line() {
  local line="$1"
  local file="$HOME/.zshrc"
  touch "$file"
  grep -qxF "$line" "$file" || printf '%s\n' "$line" >> "$file"
}

ensure_line "export PATH=\"\$HOME/.npm-global/bin:\$PATH\""
ensure_line "export PATH=\"\$HOME/.local/bin:\$PATH\""

export PATH="$BIN:$NPMBIN:$PATH"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap targets macOS."
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

install_tgz_binary() {
  local name="$1" url="$2" inner="$3"
  command -v "$name" >/dev/null 2>&1 && return 0
  curl -fsSL -o x.tgz "$url"
  tar -xzf x.tgz
  cp "$inner" "$BIN/$name"
  chmod +x "$BIN/$name"
  rm -rf x.tgz ./*/
}

if [[ "$(uname -m)" == "x86_64" ]]; then
  install_tgz_binary rg     "https://github.com/BurntSushi/ripgrep/releases/download/15.2.0/ripgrep-15.2.0-x86_64-apple-darwin.tar.gz"     "ripgrep-15.2.0-x86_64-apple-darwin/rg"

  install_tgz_binary fd     "https://github.com/sharkdp/fd/releases/download/v10.5.0/fd-v10.5.0-x86_64-apple-darwin.tar.gz"     "fd-v10.5.0-x86_64-apple-darwin/fd"

  install_tgz_binary fzf     "https://github.com/junegunn/fzf/releases/download/v0.74.4/fzf-0.74.4-darwin_amd64.tar.gz"     "fzf"

  if ! command -v yq >/dev/null 2>&1; then
    curl -fsSL -o "$BIN/yq" "https://github.com/mikefarah/yq/releases/download/v4.54.1/yq_darwin_amd64"
    chmod +x "$BIN/yq"
  fi

  if ! command -v shfmt >/dev/null 2>&1; then
    curl -fsSL -o "$BIN/shfmt" "https://github.com/mvdan/sh/releases/download/v3.14.1/shfmt_v3.14.1_darwin_amd64"
    chmod +x "$BIN/shfmt"
  fi

  if ! command -v bat >/dev/null 2>&1; then
    curl -fsSL -o bat.tgz "https://github.com/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-x86_64-apple-darwin.tar.gz"
    tar -xzf bat.tgz
    cp bat-v0.26.1-x86_64-apple-darwin/bat "$BIN/bat"
    chmod +x "$BIN/bat"
  fi

  if ! command -v shellcheck >/dev/null 2>&1; then
    curl -fsSL -o shellcheck.txz "https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.darwin.x86_64.tar.xz"
    tar -xJf shellcheck.txz
    cp shellcheck-v0.11.0/shellcheck "$BIN/shellcheck"
    chmod +x "$BIN/shellcheck"
  fi

  if ! command -v cliclick >/dev/null 2>&1; then
    curl -fsSL -o cliclick.zip "https://github.com/BlueM/cliclick/releases/download/5.1/cliclick.zip"
    unzip -q cliclick.zip
    cp "$(find . -type f -name cliclick -perm -111 | head -1)" "$BIN/cliclick"
    chmod +x "$BIN/cliclick"
  fi

  if ! command -v git-lfs >/dev/null 2>&1; then
    curl -fsSL -o git-lfs.zip "https://github.com/git-lfs/git-lfs/releases/download/v3.8.0/git-lfs-darwin-amd64-v3.8.0.zip"
    unzip -q git-lfs.zip
    cp "$(find . -type f -name git-lfs | head -1)" "$BIN/git-lfs"
    chmod +x "$BIN/git-lfs"
  fi
else
  echo "ARM Mac: extend pinned asset list before using this script."
fi

cp "$ROOT/scripts/mactl" "$BIN/mactl"
chmod +x "$BIN/mactl"
git-lfs install --skip-repo >/dev/null 2>&1 || true

if command -v npm >/dev/null 2>&1; then
  npm config set prefix "$HOME/.npm-global"
  command -v vercel >/dev/null 2>&1 || npm install -g vercel@latest
  command -v wrangler >/dev/null 2>&1 || npm install -g wrangler@latest
else
  echo "WARN: npm missing; Vercel/Wrangler not installed."
fi

echo
"$ROOT/scripts/doctor.sh"
