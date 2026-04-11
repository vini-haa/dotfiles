---
name: sync-memory
description: Reconcilia .memory/ local + repositório de memória remoto + Obsidian vault
---

# /sync-memory

Reconcilia todas as camadas de memória do sistema.

## Quando usar
- Ao trocar de máquina
- Após uma sessão longa
- Quando suspeitar que a memória está desatualizada
- Semanalmente como manutenção

## Workflow

### 1. Sincroniza repositório de memória
```bash
cd ~/memory && git pull --rebase 2>/dev/null; git push 2>/dev/null || echo "Remote não configurado"
```

### 2. Rebuild incremental dos embeddings
```bash
python3 ~/dotfiles/scripts/memory_bridge.py rebuild --incremental
```

### 3. Sincroniza com Obsidian (se vault configurado)
```bash
python3 ~/dotfiles/scripts/memory_bridge.py sync
```

### 4. Reporta status
```bash
python3 ~/dotfiles/scripts/memory_bridge.py status
```

## Output esperado
Relatório com:
- Número de memórias indexadas
- Tamanho dos vetores (numpy + ONNX)
- Última sincronização
- Pendências identificadas
