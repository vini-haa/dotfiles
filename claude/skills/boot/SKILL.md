---
name: boot
description: Inicialização de sessão — verifica ambiente, carrega memória e contexto.
user-invocable: true
allowed-tools: Read, Write, Grep, Glob, Bash
model: sonnet
effort: medium
---

# Boot — Inicialização de Sessão

Execute a sequência de boot para garantir que o ambiente está configurado.

## Checklist (7 passos)

### 1. Consultar memória semântica
Antes de qualquer outra inicialização, busque contexto acumulado do projeto:
```bash
python3 ~/dotfiles/scripts/memory_bridge.py query \
    --text "$(basename $PWD) contexto projeto stack decisoes" \
    --top-k 8 \
    --project "$(basename $PWD)" \
    --format markdown
```
- Se houver resultados: incorpore como contexto antes de prosseguir
- Se não houver: prossiga normalmente (projeto novo ou sem histórico)

### 2. Verificar .gitignore
Garantir que `.memory/` está no `.gitignore`:
```bash
grep -q '.memory/' .gitignore 2>/dev/null || echo '.memory/' >> .gitignore
```

### 3. Criar estrutura de memória
```bash
mkdir -p .memory/session .memory/todo .memory/plan
```

### 4. Carregar memória long-term
- Ler `.memory/long-term.md` se existir
- Aplicar preferências e feedback ao comportamento
- Se não existir, criar com template vazio (skill `/agent-memory`)

### 5. Verificar sessões pausadas
- Listar `.memory/session/*.md` com status `paused` ou `active`
- Se encontrar: "Sessão anterior detectada: [slug]. Retomar ou iniciar nova?"
- Se não encontrar: prosseguir

### 6. Indexar contexto do projeto
- Verificar arquivos `.context.md` no projeto
- Se ausentes: sugerir `/contextualize`
- Detectar stack (package.json, go.mod, pyproject.toml, etc.)

### 7. Saudação
Reportar estado ao usuário:
- Memória: carregada / vazia / sessão pausada encontrada
- Stack: detectado / não identificado
- Solicitar instruções

## Quando usar
- Início de sessão em projeto novo
- Após longo período sem trabalhar no projeto
- Quando o contexto parece degradado
- Manualmente: `/boot`
