#!/bin/sh
# Athanor installer (ADR 0026): download the latest release binary for this
# platform, verify it against the release's sha256sums.txt, and install it to
# ~/.athanor/bin/athanor. Safe to re-run — it upgrades in place.
#
#   curl -fsSL https://raw.githubusercontent.com/TranscendOfSypherus/athanor-releases/main/install.sh | sh
#
# ATHANOR_HOME overrides the install root (default ~/.athanor).
#
# Source-repo note: this file mirrors `docs/releases-repo-install.sh` in the
# source tree — edit there and push here.
set -eu

REPO="TranscendOfSypherus/athanor-releases"

fail() {
  printf 'install.sh: %s\n' "$*" >&2
  exit 1
}

os=$(uname -s)
arch=$(uname -m)
case "$os" in
  Linux)
    case "$arch" in
      x86_64) asset="athanor-linux-x64" ;;
      aarch64 | arm64) asset="athanor-linux-arm64" ;;
      *) fail "unsupported Linux architecture: $arch (releases cover x86_64 and aarch64)" ;;
    esac
    ;;
  Darwin)
    case "$arch" in
      arm64) asset="athanor-mac-arm64" ;;
      *) fail "unsupported macOS architecture: $arch (releases cover Apple Silicon only)" ;;
    esac
    ;;
  MINGW* | MSYS* | CYGWIN* | Windows_NT)
    fail "athanor is unix-only — on Windows, run this installer inside WSL2 (https://learn.microsoft.com/windows/wsl/install)"
    ;;
  *)
    fail "unsupported OS: $os (releases cover Linux and macOS; Windows runs inside WSL2)"
    ;;
esac

command -v curl >/dev/null 2>&1 || fail "curl is required"
if command -v sha256sum >/dev/null 2>&1; then
  sha_cmd="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  sha_cmd="shasum -a 256"
else
  fail "sha256sum or shasum is required to verify the download"
fi

# Resolve the latest tag through the release redirect so the binary and its
# checksum are downloaded from the same release, never a moving "latest".
tag=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest") ||
  fail "could not reach github.com to resolve the latest release"
tag=${tag##*/}
case "$tag" in
  v*) ;;
  *) fail "could not resolve the latest release tag (got: $tag)" ;;
esac

base="https://github.com/$REPO/releases/download/$tag"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

printf 'downloading %s %s ...\n' "$asset" "$tag"
curl -fsSL --retry 3 -o "$tmp/$asset" "$base/$asset" ||
  fail "download failed: $base/$asset"
curl -fsSL --retry 3 -o "$tmp/sha256sums.txt" "$base/sha256sums.txt" ||
  fail "download failed: $base/sha256sums.txt"

expected=$(awk -v a="$asset" '$2 == a { print $1 }' "$tmp/sha256sums.txt")
[ -n "$expected" ] || fail "sha256sums.txt has no entry for $asset"
actual=$($sha_cmd "$tmp/$asset" | awk '{ print $1 }')
[ "$actual" = "$expected" ] ||
  fail "checksum mismatch for $asset: expected $expected, got $actual"

bin_dir="${ATHANOR_HOME:-$HOME/.athanor}/bin"
mkdir -p "$bin_dir"
# Stage beside the target, then rename — atomic, and a running athanor keeps
# its old inode (the same swap `athanor upgrade` does).
mv -f "$tmp/$asset" "$bin_dir/athanor.new"
chmod 755 "$bin_dir/athanor.new"
if [ "$os" = "Darwin" ]; then
  # The binary is unsigned; clear Gatekeeper's quarantine flag.
  xattr -d com.apple.quarantine "$bin_dir/athanor.new" 2>/dev/null || true
fi
mv -f "$bin_dir/athanor.new" "$bin_dir/athanor"

printf 'installed athanor %s to %s\n' "$tag" "$bin_dir/athanor"
case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) printf 'add %s to your PATH to get plain `athanor` on the command line\n' "$bin_dir" ;;
esac
printf 'run `athanor` to start\n'
