#!/data/data/com.termux/files/usr/bin/bash
# claude-termux installer
# Makes Claude Code work natively on Termux (Android ARM64).
# Supports all versions: legacy JS and native musl ELF (2.1.114+).
#
# Usage: bash install.sh

set -e
PREFIX=${PREFIX:-/data/data/com.termux/files/usr}
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/claude-termux"
BIN_DIR="$HOME/.local/bin"

echo "==> claude-termux installer"
echo ""

# 1. Required Termux packages
echo "==> Installing required packages..."
pkg install -y proot patchelf nodejs-lts 2>/dev/null || pkg install -y proot patchelf nodejs 2>/dev/null
echo "    proot + patchelf + nodejs: OK"

# 2. Create data directory
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# 3. Copy scripts
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "$SCRIPT_DIR/bin/claude-proot"   "$BIN_DIR/claude-proot"
cp "$SCRIPT_DIR/bin/claude-update"  "$BIN_DIR/claude-update"
cp "$SCRIPT_DIR/bin/claude-recover" "$BIN_DIR/claude-recover"
cp "$SCRIPT_DIR/lib/android-native-stub.js" "$INSTALL_DIR/android-native-stub.js"
chmod +x "$BIN_DIR/claude-proot" "$BIN_DIR/claude-update" "$BIN_DIR/claude-recover"
echo "    Scripts installed to $BIN_DIR"

# 4. Ensure ~/.local/bin is on PATH
SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
if ! grep -q 'claude-termux' "$SHELL_RC" 2>/dev/null; then
  {
    echo ""
    echo "# claude-termux"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    echo "alias claude='claude-proot'"
  } >> "$SHELL_RC"
  echo "    PATH + alias added to $SHELL_RC"
fi
export PATH="$HOME/.local/bin:$PATH"

# 5. Install Claude Code via npm
echo ""
echo "==> Installing Claude Code..."
npm install -g @anthropic-ai/claude-code 2>&1 | grep -v "Unsupported platform" || true

# 6. Verify
echo ""
echo "==> Verifying..."
VERSION=$(CLAUDE_UPDATING=1 "$BIN_DIR/claude-proot" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ -n "$VERSION" ]; then
  echo "    Claude Code $VERSION: OK"
else
  echo "    WARNING: version check failed — check output above for errors."
fi

echo ""
echo "Done! Restart your shell or run: source $SHELL_RC"
echo "Then use: claude"
