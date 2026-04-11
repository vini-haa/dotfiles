#!/usr/bin/env bash
#
# bash_security.sh — Claude Code PreToolUse hook
#
# Intercepts Bash tool calls before execution and blocks commands that match
# dangerous patterns. Reads the Claude Code JSON payload from stdin, extracts
# the command string, and exits 2 (block) with a message when a threat is found.
#
# Triggered by: PreToolUse / Bash
# Exit codes:
#   0 — command is safe, allow execution
#   2 — command is dangerous, block execution
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Read JSON from stdin and extract the command string.
# Claude Code sends: { "tool_input": { "command": "<cmd>" }, ... }
# ---------------------------------------------------------------------------

raw_input="$(cat)"

# Prefer jq for correctness; fall back to a simple grep-based extraction so
# the hook still works on minimal environments without jq installed.
if command -v jq &>/dev/null; then
    command_text="$(printf '%s' "$raw_input" | jq -r '.tool_input.command // empty')"
else
    # Naive extraction: grab the value after "command": up to the closing quote.
    # Good enough for single-line commands; jq is strongly preferred.
    command_text="$(printf '%s' "$raw_input" | grep -oP '"command"\s*:\s*"\K[^"]*' 2>/dev/null || true)"
fi

# Nothing to check if we could not extract a command.
if [[ -z "$command_text" ]]; then
    exit 0
fi

# ---------------------------------------------------------------------------
# Helper: block with a human-readable reason.
# ---------------------------------------------------------------------------
block() {
    echo "BLOQUEADO: $1" >&2
    exit 2
}

# ---------------------------------------------------------------------------
# Use grep -qP (PCRE) when available; otherwise fall back to grep -qE (ERE).
# ---------------------------------------------------------------------------
_grep_dangerous() {
    local pattern="$1"
    if grep -qP "$pattern" <<< "$command_text" 2>/dev/null; then
        return 0
    fi
    return 1
}

_grep_dangerous_E() {
    local pattern="$1"
    grep -qE "$pattern" <<< "$command_text" 2>/dev/null
}

# ---------------------------------------------------------------------------
# 1. Command substitution in dangerous contexts
# ---------------------------------------------------------------------------
if _grep_dangerous '\$\((rm|mkfs|dd )[^)]*\)' || \
   _grep_dangerous_E '\$\((rm|mkfs|dd )[^)]*\)'; then
    block "command substitution with destructive command (\$(rm / \$(mkfs / \$(dd))"
fi

# ---------------------------------------------------------------------------
# 2. Pipes to shell interpreters
# ---------------------------------------------------------------------------
if _grep_dangerous '\|\s*(bash|sh|zsh)\b' || \
   _grep_dangerous_E '\|\s*(bash|sh|zsh)\b'; then
    block "piping output into a shell interpreter (| bash / | sh / | zsh)"
fi

# ---------------------------------------------------------------------------
# 3. Writing to protected directories
# ---------------------------------------------------------------------------
if _grep_dangerous '(>>?|tee\s+|cp\s+\S+\s+|mv\s+\S+\s+|install\s+)\s*/etc/' || \
   _grep_dangerous_E '(>>?|tee |cp |mv |install )\s*/etc/'; then
    block "writing to /etc/"
fi

if _grep_dangerous '(>>?|tee\s+|cp\s+\S+\s+|mv\s+\S+\s+)\s*(~|/root|/home/[^/]+)/\.ssh/' || \
   _grep_dangerous_E '(>>?|tee |cp |mv )\s*(~|/root)/\.ssh/'; then
    block "writing to ~/.ssh/"
fi

if _grep_dangerous '(>>?|tee\s+|cp\s+\S+\s+|mv\s+\S+\s+)\s*(~|/root|/home/[^/]+)/\.gnupg/' || \
   _grep_dangerous_E '(>>?|tee |cp |mv )\s*(~|/root)/\.gnupg/'; then
    block "writing to ~/.gnupg/"
fi

if _grep_dangerous '(>>?|tee\s+|cp\s+\S+\s+|mv\s+\S+\s+|install\s+)\s*/usr/' || \
   _grep_dangerous_E '(>>?|tee |cp |mv |install )\s*/usr/'; then
    block "writing to /usr/"
fi

if _grep_dangerous '(>>?|tee\s+|cp\s+\S+\s+|mv\s+\S+\s+)\s*/boot/' || \
   _grep_dangerous_E '(>>?|tee |cp |mv )\s*/boot/'; then
    block "writing to /boot/"
fi

# ---------------------------------------------------------------------------
# 4. Mass permission changes
# ---------------------------------------------------------------------------
if _grep_dangerous 'chmod\s+-R\s+(777|666)\b' || \
   _grep_dangerous_E 'chmod\s+-R\s+(777|666)'; then
    block "mass permission change (chmod -R 777 / chmod -R 666)"
fi

if _grep_dangerous 'chown\s+-R\b' || \
   _grep_dangerous_E 'chown\s+-R'; then
    block "recursive ownership change (chown -R)"
fi

# ---------------------------------------------------------------------------
# 5. Unicode invisible characters (zero-width spaces, soft hyphens, etc.)
# ---------------------------------------------------------------------------
if printf '%s' "$command_text" | grep -qP '[\x{200B}-\x{200D}\x{FEFF}\x{00AD}\x{2028}\x{2029}]' 2>/dev/null; then
    block "invisible Unicode characters detected in command"
fi

# ---------------------------------------------------------------------------
# 6. Disk-destructive commands
# ---------------------------------------------------------------------------
if _grep_dangerous '\bmkfs\b' || _grep_dangerous_E '\bmkfs\b'; then
    block "disk format command (mkfs)"
fi

if _grep_dangerous '\bdd\s+if=' || _grep_dangerous_E '\bdd\s+if='; then
    block "disk-dump/overwrite command (dd if=)"
fi

if _grep_dangerous '>\s*/dev/sd[a-z]' || _grep_dangerous_E '>\s*/dev/sd[a-z]'; then
    block "redirecting output to a raw block device (> /dev/sd*)"
fi

# ---------------------------------------------------------------------------
# 7. Fork bombs
# ---------------------------------------------------------------------------
if _grep_dangerous ':\(\)\s*\{.*:\|:.*\}' || \
   _grep_dangerous_E ':\(\)\s*\{' || \
   _grep_dangerous '\(\s*\)\s*\{[^}]*\|\s*&' ; then
    block "fork bomb pattern detected"
fi

# Catch the classic :(){ :|:& };: pattern written with various spacing.
if grep -qF ':|:&' <<< "$command_text" 2>/dev/null; then
    block "fork bomb pattern detected (:|:&)"
fi

# ---------------------------------------------------------------------------
# 8. Process kill-all commands
# ---------------------------------------------------------------------------
if _grep_dangerous '\bkillall\b' || _grep_dangerous_E '\bkillall\b'; then
    block "process kill-all command (killall)"
fi

if _grep_dangerous '\bpkill\s+-9\b' || _grep_dangerous_E '\bpkill\s+-9\b'; then
    block "force kill-all processes (pkill -9)"
fi

# ---------------------------------------------------------------------------
# 9. Shell history manipulation
# ---------------------------------------------------------------------------
if _grep_dangerous '\bhistory\s+-(c|w)\b' || _grep_dangerous_E '\bhistory\s+-(c|w)\b'; then
    block "shell history manipulation (history -c / history -w)"
fi

# ---------------------------------------------------------------------------
# 10. Network backdoor setup
# ---------------------------------------------------------------------------
if _grep_dangerous '\b(nc|ncat)\s+.*-l\b' || _grep_dangerous_E '\b(nc|ncat)\s+.*-l\b'; then
    block "network listener / potential backdoor (nc -l / ncat -l)"
fi

# ---------------------------------------------------------------------------
# Command passed all checks — allow execution.
# ---------------------------------------------------------------------------
exit 0
