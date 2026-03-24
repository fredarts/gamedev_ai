# Instalación

¡Bienvenido a la documentación oficial de **Gamedev AI**! Esta página se centra en cómo añadir rápidamente el asistente a tu proyecto actual de Godot 4.6.

## Requisitos
* **Godot Engine:** Versión 4.6 o superior (no se requiere soporte nativo de `.gdextension`, el complemento ejecuta GDScript puro).
* Cuenta de Google o OpenRouter para las claves API.

## Paso a Paso Manual (GitHub)

1. Crea o abre un proyecto existente en Godot 4.6.
2. Navega a la carpeta raíz de tu proyecto (donde se encuentra el archivo `project.godot`).
3. Crea una carpeta `addons` (si aún no existe).
4. Dentro de `addons/`, descarga o clona el repositorio del complemento:
```bash
git clone git@github.com:fredarts/gamedev_ai.git
```
*(O descarga el archivo `.zip` de la pestaña Releases en GitHub y extráelo dentro de `res://addons/gamedev_ai`).*

## Activación en el Editor

Con los archivos en su lugar:
1. Abre el editor de tu proyecto Godot.
2. Ve al menú `Proyecto` en la parte superior y elige `Configuración del Proyecto`.
3. Navega a la pestaña `Complementos` en la parte superior.
4. Busca **Gamedev AI** en la lista de complementos instalados.
5. Marca la casilla `Activar`.

¡Eso es todo! Al activarlo por primera vez, verás aparecer el panel de Chat de Gamedev AI en el *Dock* derecho de tu editor.

[**Siguiente paso: Configura tu clave API** ➔](./configuration.md)
