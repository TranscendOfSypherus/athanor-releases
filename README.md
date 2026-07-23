<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/athanor-dark.svg">
    <img alt="Athanor sigil" src="assets/athanor.svg" width="280">
  </picture>
</p>

# Athanor

> From the alchemical self-feeding furnace that maintains constant heat without manual fuelling.
> Pronounced "ATH-uh-nor."

A web-based platform for managing agentic coding sessions, evolving upward into a collaborative
software design and delivery environment — a modelled infinite canvas where humans and AI agents
work the same living objects, and the repository becomes a compiled artifact of the canvas.

Today that means: persistent terminal sessions in your browser that survive page refreshes,
server restarts, and disconnects — reattaching automatically with scrollback intact — with CLI
coding agents (Claude Code, OpenCode, Codex, …) running inside them, and session state observed
and organised by the platform.

This repository hosts the **release binaries**. One self-contained `athanor` binary carries the
server, the web UI, and its managed terminal-persistence backend — no other installs.

> Source-repo note: this file and `assets/` mirror `docs/releases-repo-README.md` in the source
> tree — edit there and push here.

## Setup

Requirements on the host: `git`, `ps`, and a shell. First run creates `~/.athanor` (config,
database, logs), persists port **7784**, and prints the URL to open.

### One-command install

```sh
curl -fsSL https://raw.githubusercontent.com/TranscendOfSypherus/athanor-releases/main/install.sh | sh
```

Downloads the latest release for your platform, verifies it against `sha256sums.txt`, and
installs to `~/.athanor/bin/athanor`. Or with [Homebrew](https://brew.sh) (macOS, Linux, WSL2):

```sh
brew install transcendofsypherus/athanor/athanor
```

Then run `athanor` to start. The manual per-platform steps below do the same thing by hand.

### Linux

Download the binary for your architecture from the
[latest release](https://github.com/TranscendOfSypherus/athanor-releases/releases/latest)
(`athanor-linux-x64` or `athanor-linux-arm64`):

```sh
mkdir -p ~/.athanor/bin
curl -fsSL -o ~/.athanor/bin/athanor \
  https://github.com/TranscendOfSypherus/athanor-releases/releases/latest/download/athanor-linux-x64
chmod +x ~/.athanor/bin/athanor
~/.athanor/bin/athanor serve
```

Add `~/.athanor/bin` to your PATH to get plain `athanor` on the command line.

### macOS (Apple Silicon)

```sh
mkdir -p ~/.athanor/bin
curl -fsSL -o ~/.athanor/bin/athanor \
  https://github.com/TranscendOfSypherus/athanor-releases/releases/latest/download/athanor-mac-arm64
chmod +x ~/.athanor/bin/athanor
xattr -d com.apple.quarantine ~/.athanor/bin/athanor 2>/dev/null
~/.athanor/bin/athanor serve
```

The binary is unsigned, hence the `xattr` line clearing Gatekeeper's quarantine flag.

### Windows (WSL2)

The server is unix-only by design; on Windows it runs inside
[WSL2](https://learn.microsoft.com/windows/wsl/install). Follow the Linux steps in your WSL2
distribution, then open the printed URL (`http://127.0.0.1:7784`) in your Windows browser —
WSL2 forwards localhost automatically.

## Upgrading

```sh
athanor upgrade    # download + verify the latest release, then restart athanor serve
```

`athanor serve` prints a one-line notice on start when a newer release exists — never more than
that, and upgrades are never automatic. Disable the notice with `"checkUpdates": false` in
`~/.athanor/config.json`.

## Verifying a download

Each release includes `sha256sums.txt`:

```sh
sha256sum -c sha256sums.txt --ignore-missing
```

## Licensing

The Athanor binaries are free to download and use — see [LICENSE](LICENSE.md). Athanor is not
open source; this public repository exists to host releases. Bundled open-source components
keep their own licenses — each release attaches a generated `THIRD_PARTY_NOTICES.md` derived
from that release's actual embedded dependency set: the npm packages in the server binary and
the web UI bundle, the bundled fonts (their licenses also ship beside the font files
themselves), [zmx](https://github.com/neurosnap/zmx) (MIT, shipped as a patched build), the
Deno runtime, and the Rust crates behind the desktop shells.
