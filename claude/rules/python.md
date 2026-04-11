---
paths:
  - "**/*.py"
---

# Python

## 🔴 Obrigatório (bloqueia review se violado)
- Use type hints em todas as assinaturas de função.
- Exceções específicas — nunca `except Exception` genérico sem re-raise.
- Use `dataclasses` ou `pydantic` para estruturas de dados, não dicts aninhados.
- Imports organizados: stdlib → third-party → local (o ruff/isort cuida disso).

## 🟡 Esperado (deve corrigir salvo justificativa)
- Prefira f-strings sobre `.format()` ou `%`.
- Use `pathlib.Path` em vez de `os.path` para manipulação de caminhos.
- Docstrings no padrão Google (`Args:`, `Returns:`, `Raises:`).
- Use context managers (`with`) para I/O.
- Prefira list/dict comprehensions quando legíveis; evite comprehensions aninhadas.

## 🔵 Recomendado (sugestão de melhoria)
- Ferramentas: `ruff` para lint+format (config em `ruff.toml`).
- Considere `__slots__` em dataclasses de alta frequência.
- Use `functools.lru_cache` para funções puras chamadas repetidamente.
