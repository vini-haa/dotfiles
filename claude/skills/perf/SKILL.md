---
name: perf
description: Analisa performance do código e sugere otimizações concretas.
argument-hint: "[arquivo ou diretório opcional]"
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent
model: sonnet
effort: high
context: fork
---

# Performance Analysis

Realize uma análise completa de performance no escopo indicado.

## Escopo

### Se um argumento foi fornecido
Analise o arquivo ou diretório: `$ARGUMENTS`

### Se nenhum argumento foi fornecido
Analise o diretório raiz do projeto atual. Use `Glob` e `Bash` para mapear a estrutura e identificar os arquivos mais relevantes (entry points, serviços, rotas, componentes principais).

Antes de iniciar, identifique o stack do projeto (linguagem, framework, ORM, biblioteca de UI) -- isso determina quais padrões procurar. Para projetos com muitos arquivos relevantes, use `Agent` para paralelizar a análise por categoria.

## Categorias de Análise (TODAS obrigatórias)

### 1. Queries e Acesso a Dados

Procure por:
- **N+1 queries**: loops que executam queries individuais em vez de buscar em lote (ex: `for item in items: db.query(...)`)
- **Indexes ausentes**: colunas usadas em `WHERE`, `JOIN` ou `ORDER BY` sem índice correspondente no schema
- **SELECT \***: queries que retornam todas as colunas quando apenas algumas são usadas
- **Eager loading desnecessário**: relações carregadas que nunca são acessadas no código

Use `Grep` para padrões de ORM (`.query(`, `.find(`, `.filter(`, `SELECT`, `JOIN`) e `Read` para schemas de migration.

### 2. Loops e Algoritmos

Procure por:
- **Complexidade O(n²) ou pior**: loops aninhados sobre a mesma coleção onde O(n) é viável
- **Computação repetida dentro de loop**: chamadas que produzem o mesmo resultado a cada iteração e poderiam ser memoizadas antes do loop
- **Busca linear em coleções**: `Array.includes`, `list.index()`, `.find()` dentro de loops -- candidatos a `Set` ou `Map` para lookup O(1)
- **Ordenações desnecessárias**: dados ordenados repetidamente sem mudança entre as ordenações

### 3. Memória e Alocações

Procure por:
- **Objetos grandes em hot paths**: alocações pesadas dentro de funções chamadas com alta frequência
- **Concatenação de strings em loop**: construção via `+=` em loop (use array + join ou StringBuilder)
- **Caches sem limite ou listas crescentes**: estruturas que crescem indefinidamente sem eviction policy
- **Memory leaks**: event listeners sem remoção correspondente, `setInterval`/`setTimeout` sem `clear*`, subscriptions não canceladas

### 4. I/O e Rede

Procure por:
- **Chamadas async sequenciais paralelizáveis**: `await a(); await b()` quando `a` e `b` são independentes -- use `Promise.all` ou equivalente
- **Cache ausente para dados estáveis**: dados buscados repetidamente que mudam raramente (configurações, listas de referência, resultados de queries lentas)
- **Payloads sem paginação**: endpoints que retornam coleções completas sem limit/offset ou cursor
- **I/O síncrono com alternativa async disponível**: `fs.readFileSync` onde `fs.readFile` seria viável, `time.sleep` onde async sleep existe

### 5. Frontend (quando aplicável)

Procure por:
- **Re-renders desnecessários**: componentes React/Vue/Svelte sem memoização recebendo props que mudam frequentemente; funções inline em JSX que recriam referências a cada render
- **Bundle sem code splitting**: imports estáticos de módulos pesados que poderiam ser carregados sob demanda via `import()` dinâmico
- **Imagens sem otimização**: `<img>` sem `loading="lazy"`, sem `width`/`height` explícitos, formatos não otimizados (JPEG/PNG onde WebP seria adequado)
- **Layout thrashing**: leituras e escritas de propriedades DOM intercaladas em loop (ex: ler `offsetHeight` e escrever `style` repetidamente)

## Regras de Análise

- Reporte apenas problemas com evidência de impacto real: hot paths, loops sobre dados de produção, endpoints de alta frequência.
- Não sugira otimizações prematuras -- se não há dado de que o trecho é um gargalo, classifique como Sugestão ou omita.
- Forneça snippets de código concretos no fix, não apenas descrições genéricas.
- Estime o impacto de forma específica: "elimina re-render do componente Table a cada keystroke", não "melhora performance".
- Se o escopo for grande demais para análise manual, use `Agent` para distribuir as categorias em paralelo e agregar os resultados.

## Formato de Saída

```
## Resumo
[1-2 frases sobre o estado geral de performance do código analisado.]

## Findings

### Critico (impacto alto)
- **[/caminho/arquivo.ext:linha]** Descrição clara do problema
  - Impacto: [ex: "executa N queries para listar N itens -- reduz para 1 query com eager load"]
  - Fix:
    ```linguagem
    // antes
    [trecho problemático]

    // depois
    [trecho corrigido]
    ```

### Importante (impacto médio)
- **[/caminho/arquivo.ext:linha]** Descrição clara do problema
  - Impacto: [estimativa qualitativa e específica]
  - Fix: [sugestão concreta, com snippet se necessário]

### Sugestao (impacto baixo)
- **[/caminho/arquivo.ext:linha]** Descrição
  - Impacto: [estimativa qualitativa]
  - Fix: [sugestão]

## Metricas Recomendadas
- [O que medir para validar que as otimizações surtiram efeito]
- [ex: "tempo médio de resposta do endpoint /api/items", "heap size após 1000 requisições"]
```
