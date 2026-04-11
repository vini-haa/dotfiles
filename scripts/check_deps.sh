#!/usr/bin/env bash
# Verifica dependências de lint/format
# Não instala nada — apenas informa o que está faltando

echo "=== Verificação de dependências de lint/format ==="
echo ""

MISSING=0

check_tool() {
    local tool="$1"
    local install_hint="$2"
    local display_name
    display_name=$(printf "%-15s" "$tool")

    if command -v "$tool" &>/dev/null; then
        echo "[✅] $display_name encontrado"
    else
        echo "[❌] $display_name não encontrado — instale com: $install_hint"
        MISSING=$((MISSING + 1))
    fi
}

check_tool "jq"             "sudo apt install jq (ou brew install jq)"
check_tool "ruff"           "pip install ruff"
check_tool "sqlfluff"       "pip install sqlfluff"
check_tool "golangci-lint"  "go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
check_tool "gofmt"          "instale Go (https://go.dev/dl/)"
check_tool "npx"            "instale Node.js (https://nodejs.org/)"

echo ""
if [ "$MISSING" -eq 0 ]; then
    echo "✅ Todas as dependências estão instaladas!"
else
    echo "⚠️  $MISSING dependência(s) não encontrada(s) — veja os comandos acima."
fi
