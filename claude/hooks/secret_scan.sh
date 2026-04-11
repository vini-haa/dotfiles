#!/usr/bin/env bash
#
# secret_scan.sh — PostToolUse hook for Claude Code
#
# Purpose: Scan files written or edited by Claude for credential patterns.
# Runs after Write/Edit tool operations. Warns via stderr without blocking
# (exit 0) so that writes are never prevented, only flagged for review.
#
# Inspired by Claude Code's internal secretScanner.ts (gitleaks-based rules).

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. Extract file path from stdin JSON
# ---------------------------------------------------------------------------

INPUT="$(cat)"

if command -v jq &>/dev/null; then
    FILE_PATH=$(printf '%s' "$INPUT" | jq -r '
        .tool_input.file_path //
        (.tool_input.edits[0].file_path // empty)
    ' 2>/dev/null)
else
    FILE_PATH=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
path = ti.get('file_path') or ''
if not path:
    edits = ti.get('edits', [])
    if edits:
        path = edits[0].get('file_path', '')
print(path)
" 2>/dev/null || true)
fi

[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

# ---------------------------------------------------------------------------
# 2. Skip binary files
# ---------------------------------------------------------------------------

BINARY_EXT='png|jpg|jpeg|gif|ico|woff|woff2|ttf|otf|eot|pdf|zip|tar|gz|bz2|xz|7z|exe|dll|so|dylib|bin|dat|db|sqlite'

EXT="${FILE_PATH##*.}"
if printf '%s' "$EXT" | grep -qiE "^($BINARY_EXT)$"; then
    exit 0
fi

if command -v file >/dev/null 2>&1; then
    MIME="$(file --mime-type -b "$FILE_PATH" 2>/dev/null || true)"
    case "$MIME" in
        text/*|application/json|application/xml|application/javascript) ;;
        *) exit 0 ;;
    esac
fi

# ---------------------------------------------------------------------------
# 3. Choose grep variant
# ---------------------------------------------------------------------------

if grep -P '' /dev/null 2>/dev/null; then
    GP="-P"
else
    GP="-E"
fi

# ---------------------------------------------------------------------------
# 4. Pattern definitions — name|regex
# ---------------------------------------------------------------------------

declare -a PATTERNS=(
    "AWS Access Key|AKIA[0-9A-Z]{16}"
    "AWS Secret Key|(aws_secret|AWS_SECRET)[^=:]*[=:]\s*['\"]?[A-Za-z0-9/+=]{40}"
    "Anthropic API Key|sk-ant-api[a-zA-Z0-9_-]{20,}"
    "GitHub PAT|ghp_[a-zA-Z0-9]{36}"
    "GitHub OAuth Token|gho_[a-zA-Z0-9]{36}"
    "OpenAI API Key|sk-[a-zA-Z0-9]{48}"
    "Slack Bot Token|xoxb-[0-9]{10,}"
    "Slack User Token|xoxp-[0-9]{10,}"
    "Stripe Live Secret|sk_live_[a-zA-Z0-9]{24,}"
    "Stripe Live Publishable|pk_live_[a-zA-Z0-9]{24,}"
    "Private Key Block|-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
    "DB Connection String|(postgres|mysql|mongodb)://[^:]+:[^@]+@"
    "Generic Auth Token|(api_key|apikey|api_secret|access_token|auth_token)\s*[=:]\s*['\"][a-zA-Z0-9_-]{20,}['\"]"
)

# ---------------------------------------------------------------------------
# 5. Scan and warn
# ---------------------------------------------------------------------------

FOUND=0

for entry in "${PATTERNS[@]}"; do
    pname="${entry%%|*}"
    pregex="${entry#*|}"

    if grep -ql $GP "$pregex" "$FILE_PATH" 2>/dev/null; then
        if [ "$FOUND" -eq 0 ]; then
            echo "" >&2
        fi
        echo "⚠️  ALERTA: Possível segredo detectado em $FILE_PATH" >&2
        echo "   Padrão: $pname" >&2
        echo "   Revise o arquivo antes de commitar." >&2
        FOUND=1
    fi
done

exit 0
