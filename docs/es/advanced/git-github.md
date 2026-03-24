# Pestaña de Git y GitHub (Automatización de Versiones)

Crear juegos en Godot suele generar pánico en los principiantes cuando se trata de hacer *Commit* de docenas de archivos binarios oscuros (Escenas, Materiales, Recursos). Hacer un *Merge* en la terminal es agotador.

Por eso, **Gamedev AI** implementa una pestaña nativa de **Git** dentro de Godot, diseñada exclusivamente para la fluidez.

## Cómo usar la pestaña de versionado

En la ventana derecha del complemento, cambia de la clásica pestaña de `Chat` o `Settings` a la pestaña superior de **Git**.
Allí verás una versión visual simplificada y moderna de la terminal:

![Interfaz de la pestaña de Git con botones de commit, ramas y operaciones de emergencia](../../images/git_tab.png)

### 1. Inicializar y Conectar
Si la carpeta no tiene versiones, aparecerá un botón verde gigante de "Initialize Repository". Luego, el panel te pedirá que pegues la **URL de GitHub** del repositorio en la nube que creaste en el sitio web de GitHub.

### 2. Generar mensaje de commit ✨ (El Tesoro)
1. Acabas de programar, has cambiado 4 escenas complejas y has rehecho scripts (`.gd`).
2. En lugar de pensar en un texto aburrido para el Commit, haz clic en **"✨ Auto-Generate Commit Message"**.
3. Gamedev AI realizará un Diff invisible. La inteligencia artificial mirará absolutamente todos los códigos eliminados en rojo y añadidos en verde que has tocado (ej. *añadida lógica de rodar al Jugador y corregido el arrastre de la IU*) y creará un resumen escrito muy pulido en el cuadro para ti.
4. Simplemente haz clic en **Commit & Sync (Push)**. ¡La IA sube todo a la nube al instante!

### 3. Ramas Aisladas (Timelines)
¿Tienes miedo de romper tu escena `Level_1.tscn`, que hoy está perfecta, mientras intentas probar un nuevo jefe (boss)?
Usa la pestaña lateral de **Current Branch** (Rama Actual) y haz clic en [Create/Switch]. Escribe `test_boss` y confirma. A partir de ese momento, estarás a salvo en una "copia aislada" del código.

### 4. Modo Pánico (Deshacer Errores)
El panel inferior contiene las Super Acciones:
* **Undo Uncommitted Changes:** ¿Ha explotado Godot? Pulsa este botón y todo volverá al estado de tu última versión guardada en GitHub al instante. Un "Ctrl+Z" universal de todo el proyecto.
* **Force Pull Overwrite:** Aplasta toda tu carpeta local, descargando y reemplazándola exactamente con el estado que está blindado en tu nube. Un salvavidas perfecto para programadores.
* **Force Push:** Aplasta la versión de la nube con la versión local. ¡Úsalo con cuidado!
