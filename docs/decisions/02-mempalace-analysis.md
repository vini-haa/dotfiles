# Análise Técnica: mempalace (v3.1.0)

**Data:** 2026-04-10
**Status:** Decidido — usar ChromaDB diretamente (sem mempalace)
**Repositório:** github.com/milla-jovovich/mempalace v3.1.0

---

## O que é

mempalace é um sistema de memória para agentes de IA que usa ChromaDB como backend vetorial. Organiza o conteúdo em uma estrutura hierárquica inspirada no método dos loci (técnica de memorização): palaces > wings > halls > rooms. Cada "room" armazena um fragmento semântico indexado.

O projeto reporta 96.6% de recall@5 no benchmark LongMemEval — número relevante para avaliação de sistemas de memória de longo prazo.

---

## Interface exposta

### CLI

```bash
mempalace init            # inicializa palace local (~/.mempalace/)
mempalace mine            # extrai e indexa conversas/documentos
mempalace search <query>  # busca semântica no palace
```

### Python API

```python
# layers.py
from mempalace.layers import search
results = search(query="autenticação JWT", top_k=5)

# knowledge_graph.py
from mempalace.knowledge_graph import add_entity, query_entity
add_entity(name="ruah", type="tool", description="orquestrador de worktrees")
query_entity(name="ruah")
```

### MCP server

mempalace inclui um servidor MCP embutido, o que permitiria integração direta com Claude Code sem subprocess. Este foi um ponto de interesse inicial.

### Embeddings

Usa `all-MiniLM-L6-v2` via ONNX localmente — sem chamada de API externa. Dimensão: 384. Adequado para uso offline e em ambientes sem internet.

---

## Problema de instalação no Windows

```
pip install mempalace
```

Falha durante a compilação de `chroma-hnswlib`, dependência transitiva do ChromaDB usado internamente pelo mempalace:

```
error: Microsoft Visual C++ 14.0 or greater is required.
Get it with "Microsoft C++ Build Tools"
```

`chroma-hnswlib` é uma extensão C++ que precisa ser compilada. No Windows, exige o MSVC toolchain instalado, o que não é viável assumir no ambiente de destino.

**Contraste:** `pip install chromadb` funciona porque o ChromaDB disponibiliza wheels binárias pré-compiladas para Windows (Python 3.14 x64). O mempalace fixa uma versão específica do ChromaDB que não tem wheel disponível para a nossa combinação Python/OS.

---

## Decisão: usar ChromaDB diretamente

A estrutura "palace" do mempalace é uma abstração útil conceitualmente, mas adiciona uma camada de complexidade desnecessária para o nosso caso de uso. O que precisamos é:

1. Armazenamento persistente de vetores
2. Busca semântica por similaridade
3. Filtragem por metadados (projeto, data, tipo)
4. Embeddings locais (sem API)

O ChromaDB entrega os quatro nativamente.

### O que ganhamos usando ChromaDB diretamente

| Funcionalidade | ChromaDB direto | via mempalace |
|---|---|---|
| Instalação no Windows | Funciona (wheel binária) | Falha (compila C++) |
| Embeddings locais | all-MiniLM-L6-v2 (built-in) | Mesmo modelo via mempalace |
| Busca semântica | `collection.query()` | `search()` |
| Filtragem por metadados | `where={"project": "dotfiles"}` | Equivalente |
| Persistência | `PersistentClient(path)` | Automático |
| Controle da coleção | Total | Abstraído |

### O que perdemos

- Metáfora de organização (palace/wings/halls/rooms) — não usaremos
- MCP server embutido — podemos usar ChromaDB via subprocess ou criar wrapper próprio
- `mempalace mine` para extração automática de conversas — substituível por script próprio

---

## Estratégia de fallback

Se o ChromaDB também apresentar problemas (compatibilidade futura, regressão de wheel), temos fallback implementável com numpy:

```python
import numpy as np

def cosine_similarity(a: np.ndarray, b: np.ndarray) -> float:
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

def search_top_k(query_vec, stored_vecs, stored_metas, k=5):
    scores = [cosine_similarity(query_vec, v) for v in stored_vecs]
    top_indices = np.argsort(scores)[-k:][::-1]
    return [(stored_metas[i], scores[i]) for i in top_indices]
```

Sem dependências externas. Sem compilação. Funciona em qualquer ambiente Python >= 3.9.

A desvantagem é velocidade (O(n) linear scan) e ausência de persistência nativa — os vetores precisariam ser salvos manualmente em `.npz` ou similar.

---

## Caminho de implementação

```
~/.dotfiles-memory/
  chroma/          ← ChromaDB PersistentClient aqui
    chroma.sqlite3
    <uuid>/
```

Coleções a criar:

| Coleção | Conteúdo | Metadados chave |
|---|---|---|
| `conversations` | Resumos de sessões com agentes | `date`, `project`, `agent` |
| `decisions` | Decisões técnicas (como este arquivo) | `date`, `topic`, `verdict` |
| `code_context` | Snippets e padrões do codebase | `file`, `language`, `project` |

---

## Referências

- ChromaDB docs: https://docs.trychroma.com/
- Modelo de embedding: `all-MiniLM-L6-v2` (384 dims, Apache 2.0)
- mempalace repo: github.com/milla-jovovich/mempalace
- LongMemEval benchmark: métrica usada para avaliar recall em memória de longo prazo
