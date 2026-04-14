---
name: handoff
description: Gera documento de handoff para continuar o trabalho em nova sessão. Use quando o contexto estiver grande ou antes de limpar a sessão.
argument-hint: "[nome do arquivo de handoff opcional]"
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
effort: high
---

# Session Handoff

Gere um documento completo de handoff para que uma nova sessão possa continuar exatamente de onde paramos.

## Processo

### 1. Coletar estado atual
```bash
# Branch e status
git branch --show-current
git status --short
git log --oneline -10

# Arquivos modificados não commitados
git diff --name-only
git diff --cached --name-only
```

### 2. Analisar a conversa
Revise toda a conversa atual e extraia:
- O que foi pedido originalmente
- O que já foi implementado
- O que ficou pendente
- Decisões tomadas e seus motivos
- Problemas encontrados e como foram resolvidos
- Problemas encontrados e NÃO resolvidos

### 3. Gerar documento

Salve como `HANDOFF.md` no diretório atual (ou no nome fornecido em `$ARGUMENTS`):

```markdown
# Handoff — [Data]

## Contexto
[O que estamos fazendo e por quê]

## Estado atual
- Branch: `feature/x`
- Último commit: `abc1234 feat: ...`
- Arquivos modificados não commitados: [lista]

## O que foi feito
1. [Tarefa] — [status: completo/parcial]
2. ...

## O que falta fazer
1. [ ] [Tarefa pendente] — [contexto necessário]
2. [ ] ...

## Decisões tomadas
| Decisão | Motivo | Alternativa descartada |
|---|---|---|
| ... | ... | ... |

## Problemas conhecidos
- [Problema] — [status: resolvido/pendente] — [contexto]

## Para continuar
Cole este prompt na nova sessão:
> Leia o arquivo HANDOFF.md neste diretório. Ele contém o contexto
> da sessão anterior. Continue de onde paramos.

## Arquivos-chave
[Lista dos arquivos mais relevantes para a tarefa em andamento]
```

### 4. Confirmar
Mostre um resumo do handoff ao usuário antes de salvar.

## Pós-handoff: Persistência na memória

Após criar o arquivo de handoff, persista na memória semântica:

```bash
python3 ~/dotfiles/scripts/memory_bridge.py store \
    --text "$(cat ARQUIVO_HANDOFF_CRIADO)" \
    --tags "handoff,$(basename $PWD),$(date +%Y-%m-%d)" \
    --project "$(basename $PWD)"
```

Para recuperar o handoff completo em uma nova sessão (com texto integral, não só resumo):

```bash
python3 ~/dotfiles/scripts/memory_bridge.py query \
    --text "handoff $(basename $PWD)" \
    --top-k 1 \
    --project "$(basename $PWD)" \
    --detail full
```

Confirme: "✓ Sessão persistida na memória semântica"
