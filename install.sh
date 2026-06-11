#!/bin/sh
# axel installer -- downloads the right prebuilt binary for this machine and
# installs it as a drop-in replacement for axel.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/proximile/axel/master/install.sh | sh
#
# Environment overrides:
#   AXEL_VERSION     install a specific tag (e.g. v2.18.0); default: latest
#   AXEL_INSTALL_DIR target directory; default: /usr/local/bin (or ~/.local/bin)
set -eu

REPO="proximile/axel"
BASE="https://github.com/${REPO}"
API="https://api.github.com/repos/${REPO}"

err() { printf 'axel-install: %s\n' "$*" >&2; exit 1; }
info() { printf 'axel-install: %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# --- pick a downloader ------------------------------------------------------
if have curl; then
  dl() { curl -fsSL "$1" -o "$2"; }
  dlout() { curl -fsSL "$1"; }
elif have wget; then
  dl() { wget -qO "$2" "$1"; }
  dlout() { wget -qO- "$1"; }
else
  err "need curl or wget"
fi

# --- detect platform --------------------------------------------------------
os="$(uname -s)"
machine="$(uname -m)"

case "$os" in
  Linux)
    case "$machine" in
      x86_64|amd64)        target="linux-x86_64"  ;;
      aarch64|arm64)       target="linux-aarch64" ;;
      armv7l|armv7)        target="linux-armv7"   ;;
      armv6l|armv6|armel)  target="linux-armv6"   ;;  # Raspberry Pi Zero / 1
      *) err "unsupported Linux architecture: $machine" ;;
    esac
    ;;
  Darwin)
    target="macos-universal" ;;
  *)
    err "unsupported OS: $os (on Windows, use WSL or the .zip from the releases page)" ;;
esac

# --- resolve version --------------------------------------------------------
ver="${AXEL_VERSION:-}"
if [ -z "$ver" ]; then
  info "looking up the latest release..."
  # Buffer the response first; piping curl into grep -m1 makes curl exit 23
  # (SIGPIPE) when grep closes the pipe early.
  resp="$(dlout "${API}/releases/latest")" || err "could not reach GitHub"
  ver="$(printf '%s\n' "$resp" \
    | grep '"tag_name"' | head -n1 \
    | sed -E 's/.*"tag_name" *: *"([^"]+)".*/\1/')"
  [ -n "$ver" ] || err "could not determine the latest version"
fi
num="${ver#v}"

asset="axel-${num}-${target}.tar.gz"
url="${BASE}/releases/download/${ver}/${asset}"

# --- choose install dir -----------------------------------------------------
dir="${AXEL_INSTALL_DIR:-}"
sudo=""
if [ -z "$dir" ]; then
  if [ -w /usr/local/bin ] 2>/dev/null || [ "$(id -u)" = "0" ]; then
    dir="/usr/local/bin"
  elif have sudo && [ -d /usr/local/bin ]; then
    dir="/usr/local/bin"; sudo="sudo"
  else
    dir="$HOME/.local/bin"
  fi
fi
mkdir -p "$dir" 2>/dev/null || sudo="sudo"

# --- download + install -----------------------------------------------------
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
info "downloading $asset ($ver)..."
dl "$url" "$tmp/axel.tar.gz" || err "download failed: $url"
tar -C "$tmp" -xzf "$tmp/axel.tar.gz"
binpath="$(find "$tmp" -type f -name axel -perm -u+x 2>/dev/null | head -n1)"
[ -n "$binpath" ] || binpath="$(find "$tmp" -type f -name axel | head -n1)"
[ -n "$binpath" ] || err "binary not found in archive"

info "installing to $dir/axel"
$sudo install -Dm0755 "$binpath" "$dir/axel" 2>/dev/null \
  || { $sudo mkdir -p "$dir" && $sudo cp "$binpath" "$dir/axel" && $sudo chmod 0755 "$dir/axel"; }

# --- report -----------------------------------------------------------------
info "installed: $("$dir/axel" --version 2>/dev/null | head -1)"
case ":$PATH:" in
  *":$dir:"*) ;;
  *) info "note: $dir is not on your PATH -- add it to use 'axel' directly" ;;
esac
