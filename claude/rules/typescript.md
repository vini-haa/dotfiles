---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---

# TypeScript / JavaScript

## 🔴 Obrigatório (bloqueia review se violado)
- Evite `any` — use `unknown` e faça narrowing, ou genéricos.
- Use `const` por padrão; `let` quando reatribuição for necessária; nunca `var`.
- Prefira TypeScript sobre JavaScript sempre que o projeto suportar.
- React: componentes funcionais + hooks; evite `useEffect` para lógica de negócio.

## 🟡 Esperado (deve corrigir salvo justificativa)
- Use `interface` para contratos públicos; `type` para unions/intersections.
- Async/await sobre `.then()` chains — exceto em composição funcional.
- Desestruturação moderada — se precisar de mais de 4 campos, extraia um tipo.
- Imports com caminho absoluto (aliases `@/`) quando o projeto tiver configurado.
- React: prefira server components (Next.js App Router) quando aplicável.

## 🔵 Recomendado (sugestão de melhoria)
- Ferramentas: `eslint` + `prettier` (configs no projeto, não globais).
- Use `satisfies` para validação de tipo sem widening.
- Prefira `Map`/`Set` sobre objetos quando as chaves são dinâmicas.
