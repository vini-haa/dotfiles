---
paths:
  - "**/*"
---

# Segurança

## 🔴 Obrigatório (bloqueia review se violado)
- Nunca faça hardcode de secrets, tokens, senhas ou chaves de API.
- Sanitize todo input de usuário — SQL injection, XSS, command injection.
- Use prepared statements / parameterized queries para SQL.
- Autenticação: use bcrypt/argon2 para senhas; nunca MD5/SHA1.
- HTTPS obrigatório em produção.
- Logs: nunca logue dados sensíveis (senhas, tokens, PII).
- Path traversal: nunca use `path.normalize()` ou `path.join()` sozinhos para validar caminhos de usuário. Use `path.resolve()` + verificação de prefixo:
  ```
  const fullPath = path.resolve(baseDir, userInput)
  if (!fullPath.startsWith(baseDir + path.sep)) throw new Error('path traversal')
  ```
- Nunca confie em nomes de arquivo vindos do cliente — sanitize caracteres especiais e limite o comprimento.

## 🟡 Esperado (deve corrigir salvo justificativa)
- Use variáveis de ambiente ou secret managers para credenciais.
- Valide e escape output renderizado no frontend.
- CORS: configure explicitamente os domínios permitidos.
- Tokens JWT: prazo de expiração curto + refresh token rotativo.
- Dependências: mantenha atualizadas; rode `npm audit` / `pip audit` periodicamente.

## 🔵 Recomendado (sugestão de melhoria)
- Headers de segurança: CSP, HSTS, X-Frame-Options, X-Content-Type-Options.
- Rate limiting em endpoints públicos.
- Implementar circuit breaker para chamadas a serviços externos.
