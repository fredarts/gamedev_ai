# Project Plan: Visual Shader & Material Synthesizer [COMPLETO, ROBUSTO & PRÁTICO]

## 📋 Resumo Executivo
- **Objetivo**: Integrar um assistente e estúdio visual completo para criação, customização dinâmica de Uniforms, visualização em tempo real (SubViewport 2D/3D) e aplicação em nós do Godot 4.x diretamente no plugin **Gamedev AI**.
- **Filosofia de Design**:
  - **Robusto & Completo**: Motor GDShader com suporte a 2D (`canvas_item`) e 3D (`spatial`), parser dinâmico de Uniforms com hints de cores e ranges numéricos, gravação recursiva de pastas e geração de companion `.tres` `ShaderMaterial`.
  - **Prático & Fácil de Usar**:
    - **Para a IA**: Ferramentas `generate_shader`, `apply_shader_to_node`, `get_shader_presets_list` com inferência semântica e criação automática na pasta `res://shaders/`.
    - **Para o Desenvolvedor**: Estúdio visual no Dock com live preview em SubViewport (Sprite 2D ou Mesh 3D), inspetor gerado dinamicamente com ColorPickers e Sliders, botão "Apply to Selected Node in Scene" e slash command `/shader <tipo>`.
    - **Para Multi-Agentes**: Nova persona `ShaderPersona` (`Role.SHADER_ARTIST`) focada em shaders de alta performance.

---

## 🏗️ Arquitetura Completa

```
                               ┌────────────────────────────────┐
                               │     Interação do Desenvolvedor │
                               │  - Aba 'Shaders' no Dock       │
                               │  - Slash Command: /shader toon │
                               │  - Chat da IA (Multi-Agente)   │
                               └───────────────┬────────────────┘
                                               │
                                               ▼
                               ┌────────────────────────────────┐
                               │           ShaderTools          │
                               │  - generate_shader             │
                               │  - apply_shader_to_node        │
                               │  - get_shader_presets_list     │
                               └───────────────┬────────────────┘
                                               │
                                               ▼
                               ┌────────────────────────────────┐
                               │        ShaderSynthesizer       │
                               │  - GDShader Code Builder       │
                               │  - Uniform Parser & Metadata   │
                               │  - ShaderMaterial (.tres) Gen  │
                               └───────────────┬────────────────┘
                                               │
                                               ▼
                               ┌────────────────────────────────┐
                               │          ShaderPresets         │
                               │  - 2D CanvasItem Effects       │
                               │  - 3D Spatial & Cel-Shading    │
                               │  - Default Uniform Values      │
                               └───────┬────────────────┬───────┘
                                       │                │
            ┌──────────────────────────┴────┐      ┌────┴──────────────────────────┐
            ▼                               ▼      ▼                               ▼
┌───────────────────────┐ ┌────────────────────┐ ┌───────────────────┐ ┌──────────────────────┐
│  Live SubViewport UI  │ │  Direct Scene Hook │ │    ShaderWriter   │ │   Filesystem Scan    │
│  (Preview 2D/3D com   │ │ Aplica material no │ │ Salva .gdshader e │ │ Notifica o Godot e   │
│   controles dinâmicos)│ │ nó selecionado     │ │ .tres organizados │ │ atualiza o FileSystem│
└───────────────────────┘ └────────────────────┘ └───────────────────┘ └──────────────────────┘
```

---

## 🎨 Biblioteca de Presets Integrada

### 2D Combat & Feedback
- `hit_flash`: Flash sólido de dano para sprites ao receberem impacto.
- `dissolve_2d`: Desintegração procedural com borda incandescente de queima.
- `outline_2d`: Contorno nítido ou suave com cor e espessura configuráveis.
- `shield_bubble`: Campo de força sci-fi pulsante com refração de borda.

### 2D Stylized & Retro
- `pixelate_2d`: Efeito de mosaico/pixelização retro dinâmico.
- `vhs_glitch`: Aberração cromática, distorção VHS e scanlines CRT.
- `hologram_2d`: Projeção holográfica azul ciano com flicker e scanlines.
- `chromatic_aberration`: Dispersão prismática RGB de lentes.

### 2D Nature & Ambience
- `water_ripple`: Distorção de ondas de calor ou ondulação de água 2D.
- `wind_sway_2d`: Balanço de vegetação/árvores/grama calculado em vertex.
- `fire_lava`: Plasma de fogo e magma em movimento dinâmico.

### 3D Spatial & Cel-Shading
- `toon_cel`: Cel-shading estilo anime com luz em degraus e sombras tingidas.
- `fresnel_rim`: Aura de energia e brilho de silhueta por ângulo de visão.
- `stylized_water_3d`: Ondas volumétricas em vertex com espuma e especular.
- `dissolve_3d`: Desintegração de malhas 3D com borda emissiva.
- `hologram_3d`: Holograma 3D translúcido com scanlines verticais.
- `foliage_wind_3d`: Deformação de vento 3D em vertex para folhagens e árvores.

---

## 📁 Arquivos do Módulo

1. `addons/gamedev_ai/shaders/uniform_parser.gd` - Parser regex/AST de variáveis `uniform` e hints.
2. `addons/gamedev_ai/shaders/shader_synthesizer.gd` - Compilador de ShaderMaterial em memória.
3. `addons/gamedev_ai/shaders/shader_presets.gd` - Catálogo completo de efeitos 2D e 3D.
4. `addons/gamedev_ai/shaders/shader_writer.gd` - Gravador de `.gdshader` e `.tres` com criação de pastas.
5. `addons/gamedev_ai/tools/shader_tools.gd` - Ferramentas de IA (`generate_shader`, `apply_shader_to_node`).
6. `addons/gamedev_ai/orchestration/personas/shader_persona.gd` - Persona de Technical Artist.
7. `addons/gamedev_ai/dock/dock_shader.gd` - Controlador do estúdio visual no Dock com SubViewport.
