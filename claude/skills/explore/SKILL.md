---
name: explore
description: Exploração estruturada de codebase — discovery e deep dive.
argument-hint: "[diretório ou pergunta sobre o código]"
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent
model: sonnet
effort: high
context: fork
---

# Explore — Exploração Estruturada de Codebase

Explore o codebase: `$ARGUMENTS`

## Fase 1 — Discovery (visão geral)

### 1. Estrutura do projeto
```bash
# Árvore de diretórios (excluir node_modules, .git, etc.)
find . -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/__pycache__/*' | head -100
```

### 2. Stack e dependências
- Identificar: linguagem(ns), framework(s), banco(s), ferramentas
- Ler: package.json, go.mod, pyproject.toml, requirements.txt, Cargo.toml
- Mapear dependências principais e suas versões

### 3. Entry points
- Identificar ponto(s) de entrada: main, index, app, server
- Traçar o fluxo de inicialização

### 4. Padrões arquiteturais
- Organização: monolito, monorepo, microserviços
- Camadas: MVC, Clean Architecture, Hexagonal
- Comunicação: REST, GraphQL, gRPC, eventos

### 5. Mapa de arquitetura
```
## Mapa de Arquitetura

### Stack
- Linguagem: [X]
- Framework: [Y]
- Banco: [Z]
- Infra: [Docker/K8s/etc]

### Estrutura
[diagrama em texto da organização de diretórios]

### Fluxo principal
[entry point] → [camada 1] → [camada 2] → [dados]

### Dependências críticas
- [lib]: [para que é usada]
```

## Fase 2 — Deep Dive (foco específico)

Se o usuário pediu algo específico (ex: "como funciona a autenticação"):

### 1. Localizar
- Grep por termos relevantes
- Identificar arquivos-chave

### 2. Traçar
- Seguir o fluxo de dados/controle
- Mapear chamadas: quem chama → quem é chamado

### 3. Documentar
```
## Deep Dive: [tópico]

### Arquivos envolvidos
- [path]: [responsabilidade]

### Fluxo
1. [passo] — [arquivo:linha]
2. [passo] — [arquivo:linha]

### Pontos de atenção
- [observação relevante]
```

## Quando usar
- Projeto novo: "como esse projeto funciona?"
- Onboarding: "me explique a arquitetura"
- Investigação: "onde fica a lógica de X?"
- Antes de mudanças grandes: entender o terreno
