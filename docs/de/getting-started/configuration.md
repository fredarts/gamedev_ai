# Konfiguration (API-Key erhalten)

Gamedev AI verfügt über kein proprietäres Backend, um Ihre Daten zu stehlen. Es führt direkte (austauschbare) Aufrufe an die LLM-Server durch, die Sie bevorzugen. Alles indexierte Wissen wird aus Sicherheitsgründen lokal auf Ihrem Rechner gespeichert!

Damit das Plugin mit Ihrem Code kommunizieren und antworten kann, müssen wir einen **API-Key** bereitstellen.

## Nutzung von Google-Tools (Gemini) - Kostenlos
Die beliebteste, unglaublich intelligente und heute **kostenlose** Methode, das Plugin zu nutzen, ist über Google AI Studio mit Gemini 2.5 Pro oder Gemini 2.5 Flash. Gemini 3.0 und 3.1 Pro sind kostenpflichtig.

1. Gehen Sie zu [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Melden Sie sich mit Ihrem Google-Konto an (für die kostenlose Stufe ist keine Kreditkarte erforderlich).
3. Klicken Sie auf **"Get API key"** oder **"Create API key"**.
4. Kopieren Sie den generierten langen Key `(Beispiel: AIzaSyD......)`.

## Key im Editor verbinden

1. Klicken Sie im Gamedev AI Panel in Godot auf den oberen versteckten Reiter namens **"Settings"**.
2. Stellen Sie sicher, dass im Dropdown-Menü als Anbieter (Provider) **"Gemini"** ausgewählt ist.
3. Fügen Sie im Textfeld **API Key** Ihren vollständigen Key ein und achten Sie darauf, dass keine zusätzlichen Leerzeichen enthalten sind.
4. Geben Sie Ihr bevorzugtes Modell im Feld *Model Name* ein (Standard ist meist `gemini-2.5-pro` oder `gemini-2.5-flash`).

<br>

> **💡 Goldener Tipp!** 
>
> ![Einstellungs-Reiter mit den Feldern Preset, Provider und API Key](../../images/settings_ui.png)

## Nutzung von OpenRouter oder OpenAI

Präferenz für GPT-5.4, Claude Opus 4.6, Qwen3 Coder.
Gamedev AI unterstützt das OpenAI/OpenRouter-Ökosystem, ohne eine einzige Zeile Code zu ändern:
1. Gehen Sie zurück zum Reiter **Settings**.
2. Ändern Sie den Anbieter im Dropdown-Menü von `Gemini` auf `OpenAI / OpenRouter`.
3. Fügen Sie Ihren OpenAI- oder OpenRouter-Key hinzu.
4. Geben Sie im zusätzlichen Feld **Base URL** Folgendes ein:
   * Für OpenAI: `https://api.openai.com/v1`
   * Für OpenRouter: `https://openrouter.ai/api/v1`
5. Ändern Sie den Modellnamen (z.B. `gpt-5.4` oder `anthropic/claude-opus-4.6`).

Wir sind bereit zum Chatten!

[**Nächster Schritt: Sagen Sie "Hallo" zur KI** ➔](./quick-start.md)
