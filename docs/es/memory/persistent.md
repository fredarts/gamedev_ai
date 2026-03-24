# Memoria Persistente (La IA como Arquitecto)

Si la Indexación (Código) le enseña a la IA **"Dónde"** se encuentra cada código fuente que Godot ha procesado alguna vez, la Memoria Persistente le enseña **"Por qué"** se programaron las cosas de esa manera.

Los desarrolladores en solitario y los estudios pequeños sufren después de semanas sin abrir un proyecto. *¿Por qué la clase Save Game guarda en binario y no en JSON? ¿Por qué usé CharacterBody2D y cambié de opinión más tarde?*

## El botón "Resumir en la Memoria"

En la pestaña superior central del panel de Chat `(junto al botón de Historial)`, descansa el brillante botón **💾 Summarize to Memory**.

Cada vez que tengas una sesión larga, ardua y compleja con la IA (por ejemplo, refactorizar todo el sistema de física de coches), sigue este paso:
1. Al final del día, haz clic en **Summarize to Memory**.
2. La IA realizará una lectura profunda de todo lo debatido.
3. Creará archivos con formato de *Registro de Memoria* permanente en la carpeta invisible `.gamedev_ai` de tu proyecto.
4. Cuando abras el proyecto 3 semanas después para solucionar un bug en la física del coche, la IA sacará mágicamente de sus entrañas la razón por la que no usaste la "Fricción" nativa de Godot sin que tengas que abrir 40 ventanas de chat antiguas para recordar por qué.

*El complemento de Godot se convierte efectivamente en el documentador e ingeniero de software de tu estudio.*
