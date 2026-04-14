# Contributing

Thanks for your interest. This project is a personal tool shared with the community — contributions are welcome, but please read this guide first to avoid wasted effort.

## Local development setup

**Required clone location:** `~/dotfiles`. The memory hooks use `$HOME/dotfiles` as a fixed path. Cloning elsewhere will make the memory injection silently fail.

```bash
git clone https://github.com/vini-haa/dotfiles ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## Running tests

```bash
pip install pytest
pytest tests/ -v
```

Tests use `tmp_path` fixtures for isolation — they never touch your real `~/memory`. The embedder is forced to the deterministic char-trigram version to keep tests fast (no model download, no PyTorch call).

## Code quality

Install pre-commit hooks once:

```bash
pip install pre-commit
pre-commit install
```

This enables:
- `ruff` lint + format on `scripts/**/*.py`
- Trailing whitespace, end-of-file fixer
- JSON validation on `claude/**/*.json`
- YAML validation
- Merge conflict markers

## Commit convention

**Conventional Commits** — first line under 72 chars, imperative mood, English:

- `feat(scope):` new feature
- `fix(scope):` bug fix
- `docs(scope):` documentation only
- `refactor(scope):` refactoring without behavior change
- `test(scope):` test additions or fixes
- `chore(scope):` maintenance

One logical change per commit. Don't bundle unrelated changes.

## PR workflow

### Open an Issue first for:
- Changes to `scripts/memory_bridge.py` (core)
- Changes to hooks in `claude/settings.json`
- Changes to `install.sh`
- Breaking changes to CLI interface

### No Issue needed for:
- New agents in `claude/agents/`
- New skills in `claude/skills/`
- New rules in `claude/rules/`
- Documentation improvements
- Typo fixes
- New tests

### PR checklist

- [ ] Tests pass (`pytest tests/`)
- [ ] Pre-commit passes (`pre-commit run --all-files`)
- [ ] Commit message follows Conventional Commits
- [ ] README updated if behavior changes
- [ ] No personal info, secrets, or PII in commits

## What we won't merge

- Contributions that add significant external dependencies without justification
- Breaking changes without an Issue discussion first
- Changes that remove the git-syncable property of `~/memory` (core value of the project)
- Marketing language in README or docs

## Reporting bugs

Open an Issue with:
- OS and Python version
- Output of `python3 ~/dotfiles/scripts/memory_bridge.py status`
- Exact command that failed and full error message
- What you expected vs what happened
