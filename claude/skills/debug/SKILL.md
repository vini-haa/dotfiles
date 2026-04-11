---
name: debug
description: Investigação e resolução de bugs — analisa erro, identifica causa raiz e propõe fix.
argument-hint: "<descrição do erro ou arquivo com o bug>"
user-invocable: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash, Agent
model: sonnet
effort: high
---

# Debug

Investigue e resolva o bug: `$ARGUMENTS`

## Metodologia

### 1. Reproduzir
- Entenda o erro reportado (mensagem, stacktrace, comportamento).
- Se possível, reproduza localmente.
- Identifique quando funciona vs quando falha.

### 2. Isolar
- Localize o arquivo e linha onde o erro ocorre.
- Trace o fluxo de dados: de onde vem o input? Por onde passa?
- Use `git log` e `git blame` para entender mudanças recentes no trecho.

### 3. Diagnosticar
Identifique a **causa raiz** (não o sintoma):
- Estado inesperado? Race condition?
- Input não validado? Tipo errado?
- Dependência externa falhando?
- Mudança recente que quebrou contrato?
- Edge case não tratado?

### 4. Corrigir
- Fix mínimo e focado — não refatore durante debug.
- Adicione teste que reproduz o bug ANTES do fix.
- Verifique que o teste falha sem o fix e passa com ele.

### 5. Relatório
```
## 🐛 Debug Report
**Erro**: [descrição]
**Causa raiz**: [explicação]
**Arquivo**: [path:linha]
**Fix**: [o que foi feito]
**Teste**: [teste adicionado]
**Prevenção**: [como evitar no futuro]
```

## Dicas
- Leia o stacktrace de baixo para cima.
- `git bisect` para encontrar commit que introduziu o bug.
- Adicione logs temporários se necessário (remova depois).
- Desconfie do óbvio — o bug muitas vezes está um nível acima.
