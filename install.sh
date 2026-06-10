#!/bin/bash
# install.sh — set up fdvs-personal plugin symlinks
# Run once after cloning the repo.
# Usage: bash install.sh

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
PLUGIN_TARGET="$HOME/.claude/plugins/fdvs-personal"

echo "Installing fdvs-personal plugin..."

# Symlink the plugin folder into ~/.claude/plugins/
mkdir -p "$HOME/.claude/plugins"

if [ -d "$PLUGIN_TARGET" ] && [ ! -L "$PLUGIN_TARGET" ]; then
  echo "ERROR: $PLUGIN_TARGET exists as a real directory (not a symlink)."
  echo "Move or rename it first, then re-run this script."
  exit 1
fi

if [ -L "$PLUGIN_TARGET" ]; then
  echo "  Removing existing plugin symlink"
  rm "$PLUGIN_TARGET"
fi
ln -s "$PLUGIN_DIR" "$PLUGIN_TARGET"
echo "  ✓ Plugin symlinked: $PLUGIN_TARGET → $PLUGIN_DIR"

# Symlink individual skills into ~/.claude/skills/ (required by Claude Code skill discovery)
mkdir -p "$SKILLS_DIR"
for skill_path in "$PLUGIN_DIR/skills"/*/; do
  skill_name="$(basename "$skill_path")"
  target="$SKILLS_DIR/$skill_name"

  if [ -d "$target" ] && [ ! -L "$target" ]; then
    echo "ERROR: $target exists as a real directory. Move or rename it first."
    exit 1
  fi

  if [ -L "$target" ]; then
    rm "$target"
  fi
  ln -s "$skill_path" "$target"
  echo "  ✓ Skill symlinked: ~/.claude/skills/$skill_name"
done

echo ""
echo "Done. Restart Claude Code to pick up the new skills."
echo ""
echo "Next step: copy config.yaml to config.local.yaml and fill in your values:"
echo "  cp $PLUGIN_DIR/config.yaml $PLUGIN_DIR/config.local.yaml"
echo "  edit $PLUGIN_DIR/config.local.yaml"
