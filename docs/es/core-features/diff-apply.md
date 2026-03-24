# La Pantalla de Diff (Luz Verde para Programadores)

Gamedev AI escribe código de forma asíncrona. Esto significa que reescribe tu archivo y edita docenas de instancias mientras lees el registro en la engine.
Pero espera, ¿dar el control de escritura automático a un bot en tu disco duro no destruye las raíces autorales del desarrollador?

¡No! *La Pantalla de Diff protege tu trabajo y tu proyecto sin arañazos accidentales.*

El complemento Gamedev AI implementa la "Safe View Diff Window" (Ventana de Vista Segura de Diff), comparable a las famosas vistas de versiones (GitHub/GitLens) en VSCode.

## Cómo ocurre el Diff
1. Al pedir crear o corregir un `EnemyAttack.gd`, el registro indica el progreso en la reescritura de los metadatos de la clase...
2. Escucharás un "Ping" visual y una **pestaña oscura de Diff** con las palabras [Original Code] junto a [New Code Changes] emergerá instantáneamente invadiendo la pantalla de chat con texto.
3. Las líneas resaltadas **[color=red]en Rojo -[/color]** representan el código original peligrosamente eliminado.
4. Las líneas resaltadas **[color=green]en Verde +[/color]** representan la inyección sin precedentes de inteligencia artificial.

## Aplicar o Ignorar (El Poder del Rechazo)

Al final del Diff (desliza la barra de desplazamiento hasta el final o analízalo fríamente), aparecen los botones de seguridad decisivos:
* **"Apply Changes":** Gamedev AI utilizará el Proxy oficial de Historial de Deshacer/Rehacer (Undo/Redo) de Godot Engine y modificará el script de destino real. Si pulsas `Ctrl + Z` en el script, volverás al estado anterior a que la IA tomara el control.
* **"Skip" (Ignorar):** ¿Detestaste la idea rígida del LLM tras el Diff? Pulsa "Skip". Ninguna línea se alterará (ni siquiera en Cache) y no hay daños técnicos, solo se quemaron los *tokens*.

> _(Visualiza en la práctica cómo funciona el Diff:)_

![Ventana de Diff que muestra código eliminado en rojo y añadido en verde, con botones para aplicar e ignorar](../../images/diff_preview.png)
