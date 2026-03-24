# 自定义系统提示 (Custom System Prompt)

有时工作室项目有严格的准则，我们不希望 AI 对所有生成的代码做出通用的决策。您如何塑造 Gamedev AI 的默认“思维”行为？

## "Custom Instructions" 面板

位于隐藏的 **Settings** 选项卡中，就在 "API Key" 提供商字段下方。
那里有一个大型自由文本字段 **Custom Instructions (appended to system prompt)**。

![显示自定义指令区域的设置面板](../../images/settings_ui.png)

每当 AI “思考”时，那里存储的指令都会在回答您之前被作为全局规则第 1 条读取。

### 该字段内容示例：
* *"请不要写长篇解释或问候，只显示专注的差异窗口"*
* *"此工作室的所有 Godot 项目都使用 Clean Code 约定。方法必须以英文小写字母开头，场景节点必须使用 PascalCase。在所有创建的函数中严格使用静态类型 (: String, : int, -> void)。"*
* *"我禁止使用 _process()。我希望您专注于大量使用信号 (Signals) 以保证性能的架构。"*

有了这个功能，Gamedev AI 就成为了一个专门由首席技术官（您）塑造的开发人员，按照您的团队认可的方式创建代码，而不是遵循 LLM 的通用语法。
