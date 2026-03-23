# Todas as Ferramentas da IA (Tools Reference)

O Gamedev AI possui **27 ferramentas internas** que a IA pode chamar autonomamente durante uma conversa. Essas ferramentas são o "braço mecânico" que permite à IA interagir diretamente com o Godot Engine, e cada uma é descrita abaixo agrupada por categoria.

## 🔧 Scripts (Criação e Edição de Código)

### `create_script`
Cria um novo arquivo GDScript (`.gd`) no caminho especificado com o conteúdo fornecido. A IA usa essa ferramenta para gerar scripts do zero.
- **Parâmetros:** `path` (res://...), `content` (código GDScript completo)

### `edit_script`
Substitui o conteúdo inteiro de um script existente por uma nova versão. A IA lerá o arquivo antes para garantir que tem a versão mais recente.
- **Parâmetros:** `path`, `content`
- ⚠️ *Deprecado em favor do `patch_script` para edições cirúrgicas.*

### `patch_script`
Edição cirúrgica: busca um bloco exato de código dentro do script e substitui apenas aquele trecho pelo novo conteúdo. Ideal para pequenas correções sem reescrever o arquivo inteiro.
- **Parâmetros:** `path`, `search_content` (bloco exato a encontrar), `replace_content` (novo bloco)

### `replace_selection`
Substitui o texto atualmente selecionado no Editor de Scripts do Godot. Funciona em conjunto com os botões de ação rápida (Refatorar, Corrigir, Explicar).
- **Parâmetros:** `text` (novo código para substituir a seleção)

### `view_file_outline`
Retorna a estrutura de um script sem o código completo: `class_name`, `extends`, funções, sinais, exports, enums, classes internas e constantes com números de linha.
- **Parâmetros:** `path`

---

## 🌳 Nodes (Manipulação da Scene Tree)

### `add_node`
Adiciona um novo nó à cena aberta no editor. Pode criar qualquer tipo de Node do Godot (Node2D, CharacterBody3D, Label, Button, etc.).
- **Parâmetros:** `parent_path` (use `.` para a raiz), `type` (classe do nó), `name`, `script_path` (opcional)

### `remove_node`
Remove um nó da Scene Tree da cena atual. Requer confirmação do usuário por ser uma ação destrutiva.
- **Parâmetros:** `node_path`

### `set_property`
Define uma propriedade em um nó da cena (posição, tamanho, texto, cor, etc.). Aceita números, vetores, cores e strings.
- **Parâmetros:** `node_path`, `property`, `value`

### `set_theme_override`
Define um override de tema em um Control node (tamanho de fonte, cor de fonte, estilo).
- **Parâmetros:** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
Conecta um sinal de um nó emissor a um método de um nó receptor na cena atual.
- **Parâmetros:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (opcional), `flags` (opcional)

### `disconnect_signal`
Desconecta um sinal previamente conectado entre dois nós.
- **Parâmetros:** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
Anexa um GDScript existente a um nó na cena.
- **Parâmetros:** `node_path`, `script_path`

### `analyze_node_children`
Retorna um dump detalhado da sub-árvore de um nó específico na cena editada. Útil para explorar hierarquias profundas.
- **Parâmetros:** `node_path`, `max_depth` (padrão: 5)

---

## 📂 Arquivos e Projeto

### `read_file`
Lê o conteúdo completo de qualquer arquivo do projeto.
- **Parâmetros:** `path`

### `list_dir`
Lista o conteúdo de um diretório do projeto.
- **Parâmetros:** `path`

### `find_file`
Busca um arquivo no projeto por nome (correspondência parcial).
- **Parâmetros:** `pattern`

### `remove_file`
Deleta um arquivo ou diretório do projeto. Requer confirmação.
- **Parâmetros:** `path`

### `move_files_batch`
Move ou renomeia múltiplos arquivos/diretórios em uma única operação em lote. Atualiza automaticamente todas as referências internas do Godot (`.tscn`, `.tres`).
- **Parâmetros:** `moves` (dicionário mapeando caminhos antigos para novos)

### `create_scene`
Cria um novo arquivo de cena (`.tscn`) e o abre no editor.
- **Parâmetros:** `path`, `root_type`, `root_name`

### `instance_scene`
Instancia uma cena `.tscn` existente como filha de outro nó na cena atual.
- **Parâmetros:** `parent_path`, `scene_path`, `name`

### `create_resource`
Cria um novo arquivo Resource (`.tres`). Útil para assets como Items, Stats ou configurações customizadas.
- **Parâmetros:** `path`, `type`, `properties` (opcional)

---

## 🔍 Busca e Análise

### `grep_search`
Busca texto dentro dos arquivos do projeto. Retorna linhas correspondentes com caminho e número da linha.
- **Parâmetros:** `query`, `include` (filtro de extensão, opcional), `max_results` (padrão: 20)

### `search_in_files`
Busca padrões regex em todos os arquivos `.gd` do projeto para encontrar usos de variáveis, funções ou lógica específica.
- **Parâmetros:** `pattern` (expressão regular)

### `get_class_info`
Retorna informações detalhadas sobre uma classe do Godot (Engine ou Custom): classe base, propriedades, métodos e sinais.
- **Parâmetros:** `class_name`

### `capture_editor_screenshot`
Tira uma captura de tela de toda a janela do Editor Godot e a anexa automaticamente ao próximo prompt para análise visual.

---

## 🧠 Memória e Conhecimento

### `save_memory`
Salva um fato persistente na memória do projeto que estará disponível em todas as sessões futuras de chat.
- **Parâmetros:** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
Lista todos os fatos persistentes armazenados para este projeto.

### `delete_memory`
Deleta um fato de memória específico pelo seu ID.
- **Parâmetros:** `id`

### `read_skill`
Lê um arquivo de documentação de Skill da biblioteca interna da IA para aprender melhores práticas antes de programar.
- **Parâmetros:** `skill_name`

---

## 🗄️ Banco Vetorial (RAG)

### `index_codebase`
Indexa todo o projeto (`.gd`) em um Vector Database local para busca semântica. Deve ser executado antes de usar `semantic_search`.

### `semantic_search`
Realiza uma busca semântica vetorial no codebase indexado para encontrar snippets de código altamente relevantes baseados em significado, não em correspondência exata de texto.
- **Parâmetros:** `query`

---

## 🧪 Testes

### `run_tests`
Executa um script de teste ou comando. Útil para verificar mudanças com GUT, GdUnit4, ou scripts de teste customizados.
- **Parâmetros:** `test_script_path` (opcional)
