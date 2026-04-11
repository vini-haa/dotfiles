---
name: contextualize
description: Gera arquivos .context.md por diretório para orientação rápida.
argument-hint: "[diretório raiz opcional]"
user-invocable: true
allowed-tools: Read, Write, Grep, Glob, Bash, Agent
model: sonnet
effort: high
context: fork
---

# Contextualize — Orientação por Diretório

Gere arquivos `.context.md` para o projeto: `$ARGUMENTS`

## O que é um .context.md

Arquivo de orientação rápida por diretório. Não é documentação completa — é um guia de navegação para humanos e agentes entenderem rapidamente o que cada pasta faz.

## Schema

```markdown
<!-- .context.md — gerado em YYYY-MM-DD -->
## Purpose
[1-2 frases: o que este diretório contém e por quê]

## Files
- `arquivo.ts` — [responsabilidade em 1 linha]
- `outro.ts` — [responsabilidade em 1 linha]

## Subdirectories
- `sub/` — [propósito em 1 linha]

## Constraints (opcional)
- MUST: [regra obrigatória deste módulo]
- MUST NOT: [proibição]

## Guidance (opcional)
- SHOULD: [recomendação]
```

## Processo

### 1. Determinar escopo
- Se `$ARGUMENTS` fornecido, usar como raiz
- Se não, usar diretório atual do projeto
- Excluir: `node_modules/`, `.git/`, `dist/`, `__pycache__/`, `.memory/`

### 2. Percorrer diretórios
Para cada diretório com arquivos de código:
1. Listar arquivos e subdiretórios
2. Ler os primeiros ~50 linhas de cada arquivo-chave
3. Identificar propósito pela estrutura, imports e exports
4. Gerar `.context.md` seguindo o schema

### 3. Regras de geração
- **Nunca inventar propósito** — se não souber, escreva "Purpose unclear — needs investigation"
- **Brevidade** — cada entrada em 1 linha
- **Atualizar, não recriar** — se `.context.md` já existe, comparar e atualizar apenas mudanças
- **Mesmo commit** — `.context.md` deve estar no mesmo commit que mudanças estruturais

### 4. Relatório
```
## Contextualize — Relatório

### Diretórios cobertos
- [X] `src/` — [status: criado/atualizado/inalterado]
- [X] `src/utils/` — [status]

### Cobertura
[X/Y] diretórios com .context.md

### Pendências
- `src/legacy/` — propósito unclear, precisa de investigação
```

## Quando usar
- Projeto novo sem documentação
- Onboarding de novos membros
- Antes de refatoração grande (mapear terreno)
- Após mudanças estruturais significativas
