# Configuration (Getting an API Key)

Gamedev AI does not have a proprietary backend to steal your data. It makes direct calls (switchable) to the top LLM servers you prefer to use. All indexed knowledge is saved locally on your machine for safety!

For the plugin to speak and respond to your code, we need to provide an **API Key**.

## Using Google Tools (Gemini) - Free
The most popular, incredibly smart, and **free** way to use the plugin today is by using Google AI Studio with Gemini 2.5 Pro or Gemini 2.5 Flash. Gemini 3.0 and 3.1 pro are paid.

1. Access [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Log in with your Google account (no credit card required on the Free Tier).
3. Click on **"Get API key"** or **"Create API key"**.
4. Copy the generated long key `(example: AIzaSyD......)`.

## Connecting the Key in the Editor

1. Click on the hidden top tab called **"Settings"** inside the Gamedev AI panel in Godot.
2. Make sure the selected Provider in the dropdown menu is **"Gemini"**.
3. In the **API Key** text field, paste your entire key, making sure there are no extra spaces.
4. Type your preferred model in the *Model Name* field (the default is usually `gemini-2.5-pro` or `gemini-2.5-flash`).

<br>

> **💡 Golden Tip!** 

![Settings tab showing Preset, Provider and API Key fields](../../images/settings_ui.png)

## Using OpenRouter or OpenAI

Preference for GPT-5.4, Claude Opus 4.6, Qwen3 Coder.
Gamedev AI supports the OpenAI/OpenRouter ecosystem without changing a single line of code:
1. Go back to the **Settings** tab.
2. Change the Provider in the dropdown from `Gemini` to `OpenAI / OpenRouter`.
3. Add your OpenAI or OpenRouter key.
4. In the extra field called `Base URL`, enter:
   * For OpenAI: `https://api.openai.com/v1`
   * For OpenRouter: `https://openrouter.ai/api/v1`
5. Change the model name (e.g., `gpt-5.4` or `anthropic/claude-opus-4.6`).

We are ready to chat!

[**Next Step: Say "Hi" to the AI** \u27A4](./quick-start.md)
