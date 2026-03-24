# Prompt de Sistema Personalizado

A veces, los proyectos de un estudio tienen restricciones estrictas y no queremos que la IA tome decisiones genéricas para todo el código creado. ¿Cómo se moldea el comportamiento "mental" predeterminado de Gamedev AI?

## El panel de "Instrucciones Personalizadas"

En la pestaña oculta de **Settings**, debajo del campo del proveedor de la "API Key".
Se encuentra el gran cuadro libre **Custom Instructions (appended to system prompt)**.

![Panel de ajustes que muestra el área de instrucciones personalizadas](../../images/settings_ui.png)

Cada vez que la IA "piense", las instrucciones colocadas allí se leerán como la Regla Número 1 universal antes de responderte.

### Ejemplos de qué pegar en este cuadro:
* *"Por favor, no escribas explicaciones largas ni saludos, solo muestra la ventana de Diff enfocada".*
* *"Todo el proyecto de Godot de este estudio usa la convención de Clean Code. Los métodos deben empezar con letras minúsculas en inglés y los nodos de escena con PascalCase. Usa tipado estático estricto (: String, : int, -> void) en todas las funciones creadas".*
* *"Prohibo el uso de etiquetas _process(). Quiero que te enfoques en una arquitectura con un uso intenso de Señales para el rendimiento".*

Con esto, Gamedev AI se convierte en un desarrollador moldeado específicamente por el CTO (Tú) y creará código de la manera que tu equipo aprueba en lugar de la sintaxis libre convencional de los LLMs.
