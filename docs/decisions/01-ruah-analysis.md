# Análise Técnica: ruah (@levi-tc/ruah v0.4.3)

**Data:** 2026-04-10
**Status:** Decidido — integrar via bridge script
**Pacote atual:** `@levi-tc/ruah` v0.4.3 (depreciado → `@ruah-dev/orch`)

---

## O que é

ruah é um orquestrador de tarefas para agentes de IA que utiliza git worktrees como unidade de isolamento. Cada tarefa recebe seu próprio worktree, permitindo execução paralela sem conflitos de branches.

---

## Comandos disponíveis

### Inicialização e configuração

| Comando | Descrição |
|---|---|
| `ruah init` | Inicializa `.ruah/` no repositório git (requer ao menos 1 commit) |
| `ruah setup` | Configuração inicial do ambiente |
| `ruah config` | Gerencia configurações |
| `ruah doctor` | Diagnóstico do ambiente |
| `ruah status` | Estado atual das tarefas |
| `ruah clean` | Limpeza de worktrees e estado |
| `ruah demo` | Demonstração interativa |

### Ciclo de vida de tarefas

| Comando | Descrição |
|---|---|
| `ruah task create` | Cria nova tarefa (com worktree) |
| `ruah task start` | Inicia execução da tarefa |
| `ruah task done` | Marca tarefa como concluída |
| `ruah task merge` | Faz merge do worktree de volta ao branch principal |
| `ruah task list` | Lista todas as tarefas e seus estados |
| `ruah task cancel` | Cancela uma tarefa |
| `ruah task retry` | Retenta uma tarefa com falha |
| `ruah task takeover` | Reassume controle de uma tarefa em execução |

### Workflows

| Comando | Descrição |
|---|---|
| `ruah workflow run` | Executa um workflow definido em markdown |
| `ruah workflow plan` | Analisa e planeja a execução (DAG) |
| `ruah workflow list` | Lista workflows disponíveis |
| `ruah workflow create` | Cria novo arquivo de workflow |

---

## Funcionalidades relevantes

### File claiming

Ao criar uma tarefa, é possível declarar os arquivos que ela vai modificar:

```bash
ruah task create "implementar autenticação" --files "src/auth/**" --files "tests/auth/**"
```

Isso registra contratos de modificação no `.ruah-task.md` da tarefa.

### Contratos de modificação

O arquivo `.ruah-task.md` define fronteiras de acesso entre tarefas concorrentes:

- **owned** — arquivo pertence exclusivamente à tarefa
- **shared-append** — múltiplas tarefas podem adicionar conteúdo
- **read-only** — tarefa só lê, não modifica

Isso evita conflitos em execuções paralelas sem exigir locks explícitos.

### Executores suportados

| Executor | Descrição |
|---|---|
| `claude-code` | Claude Code via CLI |
| `aider` | Aider (modo interativo ou automático) |
| `codex` | OpenAI Codex CLI |
| `open-code` | Open-source alternativa |
| `script` | Script shell arbitrário |

### Execução paralela

O planejador analisa overlaps de arquivos entre tarefas e decide quais podem rodar em paralelo. Tarefas com conflito de arquivos são serializadas automaticamente.

### Subtarefas

Tarefas podem ter hierarquia via `--parent`:

```bash
ruah task create "implementar endpoint POST /users" --parent task-uuid-pai
```

A subtarefa cria um worktree que parte do branch do pai, não do main.

### Integração com crag

Antes do `task merge`, o ruah pode chamar o crag como quality gate — verificando cobertura de testes, lint e outros critérios antes de aceitar o merge.

### Estado persistido

Todo o estado fica em `.ruah/state.json` com a seguinte estrutura:

```json
{
  "tasks": {},
  "locks": {},
  "lockModes": {},
  "history": []
}
```

---

## Limitações identificadas

| Limitação | Impacto | Mitigação |
|---|---|---|
| Pacote depreciado (`@levi-tc/ruah`) | Médio — sem novas correções | Migrar para `@ruah-dev/orch` quando estável |
| Sem injeção de memória/contexto | Alto — agentes partem sem histórico | Bridge script injeta contexto via `--context` ou arquivo temp |
| Requer ao menos 1 commit para `init` | Baixo — condição conhecida | Documentar no README |
| Sem sistema de hooks nativo | Médio — lifecycle só via workflows | Envolver comandos ruah com bridge script |
| Worktrees exigem disco extra | Baixo — proporcional ao tamanho do repo | Monitorar com `ruah clean` periódico |

---

## Decisão de integração

**Veredicto:** Integrar via `ruah_bridge.sh`.

O bridge script envolve os comandos ruah e adiciona as capacidades que faltam:

```
ruah task create  →  bridge injeta contexto de memória (ChromaDB/numpy)
ruah task done    →  bridge persiste resultado no vetor store
ruah task merge   →  bridge atualiza índice de memória com o diff mergeado
```

Isso mantém o ruah como orquestrador de worktrees (sua responsabilidade principal) sem modificar o pacote. A memória e o contexto ficam no bridge, que é nosso código.

### Por que não migrar agora para `@ruah-dev/orch`

- A API do `@ruah-dev/orch` ainda não está estável o suficiente para analisar
- `@levi-tc/ruah` v0.4.3 funciona e tem comportamento conhecido
- Migração é uma tarefa isolada que não bloqueia o bridge

---

## Referências

- Pacote atual: `npm install -g @levi-tc/ruah`
- Pacote successor: `npm install -g @ruah-dev/orch`
- Estado local: `.ruah/state.json`
- Contratos de arquivo: `.ruah-task.md` por worktree
