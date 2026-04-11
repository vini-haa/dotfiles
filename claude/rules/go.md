---
paths:
  - "**/*.go"
---

# Go

## 🔴 Obrigatório (bloqueia review se violado)
- Erros: sempre verifique; retorne `error` em vez de usar panic.
- Goroutines: sempre tenha estratégia de cancelamento (`context.Context`).
- Siga as convenções idiomáticas de Go — Effective Go é a referência.
- Interfaces: defina no consumidor, não no provedor.

## 🟡 Esperado (deve corrigir salvo justificativa)
- Nomeação: curta e contextual (`r` para reader, `ctx` para context).
- Structs: campos exportados em PascalCase, privados em camelCase.
- Interfaces pequenas (1-3 métodos) — composição sobre herança.
- Channels: prefira direcionais (`chan<-`, `<-chan`) nas assinaturas.
- Use `table-driven tests` para cobrir múltiplos cenários.

## 🔵 Recomendado (sugestão de melhoria)
- Ferramentas: `gofmt` para format, `golangci-lint` para lint (config em `golangci.yml`).
- Considere `errgroup` para goroutines paralelas com erro.
- Use `sync.Once` para inicialização lazy thread-safe.
