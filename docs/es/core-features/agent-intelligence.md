# 🧠 Agentes e Inteligencia

Gamedev AI no es solo un chat que escribe código. Está impulsado por una arquitectura de agentes de última generación, basada en las mejores prácticas de desarrollo autónomo, lo que permite al asistente actuar de manera metódica, proactiva y consciente del contexto.

---

## 🎭 Personas Especialistas (Dynamic Routing)

La IA identifica automáticamente su objetivo basándose en su conversación y asume una "Persona" específica. Esto garantiza que el prompt se centre solo en lo que importa, ahorrando tokens y aumentando la precisión.

- **Godot Expert**: El asistente general para lógica del juego y estructura.
- **UI/UX Designer**: Enfocado en nodos de `Control`, anclajes y layouts responsivos.
- **Technical Artist**: Especialista en Shaders, partículas y efectos visuales.
- **Multiplayer Engineer**: Enfocado en redes, RPCs y sincronización.

> [!TIP]
> Puedes forzar una persona mencionando palabras clave como "necesito un menú (UI)" o "estoy haciendo un shader".

---

## ⛩️ Puerta Socrática (Stop & Ask)

Para evitar generar códigos masivos y genéricos que pueden no servir para su proyecto, la IA implementa la **Puerta Socrática**.

Siempre que pida algo complejo (ej: "Crea un sistema de inventario"), la IA:
1. **Detendrá** la generación de código.
2. **Hará** al menos 2 preguntas sobre *trade-offs* o casos de borde (ej: "¿Se basará en espacios (slots) o peso?", "¿Necesita persistencia en la base de datos?").
3. **Ejecutará** solo después de su aclaración.

---

## ⌨️ Workflows vía Slash Commands

Puedes usar comandos directos para cambiar el comportamiento de la IA instantáneamente:

- `/brainstorm`: La IA entra en modo de descubrimiento. No escribirá código, solo ayudará a planificar la arquitectura, el GDD y la lógica.
- `/plan`: Enfocado en estructurar carpetas y escenas antes de codificar.
- `/debug`: Modo de investigación profunda. Se centra solo en logs de errores y la causa raíz.

---

## 🔍 Auto-Audit (Refinamiento Autónomo)

Después de realizar cambios complejos, la IA tiene la autonomía para ejecutar herramientas de auditoría (`audit_script`, `audit_scene`) para verificar errores de sintaxis o referencias huérfanas antes de considerar la tarea completada. Esto garantiza un ciclo de retroalimentación mucho más corto y un código más estable.
