#!/usr/bin/env bash
# Configura o repositório de memória centralizado
# Uso: bash scripts/setup_memory_repo.sh

set -euo pipefail

MEMORY_DIR="${HOME}/memory"

if [ -d "$MEMORY_DIR/.git" ]; then
    echo "✓ Repositório de memória já existe em $MEMORY_DIR"
    exit 0
fi

echo "→ Criando repositório de memória em $MEMORY_DIR..."
mkdir -p "$MEMORY_DIR"/{global,projects,session,todo,plan,patterns,.embeddings}

cd "$MEMORY_DIR"
git init
git branch -M main

cat > global/long-term.md << 'EOF'
# Memória de Longo Prazo

Insights acumulados entre sessões. Atualizado automaticamente pelo memory_bridge.py.

## Padrões técnicos identificados

## Bugs recorrentes

## Decisões arquiteturais importantes

## Preferências do desenvolvedor
EOF

cat > .gitignore << 'EOF'
*.pyc
__pycache__/
.DS_Store
*.tmp
EOF

cat > README.md << 'EOF'
# Memory Repository

Repositório privado de memória persistente entre sessões Claude Code.
NÃO compartilhar publicamente — contém contexto de projetos internos.

Sincronização automática via hooks do dotfiles.

## Estrutura

- `global/` — memória de longo prazo, padrões recorrentes
- `projects/` — contexto por projeto
- `session/` — logs de sessão (auto-gerados)
- `todo/` — tarefas pendentes entre sessões
- `plan/` — planos de implementação ativos
- `patterns/` — padrões de código identificados
- `.embeddings/` — índice vetorial (ignorado pelo git)
EOF

git add -A
git commit -m "chore(init): initialize memory repository"

echo ""
echo "✓ Repositório de memória criado em $MEMORY_DIR"
echo ""
echo "→ Próximo passo: crie um repo PRIVADO no GitHub chamado 'memory'"
echo "  Depois execute:"
echo "  cd ~/memory"
echo "  git remote add origin https://github.com/SEU_USUARIO/memory"
echo "  git push -u origin main"
echo ""
