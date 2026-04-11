# Análise Técnica: TurboQuant

**Data:** 2026-04-10
**Status:** Decidido — usar apenas para sync/export, não como armazenamento primário
**Pacotes testados:** `turboquant-py` v0.1.0, `turboquant-vectors` v0.3.0

---

## Pacotes testados

### turboquant-py v0.1.0

Instala sem erro, mas falha ao importar:

```
ModuleNotFoundError: No module named 'turboquant_py'
```

O pacote publica sob o nome `turboquant-py` no PyPI mas o módulo interno usa um nome diferente. Não há documentação clara sobre o nome correto de importação. **Descartado.**

### turboquant-vectors v0.3.0

Instala e importa corretamente. Este foi o pacote usado nos benchmarks abaixo.

---

## Benchmark: turboquant-vectors

Configuração do teste: 100 vetores, 1536 dimensões, quantização 4-bit.

### Resultados de memória e compressão

| Métrica | Valor | Observação |
|---|---|---|
| `compression_ratio` | 0.065 | Significa 6.5% do tamanho original em forma packed |
| `original_bytes` | 614.400 (600 KB) | 100 × 1536 dims × 4 bytes (float32) |
| `packed_memory_bytes` | 77.200 (75.4 KB) | ~8x de compressão em forma packed |
| `memory_bytes` (in-process) | 9.514.448 (~9 MB) | Maior porque inclui codebook, rotação e índices |
| Serialização manual (índices + codebook + normas) | 154.064 bytes (~150 KB) | ~4x de compressão vs original |

A diferença entre `packed_memory_bytes` (~75 KB) e `memory_bytes` (~9 MB) ocorre porque o objeto em memória carrega estruturas auxiliares: codebook float32[16], matriz de rotação e normas por vetor. O tamanho packed representa apenas os índices uint8 comprimidos.

### Resultados de velocidade

| Operação | Tempo (100 vetores, 1536 dims) |
|---|---|
| Compressão (fit + transform) | ~5.500 ms |
| Busca (query) | ~3.630 ms |

Esses tempos são **lentos** para 100 vetores. Para contexto, ChromaDB completa busca em coleções similares em dezenas de milissegundos. A lentidão indica overhead de Python puro ou ausência de otimização SIMD — não investigado a fundo pois o caso de uso mudou.

### Problema no Windows: `.save()` quebrado

```python
index.save("./tq_test.bin")
# Executa sem erro, mas o arquivo não é criado
```

O método `.save()` silencia o erro de escrita no Windows. Não há exception, não há arquivo. Isso inviabiliza o uso do `.save()` nativo para persistência. A serialização manual funcionou:

```python
np.savez("tq_test.bin", 
    indices=index.indices,      # uint8
    codebook=index.codebook,    # float32[16]
    norms=index.norms           # float32[N]
)
```

O arquivo `tq_test.bin.npz` presente na raiz do repositório é o artefato deste teste.

---

## Incompatibilidade de dimensões com nosso stack

Nosso stack de memória usa ChromaDB com o modelo `all-MiniLM-L6-v2` — **384 dimensões**. O benchmark do TurboQuant foi feito com 1536 dims (tamanho típico de embeddings OpenAI `text-embedding-ada-002`).

TurboQuant funciona com qualquer dimensão, mas a relação custo/benefício muda. Com 384 dims, o overhead de compressão é menor em termos absolutos, e a velocidade do ChromaDB já é adequada para nossas coleções esperadas (< 100k vetores).

---

## Decisão de uso

**ChromaDB é o primário.** Cuida de armazenamento, busca e persistência. Não há razão para adicionar uma camada de compressão no caminho crítico de busca.

**TurboQuant-vectors como camada opcional de sync/export.** O único caso de uso justificável é comprimir snapshots do índice ChromaDB para transferência entre máquinas (ex: sincronização via git de snapshots comprimidos). Nesse cenário:

1. Exportar vetores do ChromaDB → serializar com TurboQuant → commitar snapshot `.npz`
2. Em nova máquina → carregar `.npz` → reconstruir coleção ChromaDB

Isso reduz o tamanho do snapshot de ~4x a ~8x, dependendo do método de serialização usado.

### Fluxo de fallback completo

```
ChromaDB (primário)
  ↓ falha de instalação ou runtime
numpy cosine similarity + .npz manual (fallback)
  ↓ precisa de sync entre máquinas
turboquant-vectors comprimido em .npz (opcional, para export)
```

---

## Estrutura interna do índice TurboQuant

Para referência futura ao implementar a serialização manual:

| Atributo | Tipo | Descrição |
|---|---|---|
| `indices` | `uint8[N, M]` | Índices quantizados dos vetores |
| `codebook` | `float32[16]` | Centroides do codebook (PQ) |
| `norms` | `float32[N]` | Norma L2 de cada vetor original |
| `rotation` | `float32[D, D]` | Matriz de rotação aleatória pré-aplicada |

A reconstrução aproximada de um vetor original passa por: desquantizar via codebook → aplicar rotação inversa → normalizar via norma.

---

## Artefato de teste

O arquivo `/tq_test.bin.npz` na raiz do repositório é o output do benchmark manual. Contém índices, codebook e normas dos 100 vetores de teste (1536 dims, 4-bit). Pode ser usado para validar a serialização em outros ambientes.

---

## Referências

- `turboquant-vectors` v0.3.0: https://pypi.org/project/turboquant-vectors/
- `turboquant-py` v0.1.0: descartado (import quebrado)
- ChromaDB: https://docs.trychroma.com/
- all-MiniLM-L6-v2: 384 dims, Apache 2.0, via sentence-transformers
