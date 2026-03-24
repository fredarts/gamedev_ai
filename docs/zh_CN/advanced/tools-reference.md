# 所有 AI 工具 (Tool Reference)

Gamedev AI 拥有 **27 个集成工具**，AI 可以在对话过程中自主调用它们。这些工具是“机械臂”，允许 AI 直接与 Godot 引擎交互。下面按类别对每个工具进行说明。

## 🔧 脚本 (代码创建与编辑)

### `create_script`
在指定路径创建一个新的 GDScript 文件 (`.gd`)，并包含所提供的内。AI 使用此工具从头开始生成脚本。
- **参数:** `path` (res://...), `content` (完整的 GDScript 代码)

### `edit_script`
用新版本替换现有脚本的全部内容。AI 首先读取文件以确保拥有最新版本。
- **参数:** `path`, `content`
- ⚠️ *已弃用，建议针对特定局部修复使用 `patch_script`。*

### `patch_script`
局部修改 (Surgical Edit): 在脚本中搜索精确的代码块，并仅用新内容替换该部分，而无需重写整个文件。适用于小型修复。
- **参数:** `path`, `search_content` (搜索的精确块), `replace_content` (新块)

### `replace_selection`
替换 Godot 脚本编辑器中当前突出的文本。与快速操作按钮（重构、修复、解释）配合使用。
- **参数:** `text` (用于替换选定内容的新代码)

### `view_file_outline`
返回不带完整代码的脚本结构：`class_name`, `extends`, 函数、信号、Exports、枚举、内联类以及带行号的常量。
- **参数:** `path`

---

## 🌳 节点 (场景树操作)

### `add_node`
在编辑器中打开的场景中添加一个新节点。可以创建任何 Godot 节点类型（Node2D, CharacterBody3D, Label, Button 等）。
- **参数:** `parent_path` (根节点使用 `.`), `type` (节点类), `name`, `script_path` (可选)

### `remove_node`
从当前场景树中移除一个节点。由于这是破坏性操作，需要用户确认。
- **参数:** `node_path`

### `set_property`
设置场景节点上的一个属性（位置、大小、文本、颜色等）。接受数字、矢量、颜色和字符串。
- **参数:** `node_path`, `property`, `value`

### `set_theme_override`
设置 Control 节点上的主题覆盖（字体大小、字体颜色、样式）。
- **参数:** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
将当前场景中发送节点的信号连接到接收节点的方法。
- **参数:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (可选), `flags` (可选)

### `disconnect_signal`
断开两个节点之间之前连接的信号。
- **参数:** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
将现有的 GDScript 附加到场景中的节点。
- **参数:** `node_path`, `script_path`

### `analyze_node_children`
返回编辑场景中特定节点的子树的详细转储。对于探索深层层级非常有用。
- **参数:** `node_path`, `max_depth` (默认 5)

---

## 📂 文件与项目

### `read_file`
读取任何项目文件的完整内容。
- **参数:** `path`

### `list_dir`
列出项目目录的内容。
- **参数:** `path`

### `find_file`
按名称搜索项目文件（部分匹配）。
- **参数:** `pattern`

### `remove_file`
从项目中删除文件或目录。需要确认。
- **参数:** `path`

### `move_files_batch`
在单个批量操作中移动多个文件/目录或重命名它们。自动更新所有内部 Godot 引用 (`.tscn`, `.tres`)。
- **参数:** `moves` (将旧路径映射到新路径的字典)

### `create_scene`
创建一个新的场景文件 (`.tscn`) 并在编辑器中打开它。
- **参数:** `path`, `root_type`, `root_name`

### `instance_scene`
在当前场景中将现有 `.tscn` 场景作为另一个节点的子节点实例化。
- **参数:** `parent_path`, `scene_path`, `name`

### `create_resource`
创建一个新的资源文件 (`.tres`)。对于道具、统计数据或自定义配置等素材非常有用。
- **参数:** `path`, `type`, `properties` (可选)

---

## 🔍 搜索与分析

### `grep_search`
在项目文件内部搜索文本。返回带路径和行号的匹配行。
- **参数:** `query`, `include` (扩展名过滤，可选), `max_results` (默认 20)

### `search_in_files`
通过正则在所有项目 `.gd` 文件中搜索变量、函数或特定逻辑。
- **参数:** `pattern` (正则表达式)

### `get_class_info`
返回关于 Godot 类（引擎或自定义）的详细信息：基类、属性、方法和信号。
- **参数:** `class_name`

### `capture_editor_screenshot`
截取整个 Godot 编辑器窗口，并自动将其附加到下一个提示语中进行视觉分析。

---

## 🧠 记忆与知识

### `save_memory`
在项目记忆中保存一个持久事实，该事实在未来的所有聊天会话中都可用。
- **参数:** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
列出为此项目保存的所有持久事实。

### `delete_memory`
根据 ID 删除特定的记忆事实。
- **参数:** `id`

### `read_skill`
从 AI 的内部库中读取技能文档文件，以便在编程前学习最佳实践。
- **参数:** `skill_name`

---

## 🗄️ 矢量数据库 (RAG)

### `index_codebase`
将整个项目 (`.gd`) 索引到本地矢量数据库中进行语义搜索。必须在使用 `semantic_search` 之前执行。

### `semantic_search`
在索引的代码库上执行语义矢量搜索，根据含义（而非仅仅精确文本匹配）寻找高度相关的代码片段。
- **参数:** `query`

---

## 🧪 测试 (Tests)

### `run_tests`
执行测试脚本或命令。对于使用 GUT, GdUnit4 或自定义测试脚本检查更改非常有用。
- **参数:** `test_script_path` (可选)
