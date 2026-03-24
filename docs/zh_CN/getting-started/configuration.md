# 配置 (获取 API 密钥)

Gamedev AI 没有专有的后端来偷取您的数据。它会直接调用您喜欢使用的 LLM 服务器。为了安全起见，所有索引的知识都存储在您本地的机器上！

为了让插件能够与您的代码对话并做出响应，我们需要提供一个 **API 密钥**。

## 使用 Google 工具 (Gemini) - 免费
目前使用该插件最流行、极其智能且**免费**的方法是通过 Google AI Studio 使用 Gemini 2.5 Pro 或 Gemini 2.5 Flash。Gemini 3.0 和 3.1 Pro 是收费的。

1. 前往 [Google AI Studio](https://aistudio.google.com/app/apikey)。
2. 使用您的 Google 账户登录（免费层级不需要信用卡）。
3. 点击 **"Get API key"** 或 **"Create API key"**。
4. 复制生成的长密钥 `(例如: AIzaSyD......)`。

## 在编辑器中连接密钥

1. 在 Godot 的 Gamedev AI 面板内，点击顶部名为 **"Settings"** 的隐藏选项卡。
2. 确保下拉菜单中选择的提供商 (Provider) 是 **"Gemini"**。
3. 在 **API Key** 文本字段中粘贴您的完整密钥，确保没有多余的空格。
4. 在 *Model Name* 字段中输入您喜欢的模型（默认通常是 `gemini-2.5-pro` 或 `gemini-2.5-flash`）。

<br>

> **💡 黄金提示！** 
>
> ![显示 Preset、Provider 和 API Key 字段的设置选项卡](../../images/settings_ui.png)

## 使用 OpenRouter 或 OpenAI

首选 GPT-5.4, Claude Opus 4.6, Qwen3 Coder。
Gamedev AI 支持 OpenAI/OpenRouter 生态系统，无需更改一行代码：
1. 回到 **Settings** 选项卡。
2. 将下拉菜单中的提供商从 `Gemini` 更改为 `OpenAI / OpenRouter`。
3. 添加您的 OpenAI 或 OpenRouter 密钥。
4. 在名为 **Base URL** 的额外字段中，输入：
   * 对于 OpenAI: `https://api.openai.com/v1`
   * 对于 OpenRouter: `https://openrouter.ai/api/v1`
5. 更改模型名称（例如 `gpt-5.4` 或 `anthropic/claude-opus-4.6`）。

我们准备好聊天了！

[**下一步：向 AI 说声“你好”** ➔](./quick-start.md)
