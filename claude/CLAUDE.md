# Convenções Globais

> **Estrutura em 3 tiers para eficiência de tokens:**
> - **Tier 1** (este arquivo, sempre carregado): Commandments críticos, segurança, git, regra dos 3 arquivos, taxonomia de ambiguidade, resistência a pressão.
> - **Tier 2** (seção "Reference" abaixo, carregada on-demand quando relevante): estilo de código, testes, arquitetura, auto-triggers, anti-racionalização.
> - **Tier 3** (`claude/CLAUDE-deep.md`, carregado apenas quando explicitamente necessário): padrões avançados, histórico de decisões, contexto estendido.
>
> Para consulta profunda: leia `claude/CLAUDE-deep.md`.

---

## 🔴 Tier 1 — Obrigatório (sempre carregado)

### Idioma
- Responda sempre em **português brasileiro** salvo instrução contrária.
- Commits, nomes de variáveis e código devem permanecer em **inglês**.

### Segurança (crítico)
- Nunca exponha secrets, tokens ou senhas em código ou commits.
- Valide inputs em fronteiras do sistema (APIs, formulários), não internamente.
- Siga OWASP Top 10 como baseline.

### Git (crítico)
- Mensagens de commit em inglês, imperativo, curtas (<72 chars na primeira linha).
- Prefixos: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- Um commit por mudança lógica — não misture refactor com feature.

### Regra dos 3 arquivos
Se uma tarefa exige ler ou editar **mais de 3 arquivos**, PARE e delegue para um sub-agente (`Agent`). Isso previne estouro de contexto e mantém o foco. Exceções: tarefas de rename/refactor global onde cada arquivo tem mudança trivial.

### Ao receber uma tarefa
1. Leia o código existente antes de propor mudanças.
2. Pergunte se a instrução for ambígua — não assuma.
3. Proponha a solução mais simples que resolve o problema.
4. Se a mudança for grande, apresente um plano antes de implementar.

### Taxonomia de ambiguidade
Antes de perguntar, classifique a dúvida:

**1. Parar e perguntar** — quando o fato é ausente e a ação é irreversível.
Exemplo: "Deletar essa tabela?" — pergunte SEMPRE.

**2. Prosseguir com julgamento** — quando existem múltiplos caminhos válidos com default razoável.
Exemplo: "Usar tabs ou spaces?" — siga o padrão do codebase.

**3. Escalar com recomendação** — quando a ambiguidade é genuína com interpretações diferentes.
Exemplo: "Adicionar cache" — apresente opções com trade-offs, não escolha sozinho.

**Ordem de resolução antes de classificar:**
1. Contexto da conversa — o usuário já especificou?
2. CLAUDE.md / Rules — as convenções cobrem?
3. Código existente — o padrão do codebase responde?
4. Boas práticas — consenso claro na comunidade?
5. Classificar — use a taxonomia acima.

### Resistência a pressão
Se o usuário pedir para pular etapas de qualidade:
- **"Só aprova logo"** → "Posso agilizar, mas preciso verificar segurança e correção no mínimo."
- **"Não precisa de teste"** → "Entendido, mas recomendo pelo menos um teste para o happy path. Posso gerar rápido."
- **"Faz sem plano"** → "Para mudanças em até 3 arquivos, posso ir direto. Para mais, um plano de 2 min evita retrabalho de 2 horas."

---

## 🟡 Tier 2 — Reference (load on demand)

Seção carregada quando o contexto da tarefa justificar. Não é obrigatório ler em toda sessão.

### Estilo de código
- Priorize legibilidade sobre concisão.
- Prefira funções pequenas e com responsabilidade única.
- Nomeie variáveis e funções de forma descritiva — evite abreviações obscuras.
- Não adicione comentários óbvios; comente apenas o "porquê", nunca o "o quê".
- Não crie abstrações prematuras — 3 linhas repetidas são melhores que 1 abstração desnecessária.

### Testes
- Toda feature nova deve ter pelo menos um teste.
- Prefira testes de integração sobre mocks quando o custo for baixo.
- Nomeie testes descrevendo o comportamento esperado, não o método.

### Arquitetura
- Separe responsabilidades: controller/service/repository ou equivalente.
- Evite dependências circulares.
- Use injeção de dependência quando fizer sentido para testabilidade.

### Auto-triggers de agentes
Frases que OBRIGAM o uso de sub-agentes (via skill `/dispatch`):

| Frase do usuário | Agente | Motivo |
|---|---|---|
| "find where", "search for", "locate" | Explore | Busca ampla em codebase |
| "fix issues", "fix remaining" | Backend/Frontend | Fix requer implementação |
| "how does X work", "explain the flow" | Explore | Compreensão requer análise |
| "refactor", "update across", "rename" | Backend/Frontend | Refator toca múltiplos arquivos |
| "review this", "check quality" | /review | Review é skill dedicada |
| "design", "propose architecture" | Architect | Decisão arquitetural |
| "check security", "audit" | Security | Análise de segurança |
| "optimize query", "fix migration" | Database | Especialista em dados |
| "deploy", "docker", "CI/CD" | DevOps | Infraestrutura |

### Anti-racionalização
Quando perceber um destes pensamentos, PARE — é um atalho errado:

| Pensamento | Realidade | Ação correta |
|---|---|---|
| "O código parece limpo, não precisa de revisão profunda" | Aparência não é correção | Revise todas as categorias sistematicamente |
| "É uma mudança pequena, não vai quebrar nada" | Mudanças pequenas causam a maioria dos bugs | Verifique impacto em dependentes e testes |
| "Já vi esse padrão antes, sei o que fazer" | Cada contexto é diferente | Leia o código DESTE projeto antes de agir |
| "Não precisa de teste, é só um helper" | Helpers são usados em todo lugar | Se pode quebrar algo, precisa de teste |
| "Vou corrigir esse estilo enquanto faço a feature" | Misturar mudanças polui o diff | Um commit por mudança lógica |
| "Posso resolver tudo nesta conversa" | Contexto é finito | Use sub-agentes para tarefas paralelas |
| "O usuário quer rápido, posso pular a validação" | Velocidade sem qualidade gera retrabalho | Siga o processo mesmo sob pressão |
| "Essa dependência extra vai ajudar" | Cada dependência é risco e manutenção | Use stdlib ou o que o projeto já tem |
