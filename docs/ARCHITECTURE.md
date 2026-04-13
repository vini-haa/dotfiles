# Arquitetura — Sistema de Memória Unificado

## Visão geral

O dotfiles configura o Claude Code com um ecossistema completo de produtividade:
hooks automáticos, agentes especializados, skills de workflow e memória semântica
persistente entre sessões e máquinas.

## Diagrama de componentes

```
┌──────────────────────────────────────────────────────────────┐
│                      Claude Code CLI                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │   Hooks      │  │   Skills    │  │      Agents          │ │
│  │             │  │             │  │                      │ │
│  │ SessionStart│  │ /review     │  │ frontend  backend    │ │
│  │ PostToolUse │  │ /ship       │  │ database  architect  │ │
│  │ PreToolUse  │  │ /refactor   │  │ devops    security   │ │
│  │ PreCompact  │  │ /test       │  │ company-context      │ │
│  │ Stop        │  │ /debug      │  │                      │ │
│  │ UserPrompt  │  │ /handoff    │  └──────────────────────┘ │
│  │             │  │ /security   │                           │
│  └──────┬──────┘  │ /sync-mem   │                           │
│         │         │ /loop-recov │                           │
│         │         └─────────────┘                           │
│         │                                                    │
│  ┌──────▼──────────────────────────────────────────────────┐ │
│  │              memory_bridge.py                           │ │
│  │  store | query | rebuild | sync | status                │ │
│  └──────┬────────────────┬─────────────────┬───────────────┘ │
│         │                │                 │                 │
│  ┌──────▼──────┐  ┌──────▼──────┐  ┌───────▼─────────────┐  │
│  │ sent-trans  │  │ ~/memory/   │  │ Obsidian (opcional)  │  │
│  │ + numpy     │  │ (git repo)  │  │                      │  │
│  │ index.json  │  │ projetos/   │  │ vault/claude-memory/ │  │
│  │ vectors.npy │  │ session/    │  │                      │  │
│  └─────────────┘  │ global/     │  └──────────────────────┘  │
│                    └─────────────┘                            │
│                                                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              ruah_bridge.sh (opcional)                   │ │
│  │  Coordena sessões paralelas com worktrees isolados      │ │
│  │  start → injeta memória | complete → persiste contexto  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Rules     │  │   Config    │  │     Shell           │  │
│  │  python.md  │  │  ruff.toml  │  │  .bashrc_extras     │  │
│  │  ts.md      │  │  .sqlfluff  │  │  aliases            │  │
│  │  go/sql/etc │  │  golangci   │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## Fluxo de dados por evento

### SessionStart
1. Hook injeta mensagem estática (agentes/skills disponíveis)
2. memory_bridge.py query → busca contexto do projeto atual
3. Resultado injetado como contexto adicional na sessão

### PreCompact
1. Hook reforça regras (PT-BR, agentes, skills)
2. memory_bridge.py store → salva resumo da sessão antes de compactar

### Stop
1. Hook detecta TODO/FIXME pendentes
2. Auto-commit do ~/memory/ (se houver mudanças)

### /handoff
1. Gera HANDOFF.md com estado da sessão
2. memory_bridge.py store → persiste na memória semântica

### /sync-memory
1. git pull --rebase no ~/memory/
2. Rebuild incremental dos embeddings
3. Sync bidirecional com Obsidian
4. Relatório de status

## Decisões técnicas

| Decisão | Alternativas | Justificativa |
|---------|-------------|---------------|
| sentence-transformers + numpy como vector store | ChromaDB, mempalace, qdrant | Formato git-syncable (index.json + vectors.npy), sem SQLite binário, embeddings locais |
| turboquant-vectors (opcional) | turboquant-py, numpy | Funciona no Python 3.14, 4-8x compressão para export |
| ruah para coordenação | git worktree manual | CLI pronta com file claiming e DAG de merge |
| ~/memory/ como git repo | banco local, cloud | Portável, versionado, push/pull simples |
| Fallback char-trigram | — | Garante funcionamento sem dependências extras |

Detalhes completos em:
- [docs/decisions/01-ruah-analysis.md](decisions/01-ruah-analysis.md)
- [docs/decisions/02-mempalace-analysis.md](decisions/02-mempalace-analysis.md)
- [docs/decisions/03-turboquant-analysis.md](decisions/03-turboquant-analysis.md)

## Dependências externas

| Pacote | Obrigatório | Fallback |
|--------|------------|----------|
| sentence-transformers (MiniLM-L6-v2) | Não | Fallback char-trigram hashing |
| turboquant-vectors | Não | Sem compressão (vetores raw) |
| @levi-tc/ruah | Não | Sem coordenação paralela |

## Roadmap

- [ ] MCP server próprio para memory_bridge (query/store via tools)
- [ ] Integração com mempalace quando Windows build estiver disponível
- [ ] Dashboard de memória via Obsidian plugin
- [ ] Compressão TurboQuant para sync de vetores entre máquinas
- [ ] Métricas de uso (quantas queries/stores por sessão)
