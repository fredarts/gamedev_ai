# 25 项集成技能 (完整目录)

Gamedev AI 不仅仅是一个依赖于从互联网训练的记忆的通用 AI。它拥有 **25 个专家模块**，专门为 Godot 4.6 编写。这些模块在对话过程中会自动被咨询，以确保生成的代码符合最佳市场标准。

以下列出了所有 25 项技能及其目的和 AI 如何使用它们的示例。

---

## 📜 GDScript 与语言

### 1. `gdscript_style_guide`
**GDScript 代码风格指南。** 命名约定 (snake_case, PascalCase)、文件组织、静态类型、声明顺序以及根据官方 Godot 标准进行格式化的最佳实践。

### 2. `gdscript_modern_features`
**GDScript 现代特性。** Lambda 表达式、增强的静态类型、`await`、`super()`、类型枚举、高级 `match` 模式以及所有取代了旧语法的 GDScript 2.0+ 新功能。

### 3. `gdscript_deprecated`
**过时的 GDScript 特性。** Godot 3 和 Godot 4 之间被移除或替换的函数、方法和模式的完整列表。AI 咨询此技能以确保永不提供过时的代码。

### 4. `gdscript_recipes_and_patterns`
**GDScript 食谱与模式。** 针对常见问题的现成解决方案：单例 (Singleton)、对象池 (Object Pooling)、依赖注入 (Dependency Injection)、观察者 (Observer) 以及 GDScript 中的惯用实现。

### 5. `gdscript_signals_and_tweens`
**信号与补间动画 (Signals and Tweens)。** 关于 Godot 4 信号系统、`SceneTreeTween`、创建程序化动画、补间链以及通过信号实现解耦的最佳实践的深入指南。

---

## 🏗️ 架构与结构

### 6. `common_architectures`
**常见游戏架构。** 架构模式，如实体组件 (Entity-Component)、游戏的 MVC、服务定位器 (Service Locator)、事件总线 (Event Bus) 以及如何组织中大型 Godot 项目。

### 7. `project_structure_guidelines`
**项目结构指南。** 理想的文件夹组织 (`src/`, `assets/`, `ui/`, `autoloads/`)、文件命名约定、Autoload 还是依赖注入，以及何时选择哪种方法。

### 8. `state_machine_implementation`
**状态机实现。** 带有子节点的数学状态机模式、干净的转换、分层状态以及与 AnimationTree 的集成，用于复杂角色。

---

## 🎮 游戏系统

### 9. `inventory_and_item_systems`
**库存与道具系统。** 基于 Resource 的库存架构、插槽、堆叠、道具拖放、存档序列化和响应式库存 UI。

### 10. `quest_and_dialogue_systems`
**任务与对话系统。** 对话树的实现、带状态（活动/完成/失败）的任务系统、NPC、进度条件和 UI 连接。

### 11. `save_system_and_persistence`
**存档系统与持久化 (Persistence)。** 游戏状态到 JSON/二进制的完整序列化、自动保存、多个保存槽、存档版本控制以及更新期间的迁移。

### 12. `data_management_and_crafting`
**数据管理与合成 (Crafting)。** 带有基于资源的配方的合成系统、道具数据库、掉落表和游戏经济平衡。

---

## 🕹️ 机制与物理

### 13. `physics_and_collision_handling`
**物理与碰撞处理。** 图层/掩码 (Layers/Masks) 配置、CharacterBody2D/3D、RigidBody、射线检测 (Raycasting)、探测区域和解决常见物理问题。

### 14. `input_handling_and_remapping`
**输入处理与重映射。** InputMap、自定义动作、手柄/键盘/触摸支持、运行时的按键重映射、输入缓冲和死区。

### 15. `ai_and_pathfinding`
**AI 与路径规划。** NavigationServer2D/3D、NavigationAgent、避障 (Avoidance)、简化行为树、追逐、巡逻以及基于状态的敌人 AI。

---

## 🎨 视觉与音频

### 16. `shaders_and_vfx`
**着色器与特效 (VFX)。** Godot 着色器语言、消散效果、轮廓、扭曲、GPU 粒子、拖尾以及针对 2D/3D 游戏的 VFX 技术。

### 17. `post_processing_and_environment`
**后期处理与环境。** WorldEnvironment、辉光 (Glow)、雾 (Fog)、SSAO、SSR、色调映射、颜色校正和电影级环境设置。

### 18. `animation_and_cutscenes`
**动画与过场动画。** AnimationPlayer、AnimationTree、混合空间 (Blend Spaces)、动画状态机、AnimationPlayer 过场动画和平衡转换。

### 19. `audio_management_best_practices`
**音频管理最佳实践。** AudioBus、AudioStreamPlayer2D/3D、音效池、自适应音乐、淡入淡出、混音和音频系统组织。

---

## 🖥️ 界面与平台

### 20. `ui_ux_patterns`
**UI/UX 模式。** 响应式菜单、HUD、全局主题、手柄导航、屏幕转换、弹出窗口和 Godot 中的 UI 最佳实践。

### 21. `mobile_and_resolution_scaling`
**移动端与分辨率缩放。** 拉伸模式配置、宽高比、触摸输入、虚拟摇杆、针对移动设备的优化和多分辨率测试。

### 22. `localization_and_i18n`
**本地化与国际化 (i18n)。** 带有 `.csv`/`.po` 的翻译系统、TranslationServer、运行时语言切换、数字/日期格式化和 RTL（从右到左）支持。

---

## 🌐 多人游戏与性能

### 23. `multiplayer_and_networking_api`
**多人游戏与网络。** ENet、WebSocket、MultiplayerSpawner/Synchronizer、RPC、Authority、客户端-服务器架构、大厅系统和状态同步。

### 24. `performance_optimization`
**性能优化 (Performance Optimization)。** 性能分析、对象池、LOD、剔除 (Culling)、批量渲染、GDScript 优化、减少 Draw Calls 以及 60Hz 游戏技术。

### 25. `level_generation_and_pcg`
**关卡生成与 PCG。** 程序化地牢生成 (Procedural Dungeon Generation)、波函数坍缩 (Wave Function Collapse)、基于噪声的地形、自动图块集 (Auto-TileMaps) 和可复现的随机种子。

---

## 🛠️ 创建您自己的技能

技能系统是**可扩展的**！您可以在 `addons/gamedev_ai/skills/` 文件夹中创建自己的 `.md` 文件，以便向 AI 传授特定于项目的规则。

**示例：** 创建一个名为 `my_art_style.md` 的文件，内容如下：
```markdown
# 我们工作室的美术规则

- 所有素材必须是 16x16 或 32x32 像素。
- 使用受限调色板（最多 32 种颜色）。
- 角色动画至少需要 4 帧。
- 精灵命名格式：type_name_action_frame.png
```

AI 在为您项目创建或修改任何视觉素材时，都会遵循这些规则。
