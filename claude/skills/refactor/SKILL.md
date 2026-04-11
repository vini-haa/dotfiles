---
name: refactor
description: Analisa e refatora código para melhorar qualidade, legibilidade e manutenibilidade sem mudar comportamento.
argument-hint: "<arquivo ou diretório>"
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash, Agent
model: sonnet
effort: high
---

# Refactor

Refatore o código em `$ARGUMENTS` mantendo o comportamento idêntico.

## Processo

### 1. Análise
Leia o código e identifique:
- Duplicação de lógica
- Funções muito longas (>30 linhas)
- Complexidade ciclomática alta (muitos if/else aninhados)
- Nomes pouco descritivos
- Responsabilidades misturadas (god classes/functions)
- Dead code (código não utilizado)
- Dependências circulares

### 2. Plano
Antes de editar, apresente um plano:
```
## Plano de refatoração
1. [O que] — [Por que]
2. [O que] — [Por que]
...
Arquivos afetados: X
Risco: baixo/médio/alto
```

Aguarde confirmação do usuário antes de prosseguir.

### 3. Execução
- Uma mudança lógica por vez.
- Mantenha o comportamento externo idêntico.
- Se houver testes, rode após cada mudança significativa.
- Nomeie extrações de forma descritiva.

### 4. Validação
- Rode os testes existentes.
- Mostre diff resumido das mudanças.

## Técnicas comuns
- Extract Method/Function
- Rename para clareza
- Replace conditional com polimorfismo ou strategy
- Introduce Parameter Object
- Remove dead code
- Split module por responsabilidade
