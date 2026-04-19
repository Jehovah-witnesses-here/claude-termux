# claude-termux

Run [Claude Code](https://claude.ai/code) natively on Termux (Android ARM64).

Works with all versions — legacy JS builds and native musl ELF builds (2.1.114+). No Ubuntu chroot, no proot-distro — just base Termux.

## Install

```bash
git clone https://github.com/Jehovah-witnesses-here/claude-termux
cd claude-termux
bash install.sh
```

Restart your shell, then:

```bash
claude
```

## What it does

| Problem | Fix |
|---|---|
| `/tmp`, `/etc` don't exist | proot maps `$PREFIX/tmp` and `$PREFIX/etc` |
| musl ELF binary can't find libc | Alpine musl libc downloaded once, mapped via proot |
| `LD_PRELOAD` bionic conflict | Cleared with `env -u LD_PRELOAD` before exec |
| `audio-capture.node` dlopen fails | JS stub intercepts the failed load |
| `arm64-android` vs `arm64-linux` | Vendor symlink auto-created after installs |

## Auto-update

`claude-proot` runs `claude-update` in the background on each launch. The updater:

1. Checks npm for the latest 2.x version
2. Installs it in a sandbox and tests it
3. Only promotes to global if the test passes
4. Falls back to current version if the new one crashes

## Manual update

```bash
claude-update
```

## Files

```
~/.local/bin/claude-proot          # launcher (alias: claude)
~/.local/bin/claude-update         # safe updater
~/.local/share/claude-termux/
  android-native-stub.js           # .node addon stub
  musl/lib/                        # Alpine musl libc (auto-downloaded)
  native/                          # musl binary cache
```

## Configuration

| Env var | Default | Description |
|---|---|---|
| `CLAUDE_TERMUX_HOME` | `~/.local/share/claude-termux` | Data directory |
| `PREFIX` | `/data/data/com.termux/files/usr` | Termux prefix |

## Compatibility

Tested on: Pixel 7, Android 14, Termux 0.118+

Should work on any ARM64 Android device running Termux.

## Design goals

- **Native first** — reduce proot mappings as Termux evolves
- **Portable** — no hardcoded paths, configurable via env vars
- **Safe updates** — never install a version that crashes on this device
- **Zero dependencies** — only proot + nodejs (both standard Termux packages)
