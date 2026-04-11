---
name: ship
description: Prepara o código para deploy — roda lint, testes, valida build e cria commit/PR se tudo passar.
argument-hint: "[mensagem de commit opcional]"
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash
model: sonnet
effort: high
---

# Ship — Preparar para deploy

Execute o pipeline completo de validação antes de entregar o código.

## Pipeline
Execute cada etapa em ordem. Pare se alguma falhar.

### 1. Status
```bash
git status
git diff --stat
```
Mostre o que será entregue.

### 2. Lint & Format
Rode as ferramentas de lint do projeto:
- Python: `ruff check --fix && ruff format`
- JS/TS: `npx eslint --fix && npx prettier --write`
- Go: `gofmt -w && golangci-lint run --fix`
- SQL: `sqlfluff fix`

Detecte pelo projeto quais linguagens existem.

### 3. Testes
Detecte e rode a suite de testes:
- Python: `pytest` ou `python -m pytest`
- JS/TS: `npm test` ou `npx vitest run` ou `npx jest`
- Go: `go test ./...`

### 4. Build (se aplicável)
- JS/TS: `npm run build` ou `npx tsc --noEmit`
- Go: `go build ./...`
- Python: verificar syntax com `python -m py_compile`

### 5. Commit
Se todas as etapas passaram:
- Stage os arquivos alterados
- Crie o commit com a mensagem fornecida ou gere uma baseada nos changes
- Use prefixos convencionais: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`

### 6. Relatório final
```
## Ship Report
- Lint:    ✅/❌
- Testes:  ✅/❌ (X passed, Y failed)
- Build:   ✅/❌/N/A
- Commit:  [hash] mensagem
```

Se algo falhou, mostre o erro e sugira como corrigir.
