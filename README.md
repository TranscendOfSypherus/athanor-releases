# Athanor releases

This repo hosts release binaries for **Athanor** — a web-based platform for managing agentic
coding sessions. Binaries only: the source repo is private, and this public repo exists so
installs and `athanor upgrade` can fetch releases unauthenticated (public repo ≠ open source).

> Source-repo note: this file is the releases repo's README. It lives at
> `docs/releases-repo-README.md` in the source tree; push changes to
> `TranscendOfSypherus/athanor-releases` when it changes.

## Install

Download the binary for your platform from the latest release, then:

```sh
mkdir -p ~/.athanor/bin
mv athanor-linux-x64 ~/.athanor/bin/athanor   # or athanor-linux-arm64
chmod +x ~/.athanor/bin/athanor
~/.athanor/bin/athanor serve
```

First run creates `~/.athanor` (config, database, managed zmx), persists port **7784**, and
prints the URL. Add `~/.athanor/bin` to your PATH if you want plain `athanor` on the command
line.

The server runs on **linux x64/arm64** (macOS arm64 joins when its PTY port lands). On
**Windows**, run the server inside WSL2 (or on a remote linux host) and open the printed URL
from the Windows side — the server never runs natively on Windows.

Requirements on the host: `git`, `ps`, a shell. Everything else (including the patched zmx
that backs terminal persistence) is embedded in the binary.

## Upgrade

```sh
athanor upgrade    # downloads + verifies the latest release, then: restart athanor serve
```

`athanor serve` prints a one-line notice on start when a newer release exists. Disable with
`"checkUpdates": false` in `~/.athanor/config.json`. Upgrades are never automatic.

## Verify a download

`sha256sums.txt` in each release lists the checksums:

```sh
sha256sum -c sha256sums.txt --ignore-missing
```

## Third-party licenses

Each release ships the license texts of embedded third-party software (`zmx-LICENSE.txt` for
[zmx](https://github.com/neurosnap/zmx), which Athanor embeds as a patched build).
