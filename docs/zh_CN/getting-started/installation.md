# 安装 (Installation)

欢迎来到 **Gamedev AI** 官方文档！本页重点介绍如何快速将助手添加到您当前的 Godot 4.6 项目中。

## 先决条件 (Prerequisites)
* **Godot Engine:** 4.6 或更高版本（不需要原生 `.gdextension` 支持，插件运行在纯 GDScript 中）。
* 用于 API 密钥的 Google 或 OpenRouter 账户。

## 手动详细步骤 (GitHub)

1. 在 Godot 4.6 中创建或打开一个现有项目。
2. 导航到项目的根文件夹（`project.godot` 文件所在的目录）。
3. 创建一个名为 `addons` 的文件夹（如果尚不存在）。
4. 在 `addons/` 内部，下载或克隆插件存储库：
```bash
git clone git@github.com:fredarts/gamedev_ai.git
```
*(或者从 GitHub 的 Releases 标签下载 `.zip` 文件并解压到 `res://addons/gamedev_ai`)。*

## 在编辑器中激活 (Activation)

文件到位后：
1. 打开您的 Godot 项目编辑器。
2. 转到顶部的 `Project` 菜单并选择 `Project Settings`。
3. 导航到顶部的 `Plugins` 选项卡。
4. 在已安装插件列表中找到 **Gamedev AI**。
5. 勾选 `Enabled` 旁边的框。

就这样！第一次启用时，您会看到 Gamedev AI 聊天面板出现在编辑器右侧的 *Dock* 中。

[**下一步：配置您的 API 密钥** ➔](./configuration.md)
