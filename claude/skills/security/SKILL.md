---
name: security-audit
description: Auditoria de segurança do código — analisa vulnerabilidades, dependências e configurações.
argument-hint: "[arquivo, diretório ou 'full' para projeto inteiro]"
user-invocable: true
allowed-tools: Read, Grep, Glob, Bash, Agent
model: opus
effort: high
context: fork
agent: security
---

# Security Audit

Execute uma auditoria de segurança em: `$ARGUMENTS`

Se o argumento for "full" ou vazio, audite o projeto inteiro.

## Escopo da auditoria

### 1. Secrets & Credenciais
```bash
# Procurar padrões suspeitos
grep -rn "password\|secret\|api_key\|token\|private_key" --include="*.py" --include="*.ts" --include="*.js" --include="*.go" --include="*.env" .
```
- Verificar .gitignore para .env e arquivos de credenciais
- Verificar se há secrets hardcoded

### 2. Vulnerabilidades de código
- SQL injection (queries concatenadas)
- XSS (output não-escaped)
- Command injection (shell commands com input de usuário)
- Path traversal (file paths com input de usuário)
- SSRF (URLs construídas com input de usuário)
- Insecure deserialization

### 3. Dependências
```bash
# Python
pip audit 2>/dev/null || echo "pip-audit não instalado"
# Node
npm audit 2>/dev/null || echo "npm não encontrado"
# Go
govulncheck ./... 2>/dev/null || echo "govulncheck não instalado"
```

### 4. Configuração
- CORS configurado corretamente?
- HTTPS forçado?
- Headers de segurança (CSP, HSTS, X-Frame-Options)?
- Rate limiting?
- Logging sem PII?

## Formato do relatório
```
# 🔒 Relatório de Segurança
Data: [data]
Escopo: [arquivos analisados]

## Sumário
- Crítico: X
- Alto: X
- Médio: X
- Baixo: X
- Info: X

## Vulnerabilidades
### 🔴 [CRÍTICO] Título
**Arquivo**: path:linha
**Impacto**: ...
**Correção**: ...

[repetir para cada finding]

## Recomendações gerais
1. ...
2. ...
```
