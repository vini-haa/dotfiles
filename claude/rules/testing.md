---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/*_test.*"
  - "**/test_*"
  - "**/tests/**"
  - "**/__tests__/**"
---

# Testes

## 🔴 Obrigatório (bloqueia review se violado)
- Nomeie testes descrevendo comportamento: `should return 404 when user not found`.
- Testes devem ser independentes — sem dependência de ordem de execução.
- Estrutura AAA: Arrange → Act → Assert.
- Mocks apenas para dependências externas não-controladas (APIs terceiras).

## 🟡 Esperado (deve corrigir salvo justificativa)
- Um assert lógico por teste (pode ter múltiplos asserts se validam a mesma coisa).
- Prefira testes de integração sobre mocks para I/O real (DB, HTTP).
- Teste edge cases: null, vazio, limites, concorrência.
- Fixtures: use factories/builders em vez de dados hardcoded repetidos.

## 🔵 Recomendado (sugestão de melhoria)
- Testes devem ser rápidos — se demorar, mova para suite de integração.
- Coverage não é métrica de qualidade — cubra comportamentos, não linhas.
- Considere property-based testing para funções com domínio amplo.
