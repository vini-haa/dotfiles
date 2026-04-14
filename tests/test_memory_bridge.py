"""Testes básicos do memory_bridge.py.

Cobertura:
- store + query roundtrip
- query em índice vazio
- filtro por projeto
- rebuild incremental a partir de arquivos .md
- status após store
"""

import memory_bridge


def test_store_and_query_roundtrip(tmp_memory):
    mem_id = memory_bridge.store_memory(
        text="GED uses JWT auth with refresh tokens",
        tags="auth,jwt",
        project="my-api",
        quiet=True,
    )
    assert mem_id, "store_memory deve retornar um ID"

    results = memory_bridge.query_memory(
        text="GED uses JWT auth with refresh tokens",
        top_k=3,
        project=None,
        fmt="json",
    )

    assert len(results) >= 1, "query deveria retornar ao menos uma memória"
    assert any(r["id"] == mem_id for r in results), "o ID armazenado deve aparecer"
    assert any("JWT" in r["text"] for r in results), "o texto armazenado deve aparecer"


def test_query_returns_empty_on_new_index(tmp_memory):
    results = memory_bridge.query_memory(
        text="anything",
        top_k=5,
        project=None,
        fmt="json",
    )
    assert results == [], "índice vazio deve retornar lista vazia"


def test_project_filter(tmp_memory):
    memory_bridge.store_memory(
        text="API FastAPI backend with SQLAlchemy",
        tags="backend",
        project="project-alpha",
        quiet=True,
    )
    memory_bridge.store_memory(
        text="API FastAPI backend with SQLAlchemy",
        tags="backend",
        project="project-beta",
        quiet=True,
    )

    alpha_results = memory_bridge.query_memory(
        text="FastAPI backend",
        top_k=10,
        project="project-alpha",
        fmt="json",
    )
    beta_results = memory_bridge.query_memory(
        text="FastAPI backend",
        top_k=10,
        project="project-beta",
        fmt="json",
    )

    assert all(r["project"] == "project-alpha" for r in alpha_results), (
        "query com --project alpha deve retornar apenas alpha"
    )
    assert all(r["project"] == "project-beta" for r in beta_results), (
        "query com --project beta deve retornar apenas beta"
    )


def test_rebuild_incremental(tmp_memory):
    project_dir = tmp_memory / "projects" / "my-project"
    project_dir.mkdir(parents=True)
    md_file = project_dir / "test-memory.md"
    md_file.write_text(
        "---\n"
        "tags: test,rebuild\n"
        "project: my-project\n"
        "---\n\n"
        "This memory was created by a rebuild test.\n",
        encoding="utf-8",
    )

    stats = memory_bridge.rebuild_index(incremental=True)

    assert stats["added"] >= 1, "rebuild deveria ter adicionado ao menos 1 entrada"
    assert stats["errors"] == 0, "rebuild não deveria produzir erros"

    results = memory_bridge.query_memory(
        text="rebuild test",
        top_k=5,
        project="my-project",
        fmt="json",
    )
    assert len(results) >= 1, "memória indexada deveria ser buscável"


def test_dedup_replaces_similar_memory(tmp_memory):
    """Memorias quase identicas devem ser substituidas, nao duplicadas."""
    text_a = "GED uses JWT authentication with refresh tokens for the API"
    text_b = "GED uses JWT authentication with refresh tokens for the API endpoint"

    id_a = memory_bridge.store_memory(
        text=text_a, tags="auth", project="dedup-test", quiet=True
    )
    id_b = memory_bridge.store_memory(
        text=text_b, tags="auth", project="dedup-test", quiet=True
    )

    # Mesmo ID = entrada substituida (nao duplicada)
    assert id_a == id_b, "memorias quase identicas devem retornar o mesmo ID"

    # Indice deve ter apenas 1 entrada para o projeto
    results = memory_bridge.query_memory(
        text="JWT authentication", top_k=10, project="dedup-test", fmt="json"
    )
    assert len(results) == 1, "indice nao deveria ter duplicatas"


def test_no_dedup_flag_creates_new_entry(tmp_memory):
    """Com dedup=False, memorias similares criam entradas separadas."""
    text = "API uses JWT auth with refresh tokens"

    id_a = memory_bridge.store_memory(
        text=text, tags="auth", project="no-dedup-test", quiet=True, dedup=False
    )
    id_b = memory_bridge.store_memory(
        text=text, tags="auth", project="no-dedup-test", quiet=True, dedup=False
    )

    assert id_a != id_b, "com dedup=False, IDs devem ser diferentes"


def test_progressive_disclosure_detail_levels(tmp_memory):
    """--detail compact/section/full devem retornar tamanhos crescentes."""
    long_text = "A" * 50 + " " + "B" * 200 + " " + "C" * 500 + " end"

    memory_bridge.store_memory(
        text=long_text,
        tags="detail",
        project="detail-test",
        quiet=True,
        dedup=False,
    )

    compact = memory_bridge.query_memory(
        text="A B C", top_k=1, project="detail-test", fmt="json", detail="compact"
    )
    section = memory_bridge.query_memory(
        text="A B C", top_k=1, project="detail-test", fmt="json", detail="section"
    )
    full = memory_bridge.query_memory(
        text="A B C", top_k=1, project="detail-test", fmt="json", detail="full"
    )

    assert len(compact[0]["text"]) <= 150, "compact deve ter <=150 chars"
    assert len(section[0]["text"]) <= 500, "section deve ter <=500 chars"
    assert len(full[0]["text"]) >= len(section[0]["text"]), (
        "full deve ser >= section (le do disco)"
    )


def test_status_returns_count(tmp_memory, capsys):
    memory_bridge.store_memory(
        text="Test memory for status",
        tags="test",
        project="status-test",
        quiet=True,
    )

    memory_bridge.print_status()

    captured = capsys.readouterr()
    # Tolerante a acento/encoding em diferentes plataformas
    normalized = captured.out.replace("ó", "o").replace("í", "i")
    assert "Indice" in normalized or "Índice" in captured.out, (
        "status deve reportar seção de índice"
    )
    # Deve reportar pelo menos 1 memória
    assert "1 " in captured.out or ": 1" in captured.out, (
        "status deve reportar ao menos 1 memória após store"
    )
