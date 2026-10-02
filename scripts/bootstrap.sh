#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo 'This bootstrap is for macOS.' >&2
  exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" != "x86_64" ]]; then
  echo "Current documented machine is Intel x86_64; got $ARCH." >&2
  echo 'Review asset names before running on another architecture.' >&2
  exit 2
fi

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

echo 'Installing lightweight official release binaries...'
curl -fsSL -o rg.tgz https://github.com/BurntSushi/ripgrep/releases/download/15.2.0/ripgrep-15.2.0-x86_64-apple-darwin.tar.gz
tar -xzf rg.tgz
cp ripgrep-15.2.0-x86_64-apple-darwin/rg "$BIN/rg"

curl -fsSL -o fd.tgz https://github.com/sharkdp/fd/releases/download/v10.5.0/fd-v10.5.0-x86_64-apple-darwin.tar.gz
tar -xzf fd.tgz
cp fd-v10.5.0-x86_64-apple-darwin/fd "$BIN/fd"

curl -fsSL -o "$BIN/yq" https://github.com/mikefarah/yq/releases/download/v4.54.1/yq_darwin_amd64

curl -fsSL -o fzf.tgz https://github.com/junegunn/fzf/releases/download/v0.74.4/fzf-0.74.4-darwin_amd64.tar.gz
tar -xzf fzf.tgz
cp fzf "$BIN/fzf"

curl -fsSL -o bat.tgz https://github.com/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-x86_64-apple-darwin.tar.gz
tar -xzf bat.tgz
cp bat-v0.26.1-x86_64-apple-darwin/bat "$BIN/bat"

curl -fsSL -o shellcheck.txz https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.darwin.x86_64.tar.xz
tar -xJf shellcheck.txz
cp shellcheck-v0.11.0/shellcheck "$BIN/shellcheck"

curl -fsSL -o "$BIN/shfmt" https://github.com/mvdan/sh/releases/download/v3.14.1/shfmt_v3.14.1_darwin_amd64

curl -fsSL -o git-lfs.zip https://github.com/git-lfs/git-lfs/releases/download/v3.8.0/git-lfs-darwin-amd64-v3.8.0.zip
unzip -q git-lfs.zip
cp "$(find . -type f -name git-lfs | head -1)" "$BIN/git-lfs"

curl -fsSL -o cliclick.zip https://github.com/BlueM/cliclick/releases/download/5.1/cliclick.zip
unzip -q cliclick.zip
cp "$(find . -type f -name cliclick -perm -111 | head -1)" "$BIN/cliclick"

chmod +x "$BIN"/{rg,fd,yq,fzf,bat,shellcheck,shfmt,git-lfs,cliclick}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cp "$ROOT/scripts/mactl" "$BIN/mactl"
chmod +x "$BIN/mactl"

"$BIN/git-lfs" install --skip-repo

echo 'Installing deployment CLIs through npm...'
npm install -g vercel@latest wrangler@latest

echo 'Bootstrap complete. Run scripts/doctor.sh next.'
