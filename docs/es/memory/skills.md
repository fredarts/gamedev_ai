# Las 25 Habilidades Integradas (Catálogo Completo)

Gamedev AI no es una IA genérica que confía puramente en la memoria entrenada en internet. Cuenta con **25 módulos de experticia** escritos específicamente para Godot 4.6, que se consultan automáticamente durante las conversaciones para asegurar que el código generado siga las mejores prácticas de la industria.

A continuación, se detalla cada una de las 25 Skills con su propósito y ejemplos de cuándo la IA las utiliza.

---

## 📜 GDScript y Lenguaje

### 1. `gdscript_style_guide`
**Guía de Estilo de GDScript.** Convenciones de nomenclatura (snake_case, PascalCase), organización de archivos, tipado estático, orden de declaración y mejores prácticas de formateo siguiendo el estándar oficial de Godot.

### 2. `gdscript_modern_features`
**Funciones Modernas de GDScript.** Lambdas, tipado estático expandido, `await`, `super()`, enums con tipo, patrones `match` avanzados y todas las nuevas funciones de GDScript 2.0+ que reemplazaron la sintaxis heredada.

### 3. `gdscript_deprecated`
**Funciones de GDScript Obsoletas.** Lista completa de funciones, métodos y patrones eliminados o reemplazados entre Godot 3 y Godot 4. La IA consulta esta habilidad para no sugerir nunca código obsoleto.

### 4. `gdscript_recipes_and_patterns`
**Recetas y Patrones de GDScript.** Soluciones preparadas para problemas comunes: patrón singleton, object pooling, inyección de dependencias, patrón observador e implementaciones idiomáticas en GDScript.

### 5. `gdscript_signals_and_tweens`
**Señales y Tweens.** Guía detallada sobre el sistema de señales de Godot 4, `SceneTreeTween`, creación de animaciones procedimentales, encadenamiento de tweens y mejores prácticas de desacoplamiento con señales.

---

## 🏗️ Arquitectura y Estructura

### 6. `common_architectures`
**Arquitecturas Comunes de Juegos.** Patrones arquitectónicos como Entidad-Componente, MVC para juegos, Localizador de Servicios, Bus de Eventos y cómo estructurar proyectos de Godot a media/gran escala.

### 7. `project_structure_guidelines`
**Pautas de Estructura de Proyecto.** Organización ideal de carpetas (`src/`, `assets/`, `ui/`, `autoloads/`), convenciones de nomenclatura de archivos, autoloads frente a inyección de dependencias y cuándo usar cada enfoque.

### 8. `state_machine_implementation`
**Implementación de Máquinas de Estado.** Patrón de máquina de estados con nodos hijos, transiciones limpias, estados jerárquicos e integración con AnimationTree para personajes complejos.

---

## 🎮 Sistemas de Juego

### 9. `inventory_and_item_systems`
**Sistemas de Inventario y Objetos.** Arquitectura de inventario basada en Recursos, ranuras (slots), apilamiento, arrastrar y soltar objetos, serialización para partidas guardadas e interfaz de inventario responsiva.

### 10. `quest_and_dialogue_systems`
**Sistemas de Misiones y Diálogos.** Implementación de árboles de diálogo, sistema de misiones con estados (activa/completada/fallida), NPCs, condiciones de progreso e integración con la interfaz.

### 11. `save_system_and_persistence`
**Sistema de Guardado y Persistencia.** Serialización completa del estado del juego en JSON/binario, guardado automático, múltiples ranuras, versiones de guardado y migración entre versiones.

### 12. `data_management_and_crafting`
**Gestión de Datos y Crafting.** Sistemas de artesanía con recetas basadas en Recursos, bases de datos de objetos, tablas de botín (loot tables) y equilibrio de la economía del juego.

---

## 🕹️ Mecánica y Física

