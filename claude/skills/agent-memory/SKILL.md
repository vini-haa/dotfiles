---
name: agent-memory
description: Gerencia memória persistente entre sessões — long-term e session memory.
argument-hint: "[load|save|review]"
user-invocable: true
allowed-tools: Read, Write, Grep, Glob, Bash
model: sonnet
effort: medium
context: fork
---

# Agent Memory — Memória Persistente

Gerencie a memória persistente do projeto: `$ARGUMENTS`

## Arquitetura de 2 camadas

### Camada 1 — Long-term Memory
**Arquivo**: `.memory/long-term.md`

Acumula insights reutilizáveis entre TODAS as sessões:

```markdown
# Long-term Memory

## Preferências do Usuário
[Como o usuário gosta de trabalhar, estilo de código preferido]

## Feedback Acumulado
[Correções recebidas, padrões validados, abordagens rejeitadas]

## Regras Descobertas
[Constraints aprendidos que não estão no CLAUDE.md]

## Issues Conhecidos
[Bugs, quirks, workarounds do projeto]

## Notas do Projeto
[Arquitetura, padrões, decisões, gotchas]
```

### Camada 2 — Session Memory
**Diretório**: `.memory/session/`
**Formato**: `.memory/session/YYYY-MM-DD-<slug>.md`

```markdown
# Session: [slug]
**Status**: active | paused | done
**Início**: [data]

## Trabalho Atual
## Todos Ativos
- [ ] [item]

## Log de Eventos
- [timestamp] [evento]
```

## Protocolo de Sinais

| Tier | Exemplo | Ação |
|------|---------|------|
| **Forte** (explícito) | "Sempre use Tailwind neste projeto" | Gravar imediatamente |
| **Médio** (correção) | Usuário corrige sua abordagem | Gravar padrão aprendido |
| **Fraco** (implícito) | Usuário aceita sem comentar | Observar; gravar só se repetir 3x |

## Ciclo de Vida

### No início (load)
1. Verificar se `.memory/` existe; criar se necessário
2. Ler `.memory/long-term.md` para contexto
3. Verificar sessões pausadas em `.memory/session/`
4. Oferecer: retomar sessão pausada ou iniciar nova

### Durante (observe)
1. Observar sinais do usuário (forte/médio/fraco)
2. Atualizar session memory a cada marco significativo
3. Nunca gravar dados sensíveis (tokens, senhas, PII)

### No fim (save)
1. Destilar session log em insights para long-term
2. Filtro: "Isso ajudará trabalho futuro?" — se não, descarte
3. Marcar sessão como `done` ou `paused`

## Regras
- Apenas insights acionáveis entram na memória
- Dados sensíveis NUNCA entram em `.memory/`
- Entradas devem ser concisas (1-2 linhas cada)
- Máximo 80 entradas em long-term (prune as mais antigas)
- `.memory/` deve estar no `.gitignore` do projeto
