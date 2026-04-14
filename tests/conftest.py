"""Fixtures compartilhadas para os testes do memory_bridge."""

import hashlib
import math
import sys
from pathlib import Path

import pytest

# Torna o diretório scripts/ importável
ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(ROOT / "scripts"))


def _trigram_embed(text: str) -> list[float]:
    """Embedding determinístico e rápido para testes (char-trigram)."""
    text = text.lower().strip()
    dim = 384
    vec = [0.0] * dim
    for i in range(len(text) - 2):
        trigram = text[i : i + 3]
        h = int(hashlib.md5(trigram.encode()).hexdigest(), 16) % dim
        vec[h] += 1.0
    norm = math.sqrt(sum(x * x for x in vec))
    if norm > 0:
        vec = [x / norm for x in vec]
    return vec


@pytest.fixture
def tmp_memory(tmp_path, monkeypatch):
    """Cria um ~/memory isolado em tmp_path e força embedder trigram."""
    import memory_bridge

    memory_dir = tmp_path / "memory"
    embeddings_dir = memory_dir / ".embeddings"
    embeddings_dir.mkdir(parents=True)

    monkeypatch.setattr(memory_bridge, "MEMORY_DIR", memory_dir)
    monkeypatch.setattr(memory_bridge, "EMBEDDINGS_DIR", embeddings_dir)
    monkeypatch.setattr(memory_bridge, "INDEX_FILE", embeddings_dir / "index.json")
    monkeypatch.setattr(memory_bridge, "VECTORS_FILE", embeddings_dir / "vectors.npy")

    # Zera caches de módulo (evita vazamento entre testes)
    monkeypatch.setattr(memory_bridge, "_index_cache", None)
    monkeypatch.setattr(memory_bridge, "_vectors_cache", None)

    # Força embedder determinístico (rápido, sem baixar modelo)
    monkeypatch.setattr(memory_bridge, "_embedder", ("trigram-test", _trigram_embed))

    return memory_dir
