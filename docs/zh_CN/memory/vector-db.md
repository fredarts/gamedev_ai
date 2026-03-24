# 索引代码库 (分析大脑)

Gamedev AI 最有价值的资产之一，使其从传统的 ChatGPT 解决方案或其他 VSCode Copilot 中脱颖而出的，是它对您游戏项目连接结构的深刻理解。

如果说 "Open Context" 是 AI 当前的眼睛，那么 **Index Codebase** 就是机器人的潜在神经网络。

## 什么是矢量索引 (Vector DB)？

由于使用像 Godot 这样庞大的框架，许多自定义类（如 `PlayerStats`、`InventoryManager` 或 `WeaponBuilder`）并不属于 AI 几年前在 OpenAI 学到的经典 GDScript 手册的一部分。这些类是**您**创建的。

不断在聊天中复制 `PlayerStats` 脚本以询问有关库存的问题会消耗成千上万冗余令牌和宝贵时间。感谢数据库索引（矢量搜索），这已经成为过去。

### 使用索引 (设置按钮)
1. 前往 Gamedev AI 面板，点击顶部带有齿轮图标的上下文选项隐藏选项卡（位于底角的 "⚙️ Settings"）。
2. 向下滚动设置面板以打开 **Vector Database** 窗口。
3. 点击 **🔍 Scan Changes**。插件将检查硬盘上所有文件名是否有未报告的删除或修改。
4. 可视化 *文件列表* 将填满反映重要新增内容和未更改旧文件的颜色。如果与最后一次最终索引存在偏差：
5. 最后点击 **⚡ Index Database**。

这将通过 Gemini Text-Embedding API 激活不可见的索引模式。在该过程结束时，一个语义 RAG JSON 网络将以加密形式本地存储在硬盘上的 `.gamedev_ai/vector_db.json` 下。

现在在聊天中试试：
* *"我该如何修复库存中的错误？"*

AI 将回答： *"哦，我根据 `res://src/player_inventory.gd` 中的脚本和 `Network.gd` 中的调用注意到这些类没有持久连接。我将对此进行调整。"*

[**下一步：了解辅助 RAG 的 25 个“技能” (Skills) 文件** ➔](./skills.md)
