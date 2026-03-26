# Guía Completa de la Interfaz de Usuario (Todos los Botones)

Esta página describe **cada botón, interruptor y control** presente en la interfaz de Gamedev AI dentro del editor de Godot.

![Vista general de la interfaz principal de Gamedev AI en Godot](../../images/main_interface.png)

## 🗂️ Pestañas Principales

El complemento tiene **3 pestañas** en la parte superior del panel:
- **Chat** — El panel conversacional principal con la IA.
- **Settings** (Ajustes) — Gestión de claves API, ajustes preestablecidos (presets), prompts e indexación.
- **Git** — Control de versiones integrado con GitHub.

---

## 💬 Pestaña de Chat

### Barra Superior
| Botón | Función |
|-------|--------|
| **Selector de Preset** | Desplegable para cambiar rápidamente entre diferentes configuraciones de proveedor/modelo (ej. "Gemini 3.1", "GPT-4o"). |
| **A-** / **A+** | Disminuye o aumenta el tamaño de la fuente del chat. |
| **+ New Chat** | Borra la conversación actual e inicia una sesión completamente nueva. |
| **⊙ History** | Menú desplegable que muestra todas las conversaciones pasadas. Haz clic en una para restaurar todo el contexto de esa sesión. |
| **💾 Summarize to Memory** | Envía un prompt automático pidiendo a la IA que resuma las decisiones arquitectónicas de la conversación actual y las guarde en la memoria persistente del proyecto. |

### Área de Chat (OutputDisplay)
- Muestra mensajes con formato BBCode admitiendo **negrita**, *cursiva*, `código en línea` y bloques de código con resaltado de sintaxis.
- Enlaces a archivos del proyecto en los que se puede hacer clic (haz clic para abrirlos en el editor).
- Aparece un botón flotante de **Copiar** al seleccionar texto para copiarlo rápidamente.

### Reproductor TTS (Text-to-Speech)

![Reproductor de TTS compacto con controles de reproducción](../../images/tts_player.png)

| Control | Función |
|----------|--------|
| **▶ Leer en voz alta** | Convierte la última respuesta de la IA en audio y la reproduce. Útil para escuchar explicaciones mientras programas. |
| **⏹ Detener** | Detiene la reproducción de audio. |
| **Deslizador de progreso** | Barra de progreso para retroceder o avanzar el audio. |
| **Velocidad (1.0x - 2.0x)** | Controla la velocidad de reproducción del TTS. |

### Botones de Acción Rápida
| Botón | Qué hace |
|-------|-----------|
| **✧ Refactorizar** | Envía el código seleccionado en el editor con el prompt "Refactorizar este código". La IA analiza y propone mejoras estructurales. |
| **◆ Corregir** | Envía el código seleccionado con "Corregir errores en este código". La IA identifica bugs y genera soluciones. |
| **💡 Explicar** | Envía el código seleccionado con "Explicar qué hace este código". La IA explica cada parte en español. |
| **↺ Deshacer** | Deshace la última acción que la IA ejecutó en el proyecto (usando el sistema Undo/Redo de Godot). |
| **🖥 Corregir Consola** | Lee los últimos errores rojos de la consola de Salida (Output) de Godot y los envía directamente a la IA para analizar y proponer soluciones. |

### Área de Entrada
| Elemento | Función |
|----------|--------|
| **Campo de texto** | Escribe tu mensaje. Usa `Shift + Enter` para enviar. |
| **📎 Adjuntar** | Abre un selector de archivos para adjuntar imágenes, scripts o cualquier archivo al prompt. |
| **➤ Enviar** | Envía el mensaje a la IA para su procesamiento. |
| **Arrastrar y soltar** | Arrastra nodos del Scene Tree o archivos del FileSystem directamente al campo de texto o área de chat. La IA recibirá todos los metadatos del nodo/archivo arrastrado. |

### Ajustes de Prompt (Selector)
Estas opciones están agrupadas bajo el icono ⚙️ junto al botón de enviar.

| Ajuste | Función |
|--------|--------|
| **Incluir Contexto** | Cuando está activado, el plugin adjunta automáticamente el contenido completo del script abierto en el editor al mensaje enviado. |
| **Enviar Captura** | Cuando está activado, toma automáticamente una captura de pantalla de la ventana de Godot y la envía con el mensaje para el análisis visual de la IA. |
| **Planificar Primero** | Cuando está activado, la IA no escribirá código. Solo responderá con un plan detallado en Markdown. Tras revisar, haz clic no botón "Ejecutar Plan" para que codifique. |
| **Modo Vigilancia** | Cuando está activado, la IA monitoriza el console de Godot. Si detecta errores críticos, propone correcciones automáticamente. |

---

## ⚙️ Pestaña de Settings (Ajustes)

