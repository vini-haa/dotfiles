#!/usr/bin/env bash
# Hook universal de lint/format para Claude Code
# Executado automaticamente após Write, Edit e MultiEdit
# Recebe JSON via stdin conforme documentação oficial

# Ler input do stdin (formato oficial do Claude Code)
INPUT=$(cat)

# Extrair file_path do JSON (jq preferido, fallback para python3)
# Write e Edit têm tool_input.file_path direto
# MultiEdit tem tool_input.edits[0].file_path
if command -v jq &>/dev/null; then
    FILE_PATH=$(echo "$INPUT" | jq -r '
        .tool_input.file_path //
        (.tool_input.edits[0].file_path // empty)
    ' 2>/dev/null)
else
    FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
fp = data.get('tool_input', {}).get('file_path', '')
if not fp:
    edits = data.get('tool_input', {}).get('edits', [])
    if edits and isinstance(edits, list):
        fp = edits[0].get('file_path', '')
print(fp)
" 2>/dev/null)
fi

# Sair silenciosamente se não há arquivo para processar
[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# Detectar extensão
EXT="${FILE_PATH##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

# Verificar se a extensão é suportada
case "$EXT" in
    py|ts|tsx|js|jsx|go|sql) ;;
    *) exit 0 ;;
esac

echo "🔧 [$EXT] $FILE_PATH"

case "$EXT" in
    py)
        if command -v ruff &>/dev/null; then
            ruff check --fix --quiet "$FILE_PATH" 2>/dev/null
            ruff format --quiet "$FILE_PATH" 2>/dev/null
            echo "✅ ruff lint+format concluído"
        else
            echo "⚠️ ruff não encontrado — pulando lint Python"
        fi
        ;;

    ts|tsx|js|jsx)
        # Subir pelo dirname até encontrar package.json
        PROJECT_DIR="$FILE_PATH"
        FOUND_PROJECT=""
        while true; do
            PROJECT_DIR=$(dirname "$PROJECT_DIR")
            if [ -f "$PROJECT_DIR/package.json" ]; then
                FOUND_PROJECT="$PROJECT_DIR"
                break
            fi
            # Chegou na raiz sem encontrar
            if [ "$PROJECT_DIR" = "/" ] || [ "$PROJECT_DIR" = "." ]; then
                break
            fi
        done

        if [ -z "$FOUND_PROJECT" ]; then
            echo "⚠️ package.json não encontrado — pulando lint JS/TS"
        else
            if command -v npx &>/dev/null; then
                # ESLint
                npx --prefix "$FOUND_PROJECT" eslint --fix --quiet "$FILE_PATH" 2>/dev/null
                eslint_status=$?
                # Prettier
                npx --prefix "$FOUND_PROJECT" prettier --write --log-level silent "$FILE_PATH" 2>/dev/null
                prettier_status=$?

                if [ $eslint_status -eq 0 ] && [ $prettier_status -eq 0 ]; then
                    echo "✅ eslint+prettier concluído"
                else
                    echo "⚠️ eslint/prettier concluído com avisos"
                fi
            else
                echo "⚠️ npx não encontrado — instale Node.js"
            fi
        fi
        ;;

    go)
        if command -v gofmt &>/dev/null; then
            gofmt -w "$FILE_PATH" 2>/dev/null
            echo "✅ gofmt concluído"
        else
            echo "⚠️ gofmt não encontrado — instale Go"
        fi

        if command -v golangci-lint &>/dev/null; then
            golangci-lint run --fix --quiet "$(dirname "$FILE_PATH")/..." 2>/dev/null
            echo "✅ golangci-lint concluído"
        else
            echo "⚠️ golangci-lint não encontrado — pulando lint Go"
        fi
        ;;

    sql)
        if command -v sqlfluff &>/dev/null; then
            # Auto-detectar dialeto pelo path
            DIALECT="ansi"
            case "$FILE_PATH" in
                *mssql*|*sqlserver*) DIALECT="tsql" ;;
                *postgres*|*/pg/*) DIALECT="postgres" ;;
            esac

            sqlfluff fix --dialect "$DIALECT" --quiet "$FILE_PATH" 2>/dev/null
            echo "✅ sqlfluff fix concluído (dialeto: $DIALECT)"
        else
            echo "⚠️ sqlfluff não encontrado — pulando lint SQL"
        fi
        ;;
esac

exit 0
