---
name: brainstorm
description: Ideação criativa estruturada — gera, avalia e prioriza ideias.
argument-hint: "<problema ou tema>"
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
model: opus
effort: high
context: fork
---

# Brainstorm — Ideação Criativa

Explore soluções criativas para: `$ARGUMENTS`

## Processo

### Fase 1 — Entender o problema
1. Reformule o problema em 1 frase clara
2. Identifique constraints conhecidos (tempo, tech, equipe, orçamento)
3. Defina critérios de sucesso: como saber que a solução funciona?

### Fase 2 — Gerar ideias (sem filtro)
Gere **pelo menos 5 ideias** sem julgar viabilidade:
- Inclua abordagens conservadoras E ousadas
- Considere: soluções existentes, analogias de outros domínios, inversão do problema
- Cada ideia em 1-2 frases

### Fase 3 — Avaliar
Para cada ideia, avalie em 3 dimensões:

| Ideia | Viabilidade (1-5) | Impacto (1-5) | Esforço (1-5) | Score |
|-------|-------------------|---------------|---------------|-------|
| ... | ... | ... | ... | V×I/E |

- **Viabilidade**: é tecnicamente possível com os constraints?
- **Impacto**: resolve o problema de verdade?
- **Esforço**: quanto trabalho? (1=muito, 5=pouco)
- **Score**: Viabilidade × Impacto / Esforço

### Fase 4 — Recomendar
1. Top 3 ideias por score
2. Para cada uma: próximos passos concretos (1-3 ações)
3. Riscos principais e mitigações

## Formato de saída

```
## Brainstorm: [tema]

### Problema
[1 frase clara]

### Constraints
- [constraint 1]
- [constraint 2]

### Ideias
1. **[Nome]** — [descrição]
2. **[Nome]** — [descrição]
...

### Avaliação
[tabela com scores]

### Recomendação
**Top pick**: [ideia] — Score X.X
- Próximo passo 1: [ação]
- Próximo passo 2: [ação]
- Risco: [risco] → Mitigação: [como]

**Alternativa**: [ideia 2]
- ...
```

## Regras
- Quantidade antes de qualidade na Fase 2
- Avaliação honesta — não infle scores para sua ideia favorita
- Se o problema é técnico, considere soluções não-técnicas também
- Se o problema é de processo, considere automação
