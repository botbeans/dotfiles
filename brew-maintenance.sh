#!/bin/zsh

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
LOGFILE="$HOME/Library/Logs/brew-maintenance.log"
BREW="/opt/homebrew/bin/brew"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
  echo "[$TIMESTAMP] $1" | tee -a "$LOGFILE"
}

log "=== Brew maintenance started ==="

# Update Homebrew and upgrade all packages
log "Running brew update..."
$BREW update >> "$LOGFILE" 2>&1

log "Running brew upgrade..."
$BREW upgrade >> "$LOGFILE" 2>&1

# Dump current Brewfile
log "Dumping Brewfile to $DOTFILES_DIR..."
cd "$DOTFILES_DIR"
$BREW bundle dump --force --file="$DOTFILES_DIR/Brewfile" >> "$LOGFILE" 2>&1

# Commit and push if there are changes
if git -C "$DOTFILES_DIR" diff --quiet -- Brewfile; then
  log "No changes to Brewfile. Skipping commit."
else
  log "Brewfile changed. Committing and pushing..."
  git -C "$DOTFILES_DIR" add Brewfile
  git -C "$DOTFILES_DIR" commit -m "chore: update Brewfile ($(date '+%Y-%m-%d'))" >> "$LOGFILE" 2>&1
  git -C "$DOTFILES_DIR" push >> "$LOGFILE" 2>&1
  log "Changes pushed successfully."
fi

# Cleanup
log "Running brew cleanup..."
$BREW cleanup >> "$LOGFILE" 2>&1

log "=== Brew maintenance completed ==="
