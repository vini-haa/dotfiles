---
name: loop-recovery
description: Detecta e recupera de loops de retry, oscilação ou drift. Use quando perceber que está repetindo ações sem progresso.
argument-hint: "[descrição opcional do problema]"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Bash
model: sonnet
effort: high
---

# Loop Recovery

Pare, analise e recupere de um padrão improdutivo.

## Diagnóstico — Identifique o padrão

### 1. Oscilação (A → B → A → B)
Está alternando entre duas abordagens sem convergir?
```
Sinais:
- Desfez uma mudança que acabou de fazer
- Alternando entre duas implementações
- Revertendo e re-aplicando o mesmo fix
```

### 2. Retry cego (A → A → A)
Está repetindo a mesma ação esperando resultado diferente?
```
Sinais:
- Mesmo comando falhou 2+ vezes seguidas
- Mesmo erro aparece após cada tentativa
- Ajustes mínimos que não atacam a causa raiz
```

### 3. Drift (escopo expandindo)
Está tocando arquivos não-relacionados ao problema original?
```
Sinais:
- Editou 5+ arquivos para um fix que deveria ser em 1-2
- Está "consertando" coisas que não estavam quebradas
- Perdeu de vista o objetivo original
```

### 4. Rabbit hole (profundidade excessiva)
Está descendo camadas de abstração sem resolver o problema de superfície?
```
Sinais:
- Está debugando o framework em vez do código do usuário
- Chegou em código de terceiros/stdlib
- O fix requer entender 5+ camadas de indireção
```

## Protocolo de recuperação

### Passo 1 — PARAR
Não tente mais uma vez. Pare completamente.

### Passo 2 — Diagnosticar
Identifique qual dos 4 padrões acima está acontecendo.
Liste as últimas 3 ações tomadas e seus resultados.

### Passo 3 — Pivotar
Escolha UMA estratégia de pivot baseada no diagnóstico:

| Padrão | Pivot |
|---|---|
| **Oscilação** | Escolha a abordagem A ou B definitivamente. Liste prós/contras de cada. Comprometa-se com uma. |
| **Retry cego** | Releia o erro com calma. Identifique a causa raiz real (não o sintoma). Tente uma abordagem FUNDAMENTALMENTE diferente. |
| **Drift** | Volte ao objetivo original. Liste apenas os arquivos essenciais. Desfaça mudanças não-relacionadas. |
| **Rabbit hole** | Suba de volta para o nível do problema do usuário. Considere um workaround em vez de fix profundo. |

### Passo 4 — Limite
- Após 3 tentativas falhadas → mude de abordagem completamente
- Após 2 abordagens falhadas → reporte ao usuário com diagnóstico:
  ```
  ## 🔄 Loop Recovery Report
  **Objetivo**: [o que estou tentando fazer]
  **Tentativas**: [lista numerada do que tentei]
  **Padrão detectado**: [oscilação/retry/drift/rabbit hole]
  **Diagnóstico**: [por que está falhando]
  **Sugestão**: [abordagem diferente ou decisão que precisa do usuário]
  ```

### Passo 5 — Verificar resolução
Após o pivot, confirme que o novo caminho está fazendo progresso real:
- O output mudou? (não apenas o input)
- O erro é diferente? (progresso, mesmo que parcial)
- Está mais perto do objetivo? (menos arquivos com problema, testes passando)

Se não → volte ao Passo 3 com outra estratégia de pivot.

## Regra absoluta
NUNCA tente a mesma abordagem mais de 3 vezes. Se falhou 3x, está errada — mude.
