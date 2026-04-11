---
description: Framework de regras — hierarquia formal e schema de definição.
---

# Rules Framework

## Hierarquia de Regras (3 tiers)

### Tier 1 — Commandments (🔴 Obrigatório)
- **Força**: Bloqueiam review. Violação = FAIL automático.
- **Override**: Impossível. Não existe justificativa válida.
- **Exemplo**: "Nunca faça hardcode de secrets", "Use prepared statements".

### Tier 2 — Edicts (🟡 Esperado)
- **Força**: Precisam de justificativa visível para serem ignorados.
- **Override**: Possível COM justificativa documentada. Sem justificativa = bloqueador.
- **Exemplo**: "Use variáveis de ambiente para credenciais", "CORS explícito".

### Tier 3 — Counsel (🔵 Recomendado)
- **Força**: Sugestões de melhoria. NUNCA bloqueiam review.
- **Override**: Livre. Apenas warnings informativos.
- **Exemplo**: "Headers de segurança", "Rate limiting".

## Schema de Regras

### Frontmatter (obrigatório)
```yaml
---
paths:
  - "**/*.py"        # glob pattern de ativação
---
```

### Body (obrigatório)
```markdown
# Nome da Regra

## 🔴 Obrigatório (bloqueia review se violado)
- [regras tier 1]

## 🟡 Esperado (deve corrigir salvo justificativa)
- [regras tier 2]

## 🔵 Recomendado (sugestão de melhoria)
- [regras tier 3]
```

## Princípios

- **Uma regra que precisa de múltiplas páginas é provavelmente uma skill.** Rules são constraints curtos e verificáveis.
- **Rules são carregadas sob demanda.** O Claude carrega automaticamente quando lê arquivos que batem com o `paths`.
- **Findings devem ser rastreáveis.** Todo finding de review DEVE apontar para uma regra documentada. Findings sem base em rule = nota (tier 3), nunca bloqueador.

## Rules existentes

| Rule | Paths | Foco |
|------|-------|------|
| `python.md` | `**/*.py` | Type hints, f-strings, pathlib |
| `typescript.md` | `**/*.ts/*.tsx/*.js/*.jsx` | Interface vs type, const, React |
| `go.md` | `**/*.go` | Error handling, interfaces, tests |
| `sql.md` | `**/*.sql` | Keywords uppercase, CTEs, índices |
| `security.md` | `**/*` | OWASP, sanitização, secrets |
| `testing.md` | Arquivos de teste | AAA, naming, fixtures |
