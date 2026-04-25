# Configuración (Obtener una clave API)

Gamedev AI no tiene un backend propietario para robar tus datos. Realiza llamadas directas (intercambiables) a los servidores de LLM que prefieras usar. ¡Todo el conocimiento indexado se guarda localmente en tu máquina para tu seguridad!

Para que el complemento pueda hablar y responder a tu código, necesitamos proporcionar una **Clave API**.

## Uso de herramientas de Google (Gemini)
La forma más popular e increíblemente inteligente de usar el complemento hoy en día es mediante Google AI Studio con Gemini 3.1 Pro o Gemini 3.1 Flash. Gemini 4.0 está actualmente en beta.

1. Accede a [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Inicia sesión con tu cuenta de Google (no se requiere tarjeta de crédito en el Nivel Gratuito).
3. Haz clic en **"Get API key"** o **"Create API key"**.
4. Copia la clave larga generada `(ejemplo: AIzaSyD......)`.

## Conexión de la clave en el Editor

1. Haz clic en la pestaña superior oculta llamada **"Settings"** dentro del panel de Gamedev AI en Godot.
2. Asegúrate de que el Proveedor seleccionado en el menú desplegable sea **"Gemini"**.
3. In el campo de texto **API Key**, pega tu clave completa, asegurándote de que no haya espacios adicionales.
4. Escribe tu modelo preferido en el campo *Model Name* (el valor predeterminado suele ser `gemini-3.1-pro` o `gemini-3.1-flash`).

<br>

> **💡 ¡Consejo de Oro!** 
>
> ![Pestaña de ajustes que muestra los campos Preset, Provider y API Key](../../images/settings_ui.png)

## Uso de OpenRouter u OpenAI

Si prefieres acceder a modelos como Claude Opus 4.7, GPT-5.5 u outros modelos abiertos de vanguardia, Gamedev AI admite API compatibles de forma nativa.

1. Regístrate y obtén tu clave API en:
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. Regresa a la pestaña oculta **Settings** dentro de Godot.
3. Cambia el Proveedor en el desplegable de `Gemini` a `OpenAI / OpenRouter`.
4. Pega tu **API Key**.
5. En el campo adicional llamado **Base URL**, ingresa **exactamente** la dirección correspondiente:
   * **OpenRouter:** `https://openrouter.ai/api/v1`
   * **OpenAI:** `https://api.openai.com/v1`
6. Cambia el campo **Model Name** por el identificador del modelo (por ejemplo, `anthropic/claude-opus-4.7` o `gpt-5.5`).

## Uso de NVIDIA NIM (DeepSeek gratuito y otros)

La plataforma NVIDIA NIM ofrece acceso rápido y a menudo gratuito a varios modelos de vanguardia, como las series **DeepSeek** y **Llama**, a través de una API compatible con el estándar de OpenAI.

1. Accede al [Catálogo de API de NVIDIA](https://build.nvidia.com/) y crea una cuenta para obtener tu clave API.
2. En la pestaña **Settings** del complemento, selecciona el proveedor **`OpenAI / OpenRouter`**.
3. Pega tu **API Key** generada por NVIDIA.
4. En el campo **Base URL**, debes ingresar la URL exacta de NVIDIA NIM:
   * `https://integrate.api.nvidia.com/v1`
5. En el campo **Model Name**, ingresa el nombre del modelo deseado.

> **⚠️ Advertencia: El nombre del modelo en NVIDIA**
> En NVIDIA NIM, es **obligatorio** incluir el "prefijo de la organización" antes del nombre del modelo.
> Ejemplo: Para DeepSeek, não debes usar solo `deepseek-v4-pro`, sino **`deepseek-ai/deepseek-v4-pro`** (o `deepseek-ai/deepseek-r1`). Para Llama, sería `meta/llama-3.1-70b-instruct`. Si no se incluye el prefijo de la organización, la API devolverá um **error 404 - No encontrado**.

## Uso de Modelos Locales (Ollama / LM Studio)

¿Prefieres ejecutar modelos de IA directamente en tu máquina, sin depender de API externas y de forma totalmente gratuita?

1. Instala [Ollama](https://ollama.ai) y descarga un modelo en tu terminal: `ollama pull llama3.1`
2. Asegúrate de que Ollama se esté ejecutando (comando `ollama serve` o mantén la aplicación abierta).
3. En la pestaña **Settings**, cambia el Proveedor a **`Local (Ollama / LM Studio)`**.
4. El campo **Base URL** se completará automáticamente con `http://localhost:11434/v1`.
5. Escribe el nombre del modelo descargado en el campo **Model Name** (ej.: `llama3.1`, `gemma4`, `deepseek-v4-pro`).
6. El campo API Key se deshabilitará automáticamente (los modelos locales no lo necesitan).

> **⚠️ Nota:** La velocidad y calidad de las respuestas dependen puramente del hardware (GPU) de tu máquina y del modelo elegido.

¡Estamos listos para chatear!

[**Siguiente paso: Di "Hola" a la IA** ➔](./quick-start.md)
