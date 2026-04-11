#!/usr/bin/env bash
# session_start.sh — SessionStart hook for Claude Code
# Detects project stack and reports context automatically.

CONTEXT="Hooks ativos: lint automático, proteção de arquivos sensíveis, bash security, secret scanner."
CONTEXT="$CONTEXT Agentes: frontend, backend, database, architect, devops, security."
CONTEXT="$CONTEXT Skills: /review, /ship, /refactor, /test, /security, /debug, /handoff, /compact, /perf."
CONTEXT="$CONTEXT Responda sempre em português brasileiro."

# --- Stack detection ---
STACK=""

if [ -f "package.json" ]; then
    STACK="$STACK Node.js"
    # Detect framework
    for fw in next react vue angular express nestjs fastify; do
        if grep -q "\"$fw\"" package.json 2>/dev/null || grep -q "\"@${fw}/" package.json 2>/dev/null; then
            STACK="$STACK ($fw)"
            break
        fi
    done
    STACK="$STACK;"
fi

if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
    STACK="$STACK Python"
    for fw in django fastapi flask; do
        if grep -qi "$fw" requirements.txt 2>/dev/null || grep -qi "$fw" pyproject.toml 2>/dev/null; then
            STACK="$STACK ($fw)"
            break
        fi
    done
    STACK="$STACK;"
fi

if [ -f "go.mod" ]; then
    MOD_NAME=$(head -1 go.mod 2>/dev/null | awk '{print $2}')
    STACK="$STACK Go ($MOD_NAME);"
fi

if [ -f "Cargo.toml" ]; then
    STACK="$STACK Rust;"
fi

if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] || [ -f "compose.yml" ]; then
    STACK="$STACK Docker Compose;"
fi

if [ -f "Dockerfile" ]; then
    STACK="$STACK Dockerfile;"
fi

if [ -d ".github/workflows" ]; then
    STACK="$STACK GitHub Actions CI/CD;"
fi

if [ -f "terraform.tf" ] || [ -d ".terraform" ]; then
    STACK="$STACK Terraform;"
fi

if [ -n "$STACK" ]; then
    CONTEXT="$CONTEXT Stack detectado:$STACK"
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}' "$CONTEXT"
