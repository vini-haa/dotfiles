---
name: compact
description: Resume o contexto da sessão atual para liberar janela de contexto.
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
effort: medium
context: fork
---

# Compact

Analise o histórico da conversa atual e gere um resumo estruturado do contexto de trabalho. O objetivo é produzir um bloco copiável que permita continuar o trabalho em uma nova sessão sem perda de contexto relevante.

## Processo

### 1. Analise o histórico da conversa
Percorra a conversa completa identificando:
- Qual projeto está sendo trabalhado (nome, stack, objetivo principal)
- Decisões técnicas tomadas e os motivos por trás delas
- Arquivos que foram lidos, criados ou modificados (com caminhos absolutos)
- Problemas diagnosticados e resolvidos
- Tarefas iniciadas mas ainda não concluídas
- O ponto exato onde o trabalho foi interrompido

### 2. Complemente com as ferramentas
Use as ferramentas disponíveis para confirmar o estado atual:
- `Read` para verificar o conteúdo atual de arquivos modificados
- `Grep` para localizar trechos de código discutidos
- `Glob` para listar arquivos de diretórios mencionados
- `Bash` para checar o estado do repositório (`git status`, `git log --oneline -5`)

### 3. Gere o resumo
Produza o bloco abaixo com no máximo 500 palavras. Foque em contexto acionável, não em histórico de conversa.

## Formato do Resumo

```
## Resumo da Sessão

### Contexto do Projeto
- **Projeto**: [nome ou descrição]
- **Stack**: [linguagens, frameworks, ferramentas principais]
- **Objetivo**: [o que estava sendo construído ou resolvido]
- **Diretório raiz**: [caminho absoluto]

### Decisões Tomadas
- [Decisão 1]: [motivo em uma frase]
- [Decisão 2]: [motivo em uma frase]

### Arquivos Modificados
- `/caminho/absoluto/arquivo.ext`: [o que foi alterado e por quê]
- `/caminho/absoluto/outro.ext`: [o que foi alterado e por quê]

### Problemas Resolvidos
- [Descrição do problema]: [como foi resolvido]

### Pendências
- [ ] [Tarefa pendente 1 -- descritiva o suficiente para ser retomada sem contexto adicional]
- [ ] [Tarefa pendente 2]

### Estado Atual
[2-3 frases descrevendo exatamente onde o trabalho parou. Inclua arquivo e linha se aplicável.]
```

## Regras

- Limite: 500 palavras -- corte detalhes de conversa, preserve contexto acionável.
- Use sempre caminhos absolutos, nunca relativos.
- Quando um arquivo foi modificado em trecho específico, indique o número de linha.
- Distingua claramente entre o que foi concluído e o que está em andamento.
- Não inclua trechos longos de código -- referencie arquivo e linha.
- Não inclua histórico de tentativas fracassadas, apenas o estado final correto.

## Saída Final

Após o bloco de resumo, exiba esta instrução para o usuário:

---

**Cole o resumo abaixo em uma nova sessão para continuar o trabalho:**

> "Continuando sessão anterior. Contexto: [cole o bloco acima aqui]. Retome a partir das pendências listadas."
