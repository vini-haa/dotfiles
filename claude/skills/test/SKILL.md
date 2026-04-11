---
name: test
description: Gera testes para código existente ou roda a suite de testes do projeto.
argument-hint: "[arquivo para gerar testes | 'run' para rodar suite]"
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash, Agent
model: sonnet
effort: high
---

# Test

## Se o argumento for "run" ou vazio
Detecte e rode a suite de testes do projeto:
```bash
# Detectar framework
[ -f pytest.ini ] || [ -f pyproject.toml ] && pytest -v
[ -f package.json ] && npm test
[ -f go.mod ] && go test -v ./...
```

Mostre resultado formatado:
```
## Resultado dos testes
- Total:   X
- Passed:  X ✅
- Failed:  X ❌
- Skipped: X ⏭️
- Tempo:   Xs
```

## Se um arquivo for fornecido
Gere testes para: `$ARGUMENTS`

### Processo
1. Leia o arquivo e entenda as funções/classes públicas.
2. Identifique o framework de teste do projeto (pytest, jest, vitest, go test).
3. Gere testes cobrindo:
   - **Happy path**: fluxo principal funcionando
   - **Edge cases**: null, vazio, limites, tipos errados
   - **Erros**: exceções esperadas, error handling
4. Use o padrão AAA (Arrange → Act → Assert).
5. Nomes descritivos: `test_should_return_404_when_user_not_found`.
6. Coloque o arquivo de teste no local correto do projeto:
   - Python: `tests/test_<nome>.py` ou ao lado `<nome>_test.py`
   - JS/TS: `__tests__/<nome>.test.ts` ou `<nome>.spec.ts`
   - Go: `<nome>_test.go` no mesmo pacote

### Após gerar
Rode os testes para validar que passam:
```bash
# Rode apenas os testes gerados
```
