#!/usr/bin/env bash
# claude_md_reminder.sh — UserPromptSubmit hook
# Re-injeta CLAUDE.md do projeto a cada 3 prompts para prevenir context drift.
# Inspirado no Ring (LerianStudio) claude-md-reminder.sh.

SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
STATE_FILE="/tmp/.claude_reminder_${SESSION_ID}.count"

# Inicializar contador
[ ! -f "$STATE_FILE" ] && echo 0 > "$STATE_FILE"
COUNT=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

# Só atuar a cada 3 prompts
[ $((COUNT % 3)) -ne 0 ] && exit 0

# Buscar CLAUDE.md hierarquicamente
CLAUDE_MD=""
for candidate in "./CLAUDE.md" "../CLAUDE.md" "../../CLAUDE.md" "$HOME/.claude/CLAUDE.md"; do
    if [ -f "$candidate" ]; then
        CLAUDE_MD="$candidate"
        break
    fi
done

[ -z "$CLAUDE_MD" ] && exit 0

# Extrair primeiras 50 linhas (essência das regras)
RULES=$(head -50 "$CLAUDE_MD" 2>/dev/null | tr '"' "'" | tr '\n' ' ' | sed 's/[[:cntrl:]]/ /g')

# Montar contexto de reforço
CONTEXT="REFORÇO (prompt #${COUNT}): Responda em PT-BR. Regra dos 3 arquivos ativa. Auto-triggers de agentes ativos. Skills: /review /review-deep /ship /refactor /test /tdd /security /debug /handoff /compact /perf /dispatch /explore /contextualize /brainstorm /boot /agent-memory /task-tracking."

printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"%s"}}' "$CONTEXT"
