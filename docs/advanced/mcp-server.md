# 🔌 Servidor MCP & Integração com IDEs Externas

O **Gamedev AI** traz suporte nativo ao **Model Context Protocol (MCP)**, permitindo que IDEs e agentes externos avançados como **Antigravity, Cursor, Claude Desktop e VS Code** assumam o controle do Godot Engine em tempo real.

---

## ⚡ O que é o MCP no Gamedev AI?

O **Model Context Protocol** é um padrão aberto que conecta assistentes de inteligência artificial a sistemas e ferramentas locais de forma padronizada. 

Com o servidor MCP integrado do Gamedev AI, você pode utilizar qualquer IDE ou agente externo para:
* **Inspecionar a Scene Tree:** Ler os nós da cena aberta (`godot://scene/active`).
* **Manipular o Editor em Tempo Real:** Criar nós, instanciar cenas (`.tscn`), configurar propriedades e conectar sinais.
* **Editar e Refatorar Scripts:** Criar scripts `.gd`, aplicar patches cirúrgicos e obter diagnósticos do compilador via LSP em tempo real.
* **Geração Procedural e Arte:** Construir TileMaps, configurar terrenos com auto-tiling, sintetizar SFX procedurais e gerar shaders de tela e objetos.
* **Executar Testes:** Rodar suítes de testes unitários do Godot e auditar cenas e nós.

> [!TIP]
> O servidor MCP do Gamedev AI é **100% local (`127.0.0.1:6543`)**, possui **zero custo de nuvem** e não envia nada fora da sua máquina.

---

## 🚀 Como Conectar sua IDE

### 1. Iniciar o Godot com o Plugin Ativo
Ao abrir qualquer projeto Godot 4.7+ com o plugin **Gamedev AI** ativado em `Project Settings > Plugins`, o servidor MCP inicia automaticamente em background escutando em `http://127.0.0.1:6543`.

### 2. Configuração no Antigravity / Cursor / Claude Desktop

No seu arquivo de configuração MCP (`mcp_config.json` ou `claude_desktop_config.json`):

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

> [!NOTE]
> O arquivo `addons/gamedev_ai/mcp/godot_mcp.py` atua como uma ponte (stdio bridge) de dependência zero entre a sua IDE e o servidor HTTP do Godot.

---

## 🛠️ Ferramentas Disponíveis via MCP

O servidor MCP expõe mais de **50 ferramentas agentics** prontas para uso direto:

| Categoria | Ferramenta | Descrição |
|---|---|---|
| **Nós & Cenas** | `add_node` | Adiciona nós à cena ativa configurando tipo e script. |
| | `remove_node` | Remove nós da hierarquia da cena. |
| | `instance_scene` | Instancia uma cena `.tscn` dentro de um nó pai. |
| | `set_property` | Altera propriedades no editor (posições, texturas, flags). |
| | `connect_signal` | Conecta sinais entre nós na cena. |
| | `create_scene` | Cria novos arquivos de cena `.tscn`. |
| **Scripts** | `create_script` | Cria arquivos GDScript com tipagem estática e boas práticas. |
| | `edit_script` | Substitui e recarrega scripts na memória e no disco. |
| | `patch_script` | Modifica trechos cirúrgicos de código. |
| | `get_lsp_diagnostics` | Captura warnings e erros de compilação em tempo real via LSP. |
| **Tilemaps & Procedural** | `configure_tileset_atlas` | Configura atlas de texturas para TileSet. |
| | `build_tilemap_layout` | Constrói layout de fases em matriz 2D/3D. |
| | `paint_terrain_cells` | Pinta terrenos e colisões com auto-tiling. |
| | `generate_procedural_dungeon` | Gera masmorras e mapas procedurais com salas e corredores. |
| **Áudio & VFX** | `generate_sfx` | Sintetiza efeitos sonoros procedurais (pulos, tiros, moedas, explosões). |
| | `generate_shader` | Gera shaders visuais customizados para nós e telas. |
| **Animações** | `create_animation` | Cria animações no `AnimationPlayer`. |
| | `create_state_machine` | Cria máquinas de estados no `AnimationTree`. |

---

## 📦 Recursos e Memória MCP

Além de executar ferramentas, agentes externos podem ler os recursos MCP registrados:
* `godot://scene/active` — Visualização completa da hierarquia de nós da cena aberta.
* `godot://lsp/diagnostics` — Lista de erros e avisos emitidos pelo Godot Language Server.
* `godot://memory/all` — Memórias persistentes e contexto salvo do projeto.
