# Brew Maintenance Automation — Session Summary

**Date:** 2026-03-23

## Objective

Create an automated brew maintenance workflow that:
- Dumps the current Homebrew casks/packages to a Brewfile
- Runs `brew update` and `brew upgrade`
- Auto-commits and pushes changes to the dotfiles repo
- Runs on a weekly schedule via launchd

## Decisions Made

| Question | Answer |
|---|---|
| Frequency | Weekly |
| Day | Monday |
| Time | 9:00 AM |
| Git behavior | Auto-commit and push |
| Logging | `~/Library/Logs/brew-maintenance.log` |

## Files Created

### 1. `~/dotfiles/brew-maintenance.sh`

Zsh script that:
1. Runs `brew update` and `brew upgrade`
2. Runs `brew bundle dump --force` to overwrite the Brewfile
3. Checks for changes — if the Brewfile changed, commits and pushes
4. Runs `brew cleanup`
5. Logs all output to `~/Library/Logs/brew-maintenance.log`

### 2. `~/dotfiles/com.elvinsalcedo.brew-maintenance.plist`

Launchd agent configuration:
- **Label:** `com.elvinsalcedo.brew-maintenance`
- **Schedule:** Every Monday at 9:00 AM (`Weekday: 1, Hour: 9, Minute: 0`)
- **Stdout/Stderr:** Both routed to `~/Library/Logs/brew-maintenance.log`
- **PATH:** Includes `/opt/homebrew/bin` for Apple Silicon brew

## Setup Completed

- Script made executable (`chmod +x`)
- Plist validated with `plutil -lint`
- Plist symlinked to `~/Library/LaunchAgents/`
- Agent loaded with `launchctl load`

## Useful Commands

```bash
# Test the script manually
zsh ~/dotfiles/brew-maintenance.sh

# Check if the agent is loaded
launchctl list | grep brew-maintenance

# Unload the agent
launchctl unload ~/Library/LaunchAgents/com.elvinsalcedo.brew-maintenance.plist

# Reload after plist changes
launchctl unload ~/Library/LaunchAgents/com.elvinsalcedo.brew-maintenance.plist && \
launchctl load ~/Library/LaunchAgents/com.elvinsalcedo.brew-maintenance.plist

# View logs
tail -f ~/Library/Logs/brew-maintenance.log
```
