# Chat, Adjuntos y Contexto (Los Pulmones del Complemento)

El Chat es algo más que un simple ChatGPT incrustado en la ventana derecha de tu editor. Es el verdadero "sistema respiratorio" entre tus **Archivos de Juego** y la **Mente de la IA**.

## La Importancia del "Contexto" (Leer tu código actual)

La Inteligencia Artificial no puede ver tu monitor y no sabe qué estás programando en este momento — *¡A menos que le digas que mire!*

Debajo de la barra de *"Enviar"*, verás una casilla de verificación importante llamada **Contexto**.
1. **Activado (Predeterminado):** Gamedev AI copiará secretamente cada línea y carácter del archivo (`.gd`) donde parpadea el cursor en ese momento en tu ventana de Script. ¡Lo enviará junto con la pregunta que hagas!
2. **Desactivado:** Ahorra tus "Tokens" de contexto limitado en modelos de pago (OpenAI), realizando una pregunta ciega y rápida como el ChatGPT genérico. Úsalo cuando tengas un problema aislado que no requiera contexto de la engine.

## 📸 Captura de Pantalla (Snapshot Automático)

Junto al interruptor de Contexto, hay un interruptor de **Captura de Pantalla**. Esta función permite que la IA "vea" literalmente lo que hay en tu pantalla de Godot.

### Cómo funciona
1. **Activa el interruptor "Screenshot"** en la barra inferior del Chat.
2. El siguiente mensaje que envíes irá acompañado de una **captura de pantalla automática** de toda la ventana del editor de Godot.
3. La IA recibirá la imagen completa y podrá analizar visualmente: la escena 2D/3D abierta, el Árbol de Escenas (Scene Tree), el Inspector, la Salida (Output) y cualquier otro panel visible.

### Cuándo usarlo
- **UI Rota:** ¿La interfaz de tu juego está desalineada pero no sabes qué Label o Container es el culpable? Activa la captura, envía "¿Qué pasa con este diseño?" y la IA analizará visualmente los nodos.
- **Árbol de Escenas Complejo:** Quieres que la IA entienda cómo está organizada la jerarquía de nodos sin tener que describir cada uno manualmente.

::: tip Consejo
La IA también tiene la herramienta `capture_editor_screenshot`, que puede invocar ella misma en cualquier momento durante una conversación si necesita "mirar" el editor por su cuenta.
:::

## Botón Planear Primero (Plan First)

Es muy común cometer errores al pedirle a la IA que cree toda la lógica de un RPG masivo de inmediato. El complemento te permite frenar la impulsividad robótica activando **Planear Primero**.

![Interruptor Plan First activo con el botón Execute Plan visible](../../images/plan_first.png)

* **Activado:** El complemento enviará una directiva estricta. *La IA no creará código*. Responderá exclusivamente con una lista numerada en Markdown enumerando los elementos del proyecto (Clases, Nombres y Funciones Base) que deben cambiarse.
* Después de revisar y aprobar, haz clic en el botón **"Ejecutar Plan"** que aparecerá automáticamente. La IA comenzará entonces a implementar todo lo que planeó.

## Adjuntos y Nodos Arrastrables

¿Necesitas analizar cómo está hecho un Sprite2D, o por qué la escena `Player.tscn` no colisiona con el RigidBody3D `Ground`?

El complemento Gamedev AI admite el arrastre Drag & Drop. No tienes que perder tiempo abriendo cada pestaña del Inspector que generó curiosidad o fallo visual...

![Archivos adjuntos mediante arrastrar y soltar en el campo de chat](../../images/drag_and_drop.png)

1. **Árbol de Escenas (Scene Tree):** Haz clic en un Nodo de la escena y arrástralo hacia la barra de texto. La IA usará el atajo para analizar todos los Metadatos del Nodo (posiciones ocultas, instanciaciones, etiquetas de colisionadores...) y entender por qué los vectores de fricción no parecen funcionar.
2. **Botón 📎 Adjuntar:** Úsalo para insertar Imágenes (`.png` de UI con bugs), archivos de guardado en bruto (`.json`) y capturas globales de scripts largos (aunque la indexación vectorial es el método más profesional).

