# CLAUDE-deep — Tier 3 Reference

Documento carregado apenas quando explicitamente necessário (consulta profunda). Não é injetado automaticamente no contexto.

## Quando ler este arquivo

- Durante review arquitetural de grande porte
- Ao propor decisões técnicas com impacto amplo
- Ao escalar dúvida de ambiguidade tipo 3 (opções com trade-offs)
- Ao revisar padrões de uma linguagem ou domínio específico em profundidade

---

## Padrões avançados de código

### Gestão de erros
- Falhe o mais cedo possível (fail-fast) em fronteiras do sistema.
- Não logue e relance — ou trata, ou propaga, nunca os dois.
- Use exceções específicas — nunca `except Exception` genérico sem re-raise.
- Retornos com `Result<T, E>` ou tagged unions quando a linguagem suporta, em vez de exceções para fluxos esperados.

### Observabilidade
- Logs estruturados (JSON) em produção, não print / console.log.
- Nunca logue dados sensíveis: senhas, tokens, PII, payloads completos.
- Métricas: counter, gauge, histogram — escolha o tipo certo para cada medida.
- Tracing: propague trace IDs através de fronteiras de serviço.

### Performance
- Meça antes de otimizar. Perfil > intuição.
- Complexidade algorítmica é o primeiro alvo, micro-otimizações são os últimos.
- Cache invalidation é o problema real — prefira cache curto a cache errado.
- Paralelize apenas quando o overhead de coordenação é menor que o ganho.

---

## Heurísticas de decisão arquitetural

### Monolito vs microserviços
- Comece com monolito modular. Divida quando:
  - Equipes separadas precisam deployar independentemente
  - Escalabilidade vertical do monolito tornou-se gargalo real (medido)
  - Domínios têm requisitos de disponibilidade muito diferentes
- Nunca divida por moda. Divida por dor medida.

### SQL vs NoSQL
- Relacional é default. Vá para NoSQL quando:
  - Schema genuinamente não é conhecido (document store)
  - Escala horizontal extrema com acesso simples por chave (KV)
  - Grafos profundos (graph DB)
- A maioria dos casos resolve com Postgres + schema bem modelado.

### Sync vs Async
- Sync por default — é mais simples de debugar.
- Async quando:
  - Latência externa domina (múltiplas chamadas I/O)
  - Desacoplamento temporal é requisito (mensageria, eventos)
  - Backpressure / rate limiting exige fila

---

## Contexto de sistemas complexos

### Quando memória é mais valiosa que contexto
Em sessões longas, o contexto ativo degrada. Memória semântica persistente resolve isso armazenando conclusões, não raciocínios. Regras:
- Salve decisões e seus motivos — não salve tentativas falhas a menos que sejam instrutivas.
- Tag por domínio e projeto — facilita filtragem na hora da query.
- Prefira memórias curtas e específicas a memórias longas e generalistas.

### Quando compactar vs continuar
- Compactar antes de 80% do contexto — mais cedo não compensa, mais tarde perde informação.
- Após compactação, re-valide entendimento com uma frase: "Resumindo o que retornamos: ...".
- PreCompact hook pode salvar estado; PostCompact pode recuperar.

---

## Histórico de decisões do projeto

### Por que sentence-transformers em vez de ChromaDB
Ver `docs/decisions/02-mempalace-analysis.md`. Resumo: ChromaDB usa SQLite binário que não sincroniza via git. Usamos sentence-transformers direto + numpy `vectors.npy` para obter os mesmos embeddings sem a camada de storage não-sincronizável.

### Por que numpy em vez de TurboQuant como primário
Ver `docs/decisions/03-turboquant-analysis.md`. Resumo: TurboQuant tem `save()` quebrado no Windows e a compressão não compensa para índices pequenos (<10K entries). Mantemos como opcional para exportação futura.

### Por que ruah em vez de git worktree manual
Ver `docs/decisions/01-ruah-analysis.md`. Resumo: ruah oferece DAG de tasks com file claiming pronto. Reimplementar manualmente com git worktree exigiria ~500 linhas de bash.

---

## Padrões não óbvios de projeto

### Regra: clone obrigatório em ~/dotfiles
Hooks do `settings.json` usam `$HOME/dotfiles/scripts/memory_bridge.py` como caminho fixo. Se o usuário clonar em outro lugar, a injeção de memória falha silenciosamente (sem erro). Documentado no README mas vale reforçar em mudanças de arquitetura de paths.

### Regra: PreCompact salva marcador genérico
Hooks não têm acesso ao histórico da conversa. O PreCompact store apenas "Session compacted for X" — isso é um ponto de referência temporal, não um resumo real. Resumo real vem via `/handoff` manual.

### Regra: embedder é lazy
`_get_embedder()` só carrega sentence-transformers na primeira chamada de `get_embedding()`. Importar `memory_bridge` como módulo não dispara download do modelo. Preserva tempo de testes e scripts rápidos.
