# Dotfiles — Claude Code with Persistent Memory

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Built for Claude Code](https://img.shields.io/badge/built%20for-Claude%20Code-blueviolet.svg)](https://claude.ai/code)

Dotfiles that give Claude Code persistent memory. Every new session already knows who you are, how you work, and what you were doing — without you explaining anything.

---

## What is this

Claude Code starts from zero every session. You explain the same context, repeat the same preferences, lose continuity across sessions and machines. Parallel sessions can conflict without coordination.

This repository solves that with three layers:

1. **Persistent semantic memory** — a private git repo (`~/memory/`) with vector embeddings that sync across machines
2. **Automatic hooks** — inject context on open, save context on close, protect sensitive files, run linters
3. **Agents + skills + rules** — 7 specialized agents, 20 workflow skills, and 6 per-language rule sets

---

## How is this different from claude-mem?

| | This project | claude-mem |
|---|---|---|
| **Storage** | Git repo (markdown + numpy vectors) | SQLite + Chroma |
| **Cross-machine sync** | `git push/pull` | Manual file copy |
| **Embeddings cost** | Free (sentence-transformers, local) | Free (ChromaDB ONNX) |
| **Memory compression** | None (verbatim) | AI-powered via agent-sdk |
| **Deduplication** | Cosine similarity (roadmap) | AI-powered write-time dedup |
| **Search** | Vector (semantic) | Vector + FTS5 (semantic + exact) |
| **Integration** | Dotfiles (hooks, agents, skills, rules) | Plugin (5 lifecycle hooks) |
| **Setup** | `git clone` + `bash install.sh` | `npm install -g claude-mem` |

**Pick this if:** you want git-syncable memory across machines with a full dotfiles setup (agents, skills, rules, lint hooks).

**Pick claude-mem if:** you want a polished plugin with AI-powered compression, dedup, and a large community (46K stars).

---

## How it works

```
SESSION OPEN
┌─────────────────────────────────────────────────────┐
│ SessionStart hook                                   │
│   └→ memory_bridge.py query                         │
│       └→ search ~/memory/.embeddings/vectors.npy    │
│           └→ inject context: "you were working on X │
│              in project Y, with stack Z"            │
└─────────────────────────────────────────────────────┘

DURING WORK
┌─────────────────────────────────────────────────────┐
│ /handoff → save session to semantic memory          │
│ /boot    → load memory + project state              │
│ PreCompact → persist context before compacting      │
│ Auto-lint → runs on every Write/Edit                │
└─────────────────────────────────────────────────────┘

SESSION CLOSE
┌─────────────────────────────────────────────────────┐
│ Stop hook                                           │
│   └→ cd ~/memory && git add -A && git commit        │
│       └→ memory synced automatically                │
└─────────────────────────────────────────────────────┘

NEW MACHINE
┌─────────────────────────────────────────────────────┐
│ git clone dotfiles + git clone memory               │
│   └→ bash install.sh                                │
│       └→ rebuild embeddings (~10 seconds)            │
│           └→ same context as the previous machine   │
└─────────────────────────────────────────────────────┘
```

---

## Quick start

### Prerequisites

- [Claude Code](https://claude.ai/code) installed
- Python 3.9+
- Git configured
- Node.js 18+ (optional, for ruah)
- `gh` CLI (optional, for step 2 of memory setup)

> **Note:** sentence-transformers pulls PyTorch as a dependency (~2GB download on first install). On slow connections, this can take several minutes. The char-trigram fallback activates automatically if install fails.

### New machine setup (~5 minutes)

**Step 1 — Clone and install dotfiles**

```bash
git clone https://github.com/vini-haa/dotfiles ~/dotfiles
cd ~/dotfiles && bash install.sh
```

> **Note:** You must clone to `~/dotfiles`. The memory hooks use `$HOME/dotfiles` as a fixed path.

`install.sh` is idempotent — it installs everything automatically:
- Symlinks to `~/.claude/` (settings, hooks, agents, skills, rules)
- Python dependencies (sentence-transformers for local embeddings, turboquant-vectors)
- Memory repository at `~/memory/`
- ruah for session coordination (optional)
- JSON and permission validation

**Step 2 — Create a private memory repo on GitHub**

```bash
gh repo create memory --private --description "Persistent memory — Claude Code"
```

**Step 3 — Connect and push**

```bash
cd ~/memory

# SSH (if you have SSH keys configured)
git remote add origin git@github.com:YOUR_USERNAME/memory

# HTTPS (if you don't have SSH keys)
git remote add origin https://github.com/YOUR_USERNAME/memory

git push -u origin main
```

**Step 4 — Introduce yourself to the system**

```bash
python3 ~/dotfiles/scripts/memory_bridge.py store \
  --text "YOUR NAME. Stack: YOUR TECHNOLOGIES. Active projects: YOUR PROJECTS. Rules: YOUR CRITICAL RULES." \
  --tags "profile,global" \
  --project "global"
```

**Step 5 — Validate**

```bash
python3 ~/dotfiles/scripts/memory_bridge.py status
python3 ~/dotfiles/scripts/memory_bridge.py query --text "my profile" --top-k 3
```

### Reduce token usage in your projects

Copy the `.claudeignore` template to any project to prevent Claude from reading build artifacts, lock files, and binaries — saves 10-50K tokens per session:

```bash
cp ~/dotfiles/config/.claudeignore ~/my-project/.claudeignore
```

### Update an existing machine

```bash
cd ~/dotfiles && git pull        # symlinks reflect changes automatically
cd ~/memory && git pull          # sync memory from the other machine
python3 ~/dotfiles/scripts/memory_bridge.py rebuild --incremental
```

---

## Memory system

Three layers work together:

| Layer | Where | What it does |
|-------|-------|-------------|
| **Markdown** | `~/memory/projects/`, `~/memory/global/` | `.md` files with frontmatter — readable, versioned, diffable |
| **Embeddings** | `~/memory/.embeddings/` | `index.json` (metadata) + `vectors.npy` (float32 vectors) — semantic search |
| **memory_bridge.py** | `~/dotfiles/scripts/` | CLI interface that connects everything |

### Commands

```bash
# Store a memory
python3 ~/dotfiles/scripts/memory_bridge.py store \
  --text "This API uses JWT auth with refresh tokens" \
  --tags "api,jwt,auth" \
  --project "my-project"
# → ✓ Memory stored: a1b2c3d4e5f6 (embeddings: sentence-transformers)

# Search similar memories
python3 ~/dotfiles/scripts/memory_bridge.py query \
  --text "authentication flow" \
  --top-k 5
# → [0.4058] (my-project) This API uses JWT auth with refresh tokens

# System status
python3 ~/dotfiles/scripts/memory_bridge.py status
# → ✓ Index: 5 memories (model: sentence-transformers)
# → vectors.npy: 7.6 KB

# Rebuild index from .md files
python3 ~/dotfiles/scripts/memory_bridge.py rebuild --incremental

# Sync with Obsidian (if configured)
python3 ~/dotfiles/scripts/memory_bridge.py sync
```

### How embeddings work

`memory_bridge.py` tries, in order:
1. **sentence-transformers** (all-MiniLM-L6-v2, 384 dims) — runs locally, no API calls
2. **Char-trigram** — fallback if sentence-transformers is unavailable, works with zero dependencies

Vectors are saved as `vectors.npy` (numpy float32) and metadata as `index.json` (text JSON). Both sync via git.

---

## Cross-machine sync

The cycle is automatic:

| When | What happens | Who does it |
|------|-------------|-------------|
| Open session | `git pull` on `~/memory/` + context query | SessionStart hook |
| Before compacting | `memory_bridge.py store` saves context | PreCompact hook |
| Close session | `git add -A && git commit` on `~/memory/` | Stop hook |
| Switch machines | `git pull` + `rebuild --incremental` | Manual or `/sync-memory` |

Auto-push is not enabled (to avoid silent conflicts). Use `/sync-memory` or `cd ~/memory && git push` manually.

---

## Parallel session coordination (ruah)

[ruah](https://www.npmjs.com/package/@levi-tc/ruah) coordinates multiple Claude Code sessions working on the same repository, using isolated git worktrees and file claiming.

`scripts/ruah_bridge.sh` integrates ruah with memory:

```bash
# Starting a task: injects memory context into the worktree
bash ~/dotfiles/scripts/ruah_bridge.sh start task-name

# Completing: persists result to memory
bash ~/dotfiles/scripts/ruah_bridge.sh complete task-name
```

Optional — the system works without ruah.

---

## Specialized agents

Use agents to delegate tasks with specialized context:

| Agent | When to use | Model |
|-------|------------|-------|
| `frontend` | UI, components, CSS, accessibility, React/Vue/Angular | Sonnet |
| `backend` | APIs, auth, services, middleware, integrations | Sonnet |
| `database` | Modeling, queries, migrations, indexing, performance | Sonnet |
| `architect` | System design, trade-offs, technology choices | Opus |
| `devops` | Docker, CI/CD, IaC, monitoring, deploy | Sonnet |
| `security` | Auditing, vulnerabilities, OWASP (read-only, no edits) | Opus |
| `company-context` | Template for your company-specific context (customize it) | Sonnet |

```
"Use the frontend agent to create the login component"
"Ask the database agent to review this migration"
```

---

## Skills (slash commands)

| Command | What it does |
|---------|-------------|
| `/review` | Structured code review with formal verdict (PASS/FAIL/NEEDS DISCUSSION) |
| `/review-deep` | Parallel review with 4 agents (code, security, test, consequences) |
| `/ship` | Full pipeline: lint → test → build → commit |
| `/refactor` | Analysis and refactoring with plan before execution |
| `/test` | Generate tests or run existing suite |
| `/tdd` | Test-driven development: RED → GREEN → REFACTOR |
| `/security` | Security audit (secrets, vulnerabilities, deps) |
| `/debug` | Investigate bug: reproduce → isolate → diagnose → fix |
| `/perf` | Performance analysis: N+1, O(n²), re-renders, cache, I/O |
| `/handoff` | Save session context + persist to semantic memory |
| `/boot` | Initialize: query memory → load state → detect stack |
| `/sync-memory` | Reconcile git + embeddings + Obsidian |
| `/loop-recovery` | Detect and escape unproductive retry loops |
| `/compact` | Summarize session to free context |
| `/dispatch` | Sub-agent orchestration with auto-triggers |
| `/explore` | Structured codebase exploration (discovery + deep dive) |
| `/contextualize` | Generate .context.md per directory for orientation |
| `/brainstorm` | Creative ideation: generate, evaluate, and prioritize ideas |
| `/agent-memory` | Persistent memory across sessions (long-term + session) |
| `/task-tracking` | Persistent todos in file (survives across sessions) |

```
/review src/api/
/ship "feat: add user authentication"
/debug "500 error on /api/users endpoint"
/handoff
/boot
/sync-memory
```

---

## Automatic hooks

| Hook | Event | What it does |
|------|-------|-------------|
| **File protection** | PreToolUse (Edit/Write) | Blocks editing .env, credentials, secrets, .pem, .key |
| **Bash security** | PreToolUse (Bash) | Blocks dangerous commands (fork bombs, pipe to shell) |
| **Lint** | PostToolUse (Write/Edit) | Auto-formats code |
| **Secret scanner** | PostToolUse (Write/Edit) | Detects leaked credentials in code |
| **Memory: injection** | SessionStart | Queries `memory_bridge.py` and injects project context |
| **Memory: capture** | PreCompact | Saves session context before compacting |
| **Memory: preserve** | PostCompact | Saves branch, modified files and project to memory after compaction |
| **Memory: sync** | Stop | Auto-commits `~/memory/` |
| **Rule reinforcement** | UserPromptSubmit | Re-injects critical rules every N prompts |
| **Pending items** | Stop | Detects TODO/FIXME and asks if you want to continue |

### Supported lint languages

| Extension | Tools |
|-----------|-------|
| `.py` | ruff (lint + format) |
| `.ts` `.tsx` `.js` `.jsx` | eslint + prettier |
| `.go` | gofmt + golangci-lint |
| `.sql` | sqlfluff (auto-detected dialect) |

---

## Getting started for beta testers

### 1. Follow the setup above (steps 1-5)

### 2. Store your personal profile

Customize and run:

```bash
python3 ~/dotfiles/scripts/memory_bridge.py store \
  --text "YOUR NAME, ROLE. Stack: LANGUAGES AND FRAMEWORKS. \
Active projects: PROJECT A (stack), PROJECT B (stack). \
Patterns: YOUR CODE PATTERNS. \
Critical rules: THINGS THAT MUST NEVER HAPPEN." \
  --tags "profile,global" \
  --project "global"
```

### 3. Use it for a real work session

Work normally on any project. The system captures context in the background.

### 4. Use `/handoff` when closing the session

This persists the full state to semantic memory.

### 5. Open a new session and observe

The SessionStart hook will automatically inject relevant context. You should see something like:

```
Memory context injected: [0.4058] (my-project) ...
```

### 6. Report what worked and what didn't

Open an Issue at [github.com/vini-haa/dotfiles/issues](https://github.com/vini-haa/dotfiles/issues) with:
- What worked well
- What didn't work or was confusing
- Suggestions for improvement

---

## Rules (context-aware)

Loaded on demand when Claude reads files matching the glob pattern:

| Rule | Activated on | Content |
|------|-------------|---------|
| `python.md` | `**/*.py` | Type hints, f-strings, pathlib, Google docstrings |
| `typescript.md` | `**/*.ts/*.tsx/*.js/*.jsx` | Interface vs type, const, async/await, React |
| `go.md` | `**/*.go` | Error handling, interfaces, table-driven tests |
| `sql.md` | `**/*.sql` | Keywords uppercase, CTEs, indexing, naming |
| `security.md` | `**/*` | OWASP, sanitization, secrets, HTTPS |
| `testing.md` | Test files | AAA, descriptive names, fixtures, edge cases |

Severity hierarchy:
- **Commandments** (🔴) — block review, no exceptions
- **Edicts** (🟡) — need justification to override
- **Counsel** (🔵) — suggestions, never block

---

## Behavioral patterns

`CLAUDE.md` includes advanced prompt engineering patterns:

- **3-file rule** — if a task requires reading/editing more than 3 files, it automatically delegates to a sub-agent
- **Question hierarchy** — conversation context → CLAUDE.md → existing code → best practices → only then ask
- **Anti-rationalization** — table of trap-thoughts that Claude must recognize and avoid
- **Pressure resistance** — if asked to skip tests or review, suggests the minimum viable alternative
- **Periodic reinforcement** — hook re-injects critical rules every N prompts

---

## Pre-configured permissions

**Automatically allowed:** file reading, search, grep, linting (ruff, eslint, prettier, gofmt, golangci-lint, sqlfluff), testing (pytest, npm test, go test), read-only git.

**Always blocked:** `rm -rf /`, `rm -rf ~`, `git push --force` to main/master, `git reset --hard`, `chmod -R 777`, piping curl/wget to bash/sh, destructive disk commands.

---

## MCP Servers

Pre-configured with GitHub MCP. To activate:

```bash
export GITHUB_TOKEN='ghp_your_token_here'
```

---

## Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+K, Ctrl+R` | /review |
| `Ctrl+K, Ctrl+T` | /test |
| `Ctrl+K, Ctrl+S` | /ship |
| `Ctrl+K, Ctrl+D` | /debug |
| `Ctrl+K, Ctrl+E` | /explore |
| `Ctrl+K, Ctrl+P` | /perf |
| `Ctrl+K, Ctrl+B` | /brainstorm |

---

## Repository structure

```
dotfiles/
├── README.md
├── install.sh                          ← idempotent installer
├── scripts/
│   ├── memory_bridge.py                ← semantic memory (store/query/rebuild/sync/status)
│   ├── setup_memory_repo.sh            ← initializes ~/memory/
│   ├── ruah_bridge.sh                  ← ruah + memory integration
│   └── check_deps.sh                   ← dependency checker
├── claude/
│   ├── CLAUDE.md                       ← global code conventions
│   ├── settings.json                   ← hooks + permissions
│   ├── .mcp.json                       ← MCP servers
│   ├── keybindings.json                ← keyboard shortcuts
│   ├── hooks/
│   │   ├── lint_hook.sh                ← auto-lint after edit
│   │   ├── bash_security.sh            ← dangerous command blocker
│   │   ├── secret_scan.sh              ← credential detection
│   │   ├── session_start.sh            ← stack detection
│   │   └── claude_md_reminder.sh       ← periodic rule reinforcement
│   ├── agents/
│   │   ├── frontend.md                 ← UI, React, accessibility
│   │   ├── backend.md                  ← APIs, auth, services
│   │   ├── database.md                 ← SQL, modeling, performance
│   │   ├── architect.md                ← system design
│   │   ├── devops.md                   ← CI/CD, Docker, infra
│   │   ├── security.md                 ← OWASP auditing (read-only)
│   │   └── company-context.md          ← customizable company template
│   ├── skills/
│   │   ├── review/                     ← /review
│   │   ├── review-deep/                ← /review-deep
│   │   ├── ship/                       ← /ship
│   │   ├── refactor/                   ← /refactor
│   │   ├── test/                       ← /test
│   │   ├── tdd/                        ← /tdd
│   │   ├── security/                   ← /security
│   │   ├── debug/                      ← /debug
│   │   ├── perf/                       ← /perf
│   │   ├── handoff/                    ← /handoff
│   │   ├── boot/                       ← /boot
│   │   ├── sync-memory/                ← /sync-memory
│   │   ├── loop-recovery/              ← /loop-recovery
│   │   ├── compact/                    ← /compact
│   │   ├── dispatch/                   ← /dispatch
│   │   ├── explore/                    ← /explore
│   │   ├── contextualize/              ← /contextualize
│   │   ├── brainstorm/                 ← /brainstorm
│   │   ├── agent-memory/               ← /agent-memory
│   │   └── task-tracking/              ← /task-tracking
│   └── rules/
│       ├── python.md                   ← activated on *.py
│       ├── typescript.md               ← activated on *.ts/*.tsx/*.js/*.jsx
│       ├── go.md                       ← activated on *.go
│       ├── sql.md                      ← activated on *.sql
│       ├── security.md                 ← activated on all files
│       └── testing.md                  ← activated on test files
├── docs/
│   ├── ARCHITECTURE.md                 ← full architecture with diagrams
│   └── decisions/                      ← ADRs (ruah, mempalace, TurboQuant)
├── config/
│   ├── ruff.toml                       ← Python linter
│   ├── .sqlfluff                       ← SQL linter
│   └── golangci.yml                    ← Go linter
└── shell/
    └── .bashrc_extras                  ← aliases (dotfiles-update, lint-check)
```

---

## Contributing

- **Report issues or suggestions:** open an [Issue](https://github.com/vini-haa/dotfiles/issues)
- **New agents, skills, or rules:** PRs welcome
- **Core changes** (memory_bridge, hooks, install.sh): open an Issue first to align on approach
