---
name: dispatch
description: Protocolo de orquestração para despachar sub-agentes com contexto completo.
argument-hint: "[tarefa a ser despachada]"
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent
model: sonnet
effort: high
context: fork
---

# Dispatch — Orquestração de Sub-Agentes

Despache a tarefa para o agente adequado: `$ARGUMENTS`

## Quando despachar (obrigatório)

### Auto-triggers semânticos
Se o usuário usar estas frases, o dispatch é OBRIGATÓRIO:

| Frase do usuário | Agente | Justificativa |
|---|---|---|
| "find where", "search for", "locate" | Explore | Busca requer varredura ampla |
| "fix issues", "fix remaining" | Backend/Frontend | Fix requer foco em implementação |
| "how does X work", "explain the flow" | Explore | Compreensão requer análise |
| "refactor", "update across", "rename" | Backend/Frontend | Refator toca múltiplos arquivos |
| "review this", "check quality" | /review ou /review-deep | Review é skill dedicada |
| "design architecture", "propose solution" | Architect | Decisão arquitetural |
| "check security", "audit" | Security | Análise de segurança |
| "optimize query", "fix migration" | Database | Especialista em dados |
| "deploy", "configure CI", "docker" | DevOps | Infraestrutura |

### Regra dos 3 arquivos
Se a tarefa envolve >3 arquivos → dispatch é OBRIGATÓRIO.

## Protocolo de dispatch (5 passos)

### Passo 1 — Avaliar a tarefa
- Qual o objetivo concreto?
- Quantos arquivos serão afetados?
- Qual domínio de conhecimento é necessário?

### Passo 2 — Selecionar agente
- Consulte a tabela de auto-triggers
- Em caso de dúvida entre 2 agentes, escolha o mais específico
- Se cruza domínios, despache múltiplos em paralelo

### Passo 3 — Montar o prompt
O prompt DEVE conter:
1. **Contexto**: o que o projeto faz, stack, estado atual
2. **Tarefa**: o que precisa ser feito (específico, não vago)
3. **Escopo**: quais arquivos/diretórios são relevantes
4. **Critérios de aceite**: como saber que está feito
5. **Restrições**: o que NÃO fazer (se aplicável)

### Passo 4 — Despachar
- Use a ferramenta `Agent` com `subagent_type` adequado
- Para tarefas independentes, despache em paralelo
- Nunca despache sem critérios de aceite

### Passo 5 — Consolidar
- Revise o output do sub-agente
- Verifique se critérios de aceite foram atendidos
- Se não atendidos, re-despache com feedback específico
- Apresente resultado consolidado ao usuário

## Anti-padrões (PROIBIDO)

| Anti-padrão | Correto |
|---|---|
| Despachar sem contexto | Incluir contexto completo no prompt |
| "Faça o que for preciso" | Definir tarefa e critérios específicos |
| Fazer direto o que deveria ser despachado | Regra dos 3 arquivos é inviolável |
| Despachar para agente errado | Consultar tabela de domínios |
| Ignorar output do sub-agente | Sempre revisar e consolidar |
