# 配置 (获取 API 密钥)

Gamedev AI 没有专有的后端来偷取您的数据。它会直接调用您喜欢使用的 LLM 服务器。为了安全起见，所有索引的知识都存储在您本地的机器上！

为了让插件能够与您的代码对话并做出响应，我们需要提供一个 **API 密钥**。

## 使用 Google 工具 (Gemini)
目前使用该插件最流行且极其智能的方法是通过 Google AI Studio 使用 Gemini 3.1 Pro 或 Gemini 3.1 Flash。Gemini 4.0 目前处于测试阶段。

1. 前往 [Google AI Studio](https://aistudio.google.com/app/apikey)。
2. 使用您的 Google 账户登录（免费层级不需要信用卡）。
3. 点击 **"Get API key"** 或 **"Create API key"**。
4. 复制生成的长密钥 `(例如: AIzaSyD......)`。

## 在编辑器中连接密钥

1. 在 Godot 的 Gamedev AI 面板内，点击顶部名为 **"Settings"** 的隐藏选项卡。
2. 确保下拉菜单中选择的提供商 (Provider) 是 **"Gemini"**。
3. 在 **API Key** 文本字段中粘贴您的完整密钥，确保没有多余的空格。
4. 在 *Model Name* 字段中输入您喜欢的模型（默认通常是 `gemini-3.1-pro` 或 `gemini-3.1-flash`）。

<br>

> **💡 黄金提示！** 
>
> ![显示 Preset、Provider 和 API Key 字段的设置选项卡](../../images/settings_ui.png)

## 使用 OpenRouter 或 OpenAI

如果您更喜欢访问 Claude Opus 4.7、GPT-5.5 或其他最先进的开源模型，Gamedev AI 支持原生兼容的 API。

1. 在以下位置注册并获取您的 API 密钥：
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. 回到 Godot 内部隐藏的 **Settings** 选项卡。
3. 将下拉菜单中的提供商从 `Gemini` 更改为 `OpenAI / OpenRouter`。
4. 粘贴您的 **API Key**。
5. 在名为 **Base URL** 的额外字段中，**准确**输入相应的地址：
   * **OpenRouter:** `https://openrouter.ai/api/v1`
   * **OpenAI:** `https://api.openai.com/v1`
6. 将 **Model Name** 字段更改为所需的模型标识符（例如 `anthropic/claude-opus-4.7` 或 `gpt-5.5`）。

## 使用 NVIDIA NIM（免费 DeepSeek 及其他）

NVIDIA NIM 平台通过 OpenAI 兼容的 API，提供对许多高端模型（如 **DeepSeek** 和 **Llama** 系列）的快速且通常免费的访问。

1. 前往 [NVIDIA API 目录](https://build.nvidia.com/) 并创建一个账户以获取您的 API 密钥。
2. 在插件的 **Settings** 选项卡中，选择 **`OpenAI / OpenRouter`** 提供商。
3. 粘贴您生成的 NVIDIA **API Key**。
4. 在 **Base URL** 字段中，您必须输入准确的 NVIDIA NIM URL：
   * `https://integrate.api.nvidia.com/v1`
5. 在 **Model Name** 字段中，输入所需模型的名称。

> **⚠️ 警告：NVIDIA 中的模型名称**
> 在 NVIDIA NIM 中，您**必须**在模型名称前包含“组织前缀”。
> 示例：对于 DeepSeek，您不应只使用 `deepseek-v4-pro`，而应使用 **`deepseek-ai/deepseek-v4-pro`**（或 `deepseek-ai/deepseek-r1`）。对于 Llama，它将是 `meta/llama-3.1-70b-instruct`。如果不包含组织前缀，API 将返回 **404 - Not Found 错误**。

## 使用本地模型 (Ollama / LM Studio)

您是否更喜欢直接在自己的机器上运行 AI 模型，而不依赖外部 API，且完全免费？

1. 安装 [Ollama](https://ollama.ai) 并在终端中下载模型：`ollama pull llama3.1`
2. 确保 Ollama 正在运行（通过 `ollama serve` 或保持应用开启）。
3. 在 **Settings** 选项卡中，将提供商更改为 **`Local (Ollama / LM Studio)`**。
4. **Base URL** 字段将自动填充为 `http://localhost:11434/v1`。
5. 在 **Model Name** 字段中输入下载的模型名称（例如 `llama3.1`、`gemma4`、`deepseek-v4-pro`）。
6. API Key 字段将自动禁用（本地模型不需要密钥）。

> **⚠️ 注意：** 响应的速度和质量完全取决于您机器的硬件（显卡）和所选的模型。

我们准备好聊天了！

[**下一步：向 AI 说声“你好”** ➔](./quick-start.md)