### 13. `physics_and_collision_handling`
**Física y Colisiones.** Configuración de capas/máscaras (layer/mask), CharacterBody2D/3D, RigidBody, raycasting, áreas de detección y resolución de problemas comunes de física.

### 14. `input_handling_and_remapping`
**Gestión de Entrada y Remapeo.** InputMap, acciones personalizadas, soporte para gamepad/teclado/táctil, remapeo en tiempo de ejecución, buffering de entrada y zonas muertas.

### 15. `ai_and_pathfinding`
**IA y Búsqueda de Caminos.** NavigationServer2D/3D, NavigationAgent, evitación, árboles de comportamiento simplificados, persecución, patrulla e IA de enemigos basada en estados.

---

## 🎨 Visuales y Audio

### 16. `shaders_and_vfx`
**Shaders y VFX.** Shaders de Godot Shading Language, efectos de disolución, contorno (outline), distorsión, partículas GPU, estelas (trails) y técnicas de VFX para juegos 2D y 3D.

### 17. `post_processing_and_environment`
**Post-procesamiento y Entorno.** WorldEnvironment, resplandor (glow), niebla, SSAO, SSR, tonemap, corrección de color y configuración de entorno cinematográfico.

### 18. `animation_and_cutscenes`
**Animación y Cinemáticas.** AnimationPlayer, AnimationTree, blend spaces, máquinas de estado de animación, cinemáticas con AnimationPlayer y transiciones suaves.

### 19. `audio_management_best_practices`
**Gestión de Audio.** AudioBus, AudioStreamPlayer2D/3D, pooling de efectos de sonido, música adaptativa, crossfade, mezcla y organización del sistema de audio.

---

## 🖥️ Interfaz y Plataforma

### 20. `ui_ux_patterns`
**Patrones de UI/UX.** Menús responsivos, HUD, temas globales, navegación por foco con gamepad, transiciones de pantalla, ventanas emergentes (pop-ups) y mejores prácticas de UI en Godot.

### 21. `mobile_and_resolution_scaling`
**Móviles y Escala de Resolución.** Configuración de stretch mode, relación de aspecto, entrada táctil, joystick virtual, optimizaciones para móviles y pruebas multirresolución.

### 22. `localization_and_i18n`
**Localización e i18n.** Sistema de traducción con `.csv`/`.po`, TranslationServer, cambio de idioma en tiempo de ejecución, formateo de números/fechas y soporte para RTL.

---

## 🌐 Multijugador y Rendimiento

### 23. `multiplayer_and_networking_api`
**Multijugador y Redes.** ENet, WebSocket, MultiplayerSpawner/Synchronizer, RPCs, autoridad, arquitectura cliente-servidor, sistemas de lobby y sincronización de estado.

### 24. `performance_optimization`
**Optimización del Rendimiento.** Perfilado (profiling), pooling de objetos, LOD, culling, renderizado por lotes (batch rendering), optimización de GDScript, reducción de draw calls y técnicas para juegos a 60fps.

### 25. `level_generation_and_pcg`
**Generación de Niveles y PCG.** Generación procedimental de mazmorras, wave function collapse, terreno basado en ruido, TileMap automático y semillas aleatorias reproducibles.

---

## 🛠️ Creación de tus propias Skills

¡El sistema de Skills es **extensible**! Puedes crear tus propios archivos `.md` en la carpeta `addons/gamedev_ai/skills/` para enseñar a la IA las reglas específicas de tu proyecto.

**Ejemplo:** Crea un archivo llamado `mi_estilo_artistico.md` con:
```markdown
# Reglas de Arte de Nuestro Estudio

- Todos los sprites deben tener una resolución de 16x16 o 32x32.
- Usar una paleta de colores limitada (máx. 32 colores).
- Las animaciones de personajes deben tener al menos 4 fotogramas.
- Nombrar los sprites como: tipo_nombre_accion_frame.png
```

La IA seguirá estas reglas siempre que cree o modifique activos visuales en tu proyecto.
