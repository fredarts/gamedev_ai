# Configuración (Obtener una clave API)

Gamedev AI no tiene un backend propietario para robar tus datos. Realiza llamadas directas (intercambiables) a los servidores de LLM que prefieras usar. ¡Todo el conocimiento indexado se guarda localmente en tu máquina para tu seguridad!

Para que el complemento pueda hablar y responder a tu código, necesitamos proporcionar una **Clave API**.

## Uso de herramientas de Google (Gemini) - Gratis
La forma más popular, increíblemente inteligente y **gratuita** de usar el complemento hoy en día es mediante Google AI Studio con Gemini 2.5 Pro o Gemini 2.5 Flash. Gemini 3.0 y 3.1 Pro son de pago.

1. Accede a [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Inicia sesión con tu cuenta de Google (no se requiere tarjeta de crédito en el Nivel Gratuito).
3. Haz clic en **"Get API key"** o **"Create API key"**.
4. Copia la clave larga generada `(ejemplo: AIzaSyD......)`.

## Conexión de la clave en el Editor

1. Haz clic en la pestaña superior oculta llamada **"Settings"** dentro del panel de Gamedev AI en Godot.
2. Asegúrate de que el Proveedor seleccionado en el menú desplegable sea **"Gemini"**.
3. In el campo de texto **API Key**, pega tu clave completa, asegurándote de que no haya espacios adicionales.
4. Escribe tu modelo preferido en el campo *Model Name* (el valor predeterminado suele ser `gemini-2.5-pro` o `gemini-2.5-flash`).

<br>

> **💡 ¡Consejo de Oro!** 
>
> ![Pestaña de ajustes que muestra los campos Preset, Provider y API Key](../../images/settings_ui.png)

## Uso de OpenRouter u OpenAI

Preferencia por GPT-5.4, Claude Opus 4.6, Qwen3 Coder.
Gamedev AI admite el ecosistema de OpenAI/OpenRouter sin cambiar una sola línea de código:
1. Regresa a la pestaña **Settings**.
2. Cambia el Proveedor en el desplegable de `Gemini` a `OpenAI / OpenRouter`.
3. Añade tu clave de OpenAI o OpenRouter.
4. En el campo adicional llamado `Base URL`, ingresa:
   * Para OpenAI: `https://api.openai.com/v1`
   * Para OpenRouter: `https://openrouter.ai/api/v1`
5. Cambia el nombre del modelo (por ejemplo, `gpt-5.4` o `anthropic/claude-opus-4.6`).

## Uso de Modelos Locales (Ollama / LM Studio)

¿Prefieres ejecutar modelos de IA directamente en tu máquina, sin depender de API externas?
Gamedev AI admite cualquier servidor compatible con la API de OpenAI que se ejecute localmente:

1. Instala [Ollama](https://ollama.ai) y descarga un modelo: `ollama pull llama3.1`
2. Asegúrate de que Ollama se esté ejecutando (`ollama serve`).
3. En la pestaña **Settings**, cambia el Proveedor a **`Local (Ollama / LM Studio)`**.
4. El campo **Base URL** se completará automáticamente con `http://localhost:11434/v1`.
5. Escribe el nombre del modelo en el campo **Model Name** (ej.: `llama3.1`, `gemma3`, `qwen3`).
6. El campo API Key se deshabilitará automáticamente (los modelos locales no lo necesitan).

> **⚠️ Nota:** La calidad de las respuestas depende del modelo local elegido y de los recursos de hardware disponibles.

¡Estamos listos para chatear!

[**Siguiente paso: Di "Hola" a la IA** ➔](./quick-start.md)
