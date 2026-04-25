# Configuration (Getting an API Key)

Gamedev AI does not have a proprietary backend to steal your data. It makes direct calls (switchable) to the top LLM servers you prefer to use. All indexed knowledge is saved locally on your machine for safety!

For the plugin to speak and respond to your code, we need to provide an **API Key**.

## Using Google Tools (Gemini)
The most popular and incredibly smart way to use the plugin today is by using Google AI Studio with Gemini 3.1 Pro or Gemini 3.1 Flash. Gemini 4.0 is currently in beta.

1. Access [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Log in with your Google account (no credit card required on the Free Tier).
3. Click on **"Get API key"** or **"Create API key"**.
4. Copy the generated long key `(example: AIzaSyD......)`.

## Connecting the Key in the Editor

1. Click on the hidden top tab called **"Settings"** inside the Gamedev AI panel in Godot.
2. Make sure the selected Provider in the dropdown menu is **"Gemini"**.
3. In the **API Key** text field, paste your entire key, making sure there are no extra spaces.
4. Type your preferred model in the *Model Name* field (the default is usually `gemini-3.1-pro` or `gemini-3.1-flash`).

<br>

> **💡 Golden Tip!** 

![Settings tab showing Preset, Provider and API Key fields](../../images/settings_ui.png)

## Using OpenRouter or OpenAI

If you prefer to access models like Claude Opus 4.7, GPT-5.5, or other cutting-edge open models, Gamedev AI supports natively compatible APIs.

1. Register and get your API Key at:
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. Go back to the hidden **Settings** tab inside Godot.
3. Change the Provider in the dropdown from `Gemini` to `OpenAI / OpenRouter`.
4. Paste your **API Key**.
5. In the extra field called **Base URL**, enter **exactly** the corresponding address:
   * **OpenRouter:** `https://openrouter.ai/api/v1`
   * **OpenAI:** `https://api.openai.com/v1`
6. Change the **Model Name** field to the desired model identifier (e.g., `anthropic/claude-opus-4.7` or `gpt-5.5`).

## Using NVIDIA NIM (Free DeepSeek and Others)

The NVIDIA NIM platform provides fast and often free access to many high-end models, such as the **DeepSeek** and **Llama** series, via an OpenAI-compatible API.

1. Go to the [NVIDIA API Catalog](https://build.nvidia.com/) and create an account to get your API Key.
2. In the plugin's **Settings** tab, select the **`OpenAI / OpenRouter`** provider.
3. Paste your NVIDIA generated **API Key**.
4. In the **Base URL** field, you must enter the exact NVIDIA NIM URL:
   * `https://integrate.api.nvidia.com/v1`
5. In the **Model Name** field, enter the name of the desired model.

> **⚠️ Warning: The Model Name in NVIDIA**
> In NVIDIA NIM, you are **required** to include the "organization prefix" before the model name.
> Example: For DeepSeek, you should not just use `deepseek-v4-pro`, but instead **`deepseek-ai/deepseek-v4-pro`** (or `deepseek-ai/deepseek-r1`). For Llama, it would be `meta/llama-3.1-70b-instruct`. If the organization prefix is not included, the API will return a **404 - Not Found error**.

## Using Local Models (Ollama / LM Studio)

Do you prefer to run AI models directly on your machine, without relying on external APIs and completely free of charge?

1. Install [Ollama](https://ollama.ai) and download a model in your terminal: `ollama pull llama3.1`
2. Ensure Ollama is running (via `ollama serve` or keep the app open).
3. In the **Settings** tab, change the Provider to **`Local (Ollama / LM Studio)`**.
4. The **Base URL** field will be automatically populated with `http://localhost:11434/v1`.
5. Enter the downloaded model name in the **Model Name** field (e.g., `llama3.1`, `gemma4`, `deepseek-v4-pro`).
6. The API Key field will be automatically disabled (local models do not need one).

> **⚠️ Note:** The speed and quality of the responses depend purely on your machine's hardware (GPU) and the chosen model.

We are ready to chat!

[**Next Step: Say "Hi" to the AI** \u27A4](./quick-start.md)