---

## 🎙️ Lectura en voz alta (TTS - Text-to-Speech)

Gamedev AI tiene un reproductor de **narración de voz** integrado que convierte las respuestas de la IA en audio. Esto te permite escuchar las explicaciones mientras sigues programando sin tener que detenerte a leer bloques de texto.

![Reproductor de TTS compacto con botón de play y control de velocidad](../../images/tts_player.png)

### Cómo usarla
1. Después de que la IA responda a cualquier pregunta en el chat, haz clic en el botón **"▶ Leer en voz alta"** (situado justo debajo del área de chat).
2. El complemento enviará una solicitud para convertir el texto de la última respuesta en audio.
3. Aparecerá un reproductor de audio compacto con controles completos:

| Control | Función |
|----------|--------|
| **▶ Leer en voz alta** | Inicia la reproducción de la narración. |
| **⏹ (Detener)** | Detiene la reproducción inmediatamente. |
| **Barra de Progreso** | Te permite avanzar o retroceder en la narración arrastrando el deslizador. |
| **Velocidad (1.0x a 2.0x)** | Controla la velocidad de la narración. Usa 1.5x o 2.0x para escuchar más rápido. |

### Cuándo es útil
- **Respuestas largas:** ¿La IA ha explicado 3 párrafos sobre cómo funciona `NavigationAgent3D`? Escúchalo mientras ajustas los nodos en el Scene Tree.
- **Accesibilidad:** Para desarrolladores que prefieren aprender escuchando o que tienen dificultades con la lectura prolongada en pantalla.
- **Revisión pasiva:** ¡Deja que la IA narre el plan de refactorización mientras te tomas un café!

::: info Nota
La función TTS utiliza la API del proveedor configurado para sintetizar el audio. El flujo se guarda en caché, por lo que pausar y reanudar no conlleva ningún coste de tokens adicional.
:::

---

## ⚡ Botones de Acción Rápida

En la barra situada justo debajo del área de chat (y encima del campo de texto), hay **5 botones de acción rápida** que actúan como atajos inteligentes. Envían automáticamente un prompt preconfigurado junto con el código que hayas seleccionado en el Editor de Scripts de Godot.

### Cómo funcionan
1. **Abre cualquier script** (`.gd`) en el editor de código de Godot.
2. **Selecciona un trozo de código** con el ratón o el teclado (por ejemplo, una función completa, un bloque `if` o unas pocas líneas).
3. **Haz clic en uno de los botones** de abajo:

### Los 5 Botones

| Botón | Prompt Enviado | Qué hace la IA |
|-------|---------------|----------------|
| **✧ Refactorizar** | "Refactor this code" | Analiza el fragmento seleccionado y propone una versión más limpia y eficiente con mejores prácticas de GDScript. |
| **◆ Corregir** | "Fix errors in this code" | Identifica bugs, errores de sintaxis, tipos incorrectos o lógica defectuosa en el fragmento y genera una solución en Diff. |
| **💡 Explicar** | "Explain what this code does" | Explica línea por línea qué hace el fragmento en lenguaje natural, ideal para aprender o documentar. |
| **↺ Deshacer** | *(Acción directa)* | Deshace la última modificación que la IA realizó en el proyecto utilizando el sistema nativo de Deshacer/Rehacer de Godot. Sin prompt. |
| **🖥 Corregir Consola** | *(Lee la Salida)* | Lee los últimos errores rojos de la consola de Salida (Output) de Godot y los envía a la IA para diagnosticar y proponer una solución. |

### Ejemplo usando "Corregir Consola"
1. Ejecutas el juego mediante Godot (`F5`).
2. El juego falla y aparece un error rojo: `Attempt to call function 'die' in base 'null instance'`.
3. Sin copiar nada, haz clic en **🖥 Corregir Consola**.
4. La IA leerá el registro de Salida por su cuenta, encontrará el script problemático y sugerirá la corrección en un Diff seguro.

::: tip Consejo
El botón **"Corregir Consola"** es diferente del **"Modo Vigilancia"**. La Consola requiere un clic manual, mientras que el Modo Vigilancia funciona automáticamente en segundo plano tras ser activado.
:::
