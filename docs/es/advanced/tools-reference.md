# Todas las Herramientas de la IA (Tool Reference)

Gamedev AI cuenta con **27 herramientas integradas** que la IA puede invocar de forma autónoma durante una conversación. Estas herramientas son el "brazo mecánico" que permite a la IA interactuar directamente con el motor Godot, y cada una se describe a continuación agrupada por categoría.

## 🔧 Scripts (Creación y Edición de Código)

### `create_script`
Crea un nuevo archivo GDScript (`.gd`) en la ruta especificada con el contenido proporcionado. La IA utiliza esta herramienta para generar scripts desde cero.
- **Parámetros:** `path` (res://...), `content` (código GDScript completo)

### `edit_script`
Reemplaza el contenido completo de un script existente por una nueva versión. La IA leerá el archivo primero para asegurarse de tener la última versión.
- **Parámetros:** `path`, `content`
- ⚠️ *Obsoleto en favor de `patch_script` para ediciones quirúrgicas.*

### `patch_script`
Edición quirúrgica: busca un bloque de código exacto dentro del script y reemplaza solo ese fragmento con el nuevo contenido. Ideal para pequeñas correcciones sin reescribir todo el archivo.
- **Parámetros:** `path`, `search_content` (bloque exacto a buscar), `replace_content` (bloque nuevo)

### `replace_selection`
Reemplaza el texto seleccionado actualmente en el Editor de Scripts de Godot. Funciona junto con los botones de acción rápida (Refactorizar, Corregir, Explicar).
- **Parámetros:** `text` (nuevo código para reemplazar la selección)

### `view_file_outline`
Devuelve la estructura de un script sin el código completo: `class_name`, `extends`, funciones, señales, exports, enums, clases internas y constantes con números de línea.
- **Parámetros:** `path`

---

## 🌳 Nodos (Manipulación del Árbol de Escenas)

### `add_node`
Añade un nuevo nodo a la escena abierta en el editor. Puede crear cualquier tipo de nodo de Godot (Node2D, CharacterBody3D, Label, Button, etc.).
- **Parámetros:** `parent_path` (usa `.` para la raíz), `type` (clase del nodo), `name`, `script_path` (opcional)

### `remove_node`
Elimina un nodo del Árbol de Escenas actual. Requiere confirmación del usuario por ser una acción destructiva.
- **Parámetros:** `node_path`

### `set_property`
Establece una propiedad en un nodo de la escena (posición, tamaño, texto, color, etc.). Acepta números, vectores, colores y cadenas de texto.
- **Parámetros:** `node_path`, `property`, `value`

### `set_theme_override`
Establece una invalidación de tema (theme override) en un nodo de Control (tamaño de fuente, color de fuente, estilo).
- **Parámetros:** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
Conecta la señal de un nodo emisor al método de un nodo receptor en la escena actual.
- **Parámetros:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (opcional), `flags` (opcional)

### `disconnect_signal`
Desconecta una señal previamente conectada entre dos nodos.
- **Parámetros:** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
Adjunta un GDScript existente a un nodo de la escena.
- **Parámetros:** `node_path`, `script_path`

### `analyze_node_children`
Devuelve un volcado detallado del subárbol de un nodo específico en la escena editada. Útil para explorar jerarquías profundas.
- **Parámetros:** `node_path`, `max_depth` (predeterminado: 5)

---

## 📂 Archivos y Proyecto

### `read_file`
Lee el contenido completo de cualquier archivo del proyecto.
- **Parámetros:** `path`

### `list_dir`
Enumera el contenido de un directorio del proyecto.
- **Parámetros:** `path`

### `find_file`
Busca un archivo del proyecto por su nombre (coincidencia parcial).
- **Parámetros:** `pattern`

### `remove_file`
Elimina un archivo o directorio del proyecto. Requiere confirmación.
- **Parámetros:** `path`

### `move_files_batch`
Mueve o renombra varios archivos/directorios en una sola operación por lotes. Actualiza automáticamente todas las referencias internas de Godot (`.tscn`, `.tres`).
- **Parámetros:** `moves` (diccionario que asigna rutas antiguas a nuevas)

### `create_scene`
Crea un nuevo archivo de escena (`.tscn`) y lo abre en el editor.
- **Parámetros:** `path`, `root_type`, `root_name`

### `instance_scene`
Instancia una escena `.tscn` existente como hija de otro nodo en la escena actual.
- **Parámetros:** `parent_path`, `scene_path`, `name`

### `create_resource`
Crea un nuevo archivo de Recurso (`.tres`). Útil para activos como Objetos, Estadísticas o configuraciones personalizadas.
- **Parámetros:** `path`, `type`, `properties` (opcional)

---

## 🔍 Búsqueda y Análisis

### `grep_search`
Busca texto dentro de los archivos del proyecto. Devuelve las líneas que coinciden con la ruta y el número de línea.
- **Parámetros:** `query`, `include` (filtro de extensión, opcional), `max_results` (predeterminado: 20)

### `search_in_files`
Busca patrones regex en todos los archivos `.gd` del proyecto para encontrar usos de variables, funciones o lógicas específicas.
- **Parámetros:** `pattern` (expresión regular)

### `get_class_info`
Devuelve información detallada sobre una clase de Godot (de la Engine o personalizada): clase base, propiedades, métodos y señales.
- **Parámetros:** `class_name`

### `capture_editor_screenshot`
Toma una captura de pantalla de toda la ventana del Editor de Godot y la adjunta automáticamente al siguiente prompt para análisis visual.

---

## 🧠 Memoria y Conocimiento

### `save_memory`
Guarda un dato persistente en la memoria del proyecto que estará disponible en todas las sesiones de chat futuras.
- **Parámetros:** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
Enumera todos los datos persistentes almacenados para este proyecto.

### `delete_memory`
Elimina un dato de memoria específico por su ID.
- **Parámetros:** `id`

### `read_skill`
Lee un archivo de documentación de Skill de la biblioteca interna de la IA para aprender las mejores prácticas antes de programar.
- **Parámetros:** `skill_name`

---

## 🗄️ Base de Datos Vectorial (RAG)

### `index_codebase`
Indexa todo el proyecto (`.gd`) en una base de datos vectorial local para búsqueda semántica. Debe ejecutarse antes de usar `semantic_search`.

### `semantic_search`
Realiza una búsqueda vectorial semántica en el código indexado para encontrar fragmentos de código muy relevantes basados en el significado, no en la coincidencia exacta de texto.
- **Parámetros:** `query`

---

## 🧪 Pruebas

### `run_tests`
Ejecuta un script o comando de prueba. Útil para comprobar cambios con GUT, GdUnit4 o scripts de prueba personalizados.
- **Parámetros:** `test_script_path` (opcional)
