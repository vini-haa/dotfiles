---
name: task-tracking
description: Persiste tarefas em arquivo para sobreviver entre sessões.
argument-hint: "[create|update|list|close]"
user-invocable: true
allowed-tools: Read, Write, Grep, Glob, Bash
model: sonnet
effort: medium
---

# Task Tracking — Todos Persistentes

Gerencie tarefas persistentes: `$ARGUMENTS`

## Por que usar (vs TodoWrite)
O TodoWrite do Claude Code é **volátil** — morre com a sessão. Para tarefas que duram dias/semanas, use este sistema baseado em arquivos.

## Estrutura

### Diretório
`.memory/todo/`

### Formato do arquivo
`.memory/todo/YYYY-MM-DD-<prefix>-<slug>.md`

Prefixos: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

### Template
```markdown
# [prefix]: [descrição curta]
**Status**: active | paused | done | cancelled
**Criado**: YYYY-MM-DD
**Atualizado**: YYYY-MM-DD

## Tarefas
- [x] Tarefa completa
- [ ] Tarefa pendente

## Log de Eventos
- [YYYY-MM-DD HH:MM] Criado — contexto inicial
- [YYYY-MM-DD HH:MM] Decisão — escolheu X porque Y
- [YYYY-MM-DD HH:MM] Bloqueio — esperando Z
- [YYYY-MM-DD HH:MM] Progresso — completou tarefas 1-3
```

## Workflow

### Criar (`create`)
1. Determinar prefixo e slug descritivo (kebab-case)
2. Criar arquivo com template
3. Registrar evento de criação

### Atualizar (`update`)
1. Localizar arquivo em `.memory/todo/`
2. Marcar checkboxes completadas
3. Adicionar entrada no log com timestamp

### Listar (`list`)
1. Listar arquivos em `.memory/todo/`
2. Filtrar por status (active por padrão)
3. Mostrar: nome, status, progresso (X/Y tarefas)

### Fechar (`close`)
1. Marcar todas as tarefas como completas ou canceladas
2. Mudar status para `done` ou `cancelled`
3. Registrar evento de fechamento

## Regras
- Atualizar status IMEDIATAMENTE (não batchear)
- Preservar arquivos com items incompletos
- Cada ação registrada no log com timestamp
- Manter arquivo mesmo após done (histórico)