### Gestión de Presets
| Elemento | Función |
|----------|--------|
| **Selector de Preset** | Desplegable para elegir entre los presets guardados. |
| **Add** | Crea un nuevo preset vacío para configurar otro proveedor/modelo. |
| **Edit** | Abre el panel de edición mostrando los campos Nombre, Proveedor, Clave API, URL Base y Modelo. |
| **Delete** | Elimina permanentemente el preset seleccionado. |
| **Done Editing** | Cierra el panel de edición guardando los cambios. |

### Campos de Edición de Presets
| Campo | Descripción |
|-------|-----------|
| **Nombre del Preset** | Nombre descriptivo para identificar el preset (ej. "Gemini 3.1 Gratis"). |
| **Proveedor** | Opción desplegable entre "Gemini" y "OpenAI / OpenRouter". |
| **Clave API** | Tu clave API del proveedor seleccionado. |
| **URL Base** | URL base de la API (solo para OpenAI/OpenRouter). |
| **Nombre del Modelo** | Nombre exacto del modelo (ej. `gemini-2.5-flash`, `gpt-4o`). |

### Idioma
| Elemento | Función |
|----------|--------|
| **Selector de Idioma** | Desplegable para elegir el idioma de la interfaz y de las respuestas de la IA (Português BR, English, Español, etc.). |

### Prompt de Sistema Personalizado
Un cuadro de texto grande donde puedes insertar reglas fijas que la IA seguirá siempre. Ejemplo: *"Usa tipado estático en todas las funciones. Comenta en español".*

| Botón | Función |
|-------|--------|
| **✨ Mejorar instrucciones con IA** | Envía tus instrucciones actuales para que la IA las mejore automáticamente, añadiendo detalles técnicos y mejores prácticas. Se muestra una vista previa antes de aceptar. |

### Base de Datos Vectorial
| Elemento | Función |
|----------|--------|
| **Lista de archivos** | Lista visual de todos los archivos `.gd` del proyecto con su estado de indexación (nuevo, modificado, sin cambios). |
| **🔍 Scan Changes** | Barre el proyecto en busca de archivos nuevos, modificados o eliminados desde la última indexación. |
| **⚡ Index Codebase** | Inicia el proceso de indexación vectorial de todos los scripts modificados usando la API de Embeddings. |

---

## 🐙 Pestaña de Git

### Configuración Inicial
| Elemento | Función |
|----------|--------|
| **Initialize Repository** | Inicializa un repositorio Git en la carpeta del proyecto (si no existe uno). |
| **Remote URL** | Campo para pegar la URL del repositorio de GitHub (ej. `https://github.com/usuario/repo.git`). |
| **Set Remote** | Establece la URL del repositorio remoto. |

### Operaciones Principales
| Botón | Función |
|-------|--------|
| **🔃 Refresh Status** | Refresca el estado de Git mostrando archivos modificados, no rastreados y la rama actual. |
| **⬇️ Pull** | Descarga los últimos cambios del repositorio remoto. |
| **✨ Auto-Generate Commit Message** | La IA analiza todos los archivos modificados (diff) y genera automáticamente un mensaje de commit profesional y descriptivo. |
| **Commit & Sync (Push)** | Realiza el commit de todos los cambios con el mensaje escrito/generado y los sube a GitHub. |

### Ramas (Branches)
| Elemento | Función |
|----------|--------|
| **Etiqueta de Rama** | Muestra el nombre de la rama actual. |
| **Entrada de Nombre de Rama** | Campo para escribir el nombre de una nueva rama o una rama existente. |
| **Checkout/Create Branch** | Crea una nueva rama o cambia a una existente. |

### Acciones de Emergencia
| Botón | Función |
|-------|--------|
| **⚠️ Undo Uncommitted Changes** | Descarta TODOS los cambios locales no confirmados, volviendo al estado del último commit. Requiere confirmación. |
| **⚠️ Force Pull Overwrite** | Sobrescribe completamente la carpeta local con el estado del repositorio remoto. Requiere confirmación. |
| **⚠️ Force Push** | Sube forzadamente el estado local al repositorio remoto, sobrescribiendo el historial. Requiere confirmación. |

---

## 📋 Panel de Diff (Revisión de Código)

Cuando la IA genera o modifica código, aparece un panel de Diff en el chat:

![Panel de Diff que muestra el código eliminado (rojo) y añadido (verde)](../../images/diff_preview.png)

| Elemento | Función |
|----------|--------|
| **Vista de Diff** | Vista lado a lado que muestra las líneas eliminadas (rojo) y añadidas (verde). |
| **Apply Changes** | Acepta los cambios y los aplica al archivo real. La acción queda registrada en el Undo/Redo de Godot. |
| **Skip** | Rechaza los cambios. No se altera ningún archivo. |
