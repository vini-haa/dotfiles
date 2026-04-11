---
paths:
  - "**/*.sql"
---

# SQL

## 🔴 Obrigatório (bloqueia review se violado)
- Evite `SELECT *` — liste as colunas explicitamente.
- Migrations: sempre reversíveis (up + down).
- Use prepared statements / queries parametrizadas — nunca concatenação.
- Nomeie constraints (`CONSTRAINT pk_users_id PRIMARY KEY`).

## 🟡 Esperado (deve corrigir salvo justificativa)
- Keywords em UPPERCASE (`SELECT`, `FROM`, `WHERE`).
- Uma coluna por linha em queries com mais de 3 colunas.
- Use CTEs (`WITH`) em vez de subqueries aninhadas para legibilidade.
- Sempre qualifique colunas com alias de tabela em JOINs.
- Prefira `JOIN` explícito sobre joins implícitos no `WHERE`.
- Indexação: todo `WHERE`, `JOIN ON` e `ORDER BY` frequente deve ter índice.

## 🔵 Recomendado (sugestão de melhoria)
- Indentação de 4 espaços.
- Ferramentas: `sqlfluff` com auto-detecção de dialeto (config em `.sqlfluff`).
- Considere particionamento para tabelas >10M rows com queries por range.
