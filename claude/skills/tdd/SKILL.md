---
name: tdd
description: Test-Driven Development — ciclo RED-GREEN-REFACTOR estrito.
argument-hint: "<funcionalidade a implementar>"
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash, Agent
model: sonnet
effort: high
context: fork
---

# TDD — Test-Driven Development

Implemente usando TDD estrito: `$ARGUMENTS`

## Ciclo RED → GREEN → REFACTOR

### 🔴 RED — Escreva o teste PRIMEIRO
1. Entenda o comportamento esperado
2. Escreva UM teste que descreva esse comportamento
3. **Execute o teste — DEVE FALHAR**
4. Se o teste passar sem implementação → o teste está errado

```bash
# Verificar que o teste falha
npm test -- --run [arquivo]  # ou pytest, go test
```

**REGRA**: Nunca prossiga para GREEN se o teste não falhou primeiro.

### 🟢 GREEN — Implementação mínima
1. Escreva o MÍNIMO de código para o teste passar
2. Não otimize, não embeleze, não generalize
3. **Execute o teste — DEVE PASSAR**
4. Se não passar → corrija a implementação (não o teste)

**REGRA**: O fix mínimo. Se o teste espera `return 42`, retorne `42` literal.

### 🔵 REFACTOR — Melhore sem mudar comportamento
1. Todos os testes passando? Pode refatorar
2. Melhore: naming, duplicação, estrutura
3. **Execute os testes novamente — DEVEM continuar passando**
4. Se algum teste quebrou → desfaça o refactor

**REGRA**: Refactor só com todos os testes verdes.

## Protocolo

### 1 teste por vez
Não escreva 5 testes e depois implemente tudo. O ciclo é:
```
1 teste RED → 1 implementação GREEN → refactor → próximo teste
```

### Naming de testes
Descreva o comportamento, não o método:
- ✅ `should return 404 when user not found`
- ✅ `should calculate total with discount applied`
- ❌ `test_get_user`
- ❌ `testCalculate`

### Cobertura de cenários (ordem)
1. **Happy path** — o caso mais comum
2. **Edge cases** — null, vazio, limites, zero
3. **Erros** — exceções, timeouts, inputs inválidos
4. **Concorrência** — race conditions (se aplicável)

## Anti-padrões (PROIBIDO)

| Anti-padrão | Correto |
|---|---|
| Escrever implementação antes do teste | Teste primeiro, sempre |
| Teste que nunca falha (tautologia) | Teste deve ser falsificável |
| Múltiplos testes antes de implementar | 1 teste por vez |
| Refatorar com testes falhando | Verde antes de refatorar |
| Testar implementação interna | Testar comportamento observável |

## Quando usar
- Feature nova que precisa de cobertura garantida
- Bug fix (escreva teste que reproduz o bug → fix → verde)
- Lógica complexa onde edge cases importam
