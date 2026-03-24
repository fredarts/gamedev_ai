# Index Codebase (La Mente Analítica)

Uno de los puntos más valiosos de Gamedev AI, que lo diferencia drásticamente de ChatGPT convencional u otros co-pilotos de VSCode, es su profundo conocimiento de la red conectiva de tu proyecto de juego.

Si el "Contexto Abierto" es el ojo actual de la IA, el **Index Codebase** (Indexar Código) es la red neuronal latente del robot.

## ¿Qué es la Indexación Vectorial (Vector DB)?

Al trabajar con frameworks inmensos como Godot, muchas clases personalizadas como `PlayerStats`, `InventoryManager` o `WeaponBuilder` no pertenecen al manual clásico de GDScript que la IA estudió hace años en OpenAI. Son clases que **tú** has creado.

Ir allí y pegar el script `PlayerStats` cada vez en el chat para preguntar sobre el inventario devora miles de tokens repetitivos y tu tiempo. Con la Indexación DB (Búsqueda Vectorial), esto se acaba.

### Operar la Indexación (Botón Settings)
1. Ve al panel de Gamedev AI y haz clic en la pestaña de engranaje oculta para las opciones de Contexto ("⚙️ Settings" en la esquina inferior).
2. Desliza el panel de opciones hacia abajo para revelar la ventana **Vector Database**.
3. Haz clic en **🔍 Scan Changes**. El complemento barrerá todos tus nombres de archivo en el disco, buscando eliminaciones o ediciones no reportadas.
4. La *Lista de Archivos* visual se llenará de colores señalando las adiciones cruciales y los archivos antiguos sin cambios. Si hay discrepancias con la última indexación final:
5. Finalmente, haz clic en **⚡ Index Database**.

Esto activará el modo de indexador invisible con la API de text-embedding de Gemini. Al final del reloj de arena de progreso, se ocultará y cifrará en disco una red RAG JSON semántica llamada `.gamedev_ai/vector_db.json`.

Ahora, prueba en el chat:
* *"¿Cómo soluciono el bug del inventario?"*

La IA responderá: *"Oh, he notado por tus scripts en `res://src/player_inventory.gd` y la llamada en `Network.gd` que las clases no están conectadas de forma persistente. Voy a ajustar eso".*

[**Siguiente paso: Entiende los 25 archivos de "Skills" que ayudan al RAG** ➔](./skills.md)
