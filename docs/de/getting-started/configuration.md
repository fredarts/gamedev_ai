# Konfiguration (API-Key erhalten)

Gamedev AI verfügt über kein proprietäres Backend, um Ihre Daten zu stehlen. Es führt direkte (austauschbare) Aufrufe an die LLM-Server durch, die Sie bevorzugen. Alles indexierte Wissen wird aus Sicherheitsgründen lokal auf Ihrem Rechner gespeichert!

Damit das Plugin mit Ihrem Code kommunizieren und antworten kann, müssen wir einen **API-Key** bereitstellen.

## Nutzung von Google-Tools (Gemini) - Kostenlos
Die beliebteste, unglaublich intelligente und heute **kostenlose** Methode, das Plugin zu nutzen, ist über Google AI Studio mit Gemini 3.1 Pro oder Gemini 3.1 Flash. Gemini 4.0 befindet sich derzeit in der Beta-Phase.

1. Gehen Sie zu [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Melden Sie sich mit Ihrem Google-Konto an (für die kostenlose Stufe ist keine Kreditkarte erforderlich).
3. Klicken Sie auf **"Get API key"** oder **"Create API key"**.
4. Kopieren Sie den generierten langen Key `(Beispiel: AIzaSyD......)`.

## Key im Editor verbinden

1. Klicken Sie im Gamedev AI Panel in Godot auf den oberen versteckten Reiter namens **"Settings"**.
2. Stellen Sie sicher, dass im Dropdown-Menü als Anbieter (Provider) **"Gemini"** ausgewählt ist.
3. Fügen Sie im Textfeld **API Key** Ihren vollständigen Key ein und achten Sie darauf, dass keine zusätzlichen Leerzeichen enthalten sind.
4. Geben Sie Ihr bevorzugtes Modell im Feld *Model Name* ein (Standard ist meist `gemini-3.1-pro` oder `gemini-3.1-flash`).

<br>

> **💡 Goldener Tipp!** 
>
> ![Einstellungs-Reiter mit den Feldern Preset, Provider und API Key](../../images/settings_ui.png)

## Nutzung von OpenRouter oder OpenAI

Wenn Sie lieber auf Modelle wie Claude Opus 4.7, GPT-5.5 oder andere hochmoderne offene Modelle zugreifen möchten, unterstützt Gamedev AI nativ kompatible APIs.

1. Registrieren Sie sich und erhalten Sie Ihren API-Key unter:
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. Gehen Sie zurück zum versteckten Reiter **Settings** in Godot.
3. Ändern Sie den Anbieter im Dropdown-Menü von `Gemini` auf `OpenAI / OpenRouter`.
4. Fügen Sie Ihren **API-Key** ein.
5. Geben Sie im zusätzlichen Feld **Base URL** **genau** die entsprechende Adresse ein:
   * **OpenRouter:** `https://openrouter.ai/api/v1`
   * **OpenAI:** `https://api.openai.com/v1`
6. Ändern Sie das Feld **Model Name** in die gewünschte Modellkennung (z. B. `anthropic/claude-opus-4.7` oder `gpt-5.5`).

## Verwendung von NVIDIA NIM (Kostenloses DeepSeek und andere)

Die NVIDIA NIM-Plattform bietet schnellen und oft kostenlosen Zugriff auf viele High-End-Modelle wie die **DeepSeek**- und **Llama**-Serien über eine OpenAI-kompatible API.

1. Rufen Sie den [NVIDIA API-Katalog](https://build.nvidia.com/) auf und erstellen Sie ein Konto, um Ihren API-Key zu erhalten.
2. Wählen Sie im Reiter **Settings** des Plugins den Anbieter **`OpenAI / OpenRouter`** aus.
3. Fügen Sie Ihren von NVIDIA generierten **API-Key** ein.
4. Geben Sie im Feld **Base URL** die genaue NVIDIA NIM-URL ein:
   * `https://integrate.api.nvidia.com/v1`
5. Geben Sie im Feld **Model Name** den Namen des gewünschten Modells ein.

> **⚠️ Warnung: Der Modellname bei NVIDIA**
> Bei NVIDIA NIM müssen Sie **unbedingt** das „Organisationspräfix“ vor dem Modellnamen angeben.
> Beispiel: Für DeepSeek sollten Sie nicht nur `deepseek-v4-pro` verwenden, sondern stattdessen **`deepseek-ai/deepseek-v4-pro`** (oder `deepseek-ai/deepseek-r1`). Für Llama wäre es `meta/llama-3.1-70b-instruct`. Wenn das Organisationspräfix nicht enthalten ist, gibt die API einen **404 - Not Found-Fehler** zurück.

## Nutzung lokaler Modelle (Ollama / LM Studio)

Möchten Sie KI-Modelle lieber direkt auf Ihrem Rechner ausführen, ohne auf externe APIs angewiesen zu sein und völlig kostenlos?

1. Installieren Sie [Ollama](https://ollama.ai) und laden Sie ein Modell in Ihrem Terminal herunter: `ollama pull llama3.1`
2. Stellen Sie sicher, dass Ollama läuft (über `ollama serve` oder lassen Sie die App offen).
3. Ändern Sie im Reiter **Settings** den Anbieter auf **`Local (Ollama / LM Studio)`**.
4. Das Feld **Base URL** wird automatisch mit `http://localhost:11434/v1` ausgefüllt.
5. Geben Sie den Namen des heruntergeladenen Modells in das Feld **Model Name** ein (z. B. `llama3.1`, `gemma4`, `deepseek-v4-pro`).
6. Das Feld API-Key wird automatisch deaktiviert (lokale Modelle benötigen keinen).

> **⚠️ Hinweis:** Die Geschwindigkeit und Qualität der Antworten hängen rein von der Hardware Ihres Rechners (Grafikkarte) und dem gewählten Modell ab.

Wir sind bereit zum Chatten!

[**Nächster Schritt: Sagen Sie "Hallo" zur KI** ➔](./quick-start.md)
