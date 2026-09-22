# 🔌 Godot Engine MCP Server Integration Guide (Zero Cost & 100% Local)

O plugin **Gamedev AI** inclui um **Servidor MCP Nativo** que permite que o **Antigravity**, Claude Desktop, Cursor ou qualquer IDE externa assuma o controle total do Godot Editor em tempo real, sem custos de infraestrutura e sem configurações complexas.

---

## ⚡ Como funciona?

1. Ao abrir o Godot com o plugin ativado, o Godot inicia um servidor local seguro na porta `127.0.0.1:6543`.
2. A IA externa se conecta ao Godot e ganha acesso a:
   - **30+ Ferramentas MCP (`tools`):** Criar nós, instanciar cenas, editar scripts, pintar tilemaps, gerar trilhas de animação, sintetizar áudio SFX e shaders.
   - **Recursos MCP (`resources`):** Inspecionar a árvore da cena ativa (`godot://scene/active`), ler diagnósticos do Godot LSP (`godot://lsp/diagnostics`) e memórias do projeto (`godot://memory/all`).
   - **25 Skills e Personas MCP (`prompts`):** Todas as regras de GDScript moderno, State Machines, Shaders e arquitetura de jogos criadas no plugin.

---

## 🚀 Como Configurar no Antigravity / Cursor / Claude Desktop

### Opção 1: Conexão via Antigravity / IDEs com Stdio (Recomendado)

No seu arquivo de configuração MCP (`mcp_config.json`):

```json
{
  "mcpServers": {
    "godot": {
      "command": "python",
      "args": [
        "addons/gamedev_ai/mcp/godot_mcp.py"
      ]
    }
  }
}
```

### Opção 2: Conexão Direta HTTP / SSE (Para Clientes Web / REST)

Se o seu cliente suportar conexão direta HTTP/SSE:
- **URL:** `http://127.0.0.1:6543`
- **Método:** `POST` (JSON-RPC 2.0)

---

## 🛠️ Lista de Ferramentas Disponíveis via MCP

| Categoria | Ferramenta | Descrição |
| :--- | :--- | :--- |
| **Nós & Cenas** | `add_node` | Adiciona nós à cena ativa configurando tipo e script. |
| | `remove_node` | Remove nós da hierarquia da cena. |
| | `instance_scene` | Instancia uma cena (.tscn) filha dentro de um nó. |
| | `set_property` | Altera qualquer propriedade de um nó no editor. |
| | `connect_signal` | Conecta sinais entre nós na cena. |
| | `create_scene` | Cria novos arquivos de cena `.tscn`. |
| **Scripts** | `create_script` | Cria arquivos `.gd` com tipagem estática e boas práticas. |
| | `edit_script` | Substitui e recarrega scripts na memória e no disco. |
| | `patch_script` | Modifica trechos específicos de código sem alterar o resto. |
| | `get_lsp_diagnostics` | Captura warnings e erros de compilação em tempo real via LSP. |
| **Tilemaps** | `configure_tileset_atlas` | Configura atlas de texturas para TileSet. |
| | `build_tilemap_layout` | Constrói layout de fases em matriz 2D/3D. |
| | `paint_terrain_cells` | Pinta terrenos e colisões com auto-tiling. |
| **Animações & Áudio** | `create_animation` | Cria animações no `AnimationPlayer`. |
| | `create_state_machine` | Cria máquinas de estados no `AnimationTree`. |
| | `generate_sfx` | Sintetiza efeitos sonoros procedurais (pulos, tiros, explosões). |
| | `generate_shader` | Gera shaders visuais customizados para nós e telas. |

---

## 🔒 Segurança e Privacidade

- **100% Local:** O servidor só escuta em `127.0.0.1` (localhost). Nenhuma informação sai do seu computador.
- **Zero Custo:** Não utiliza APIs intermediárias nem servidores na nuvem.
