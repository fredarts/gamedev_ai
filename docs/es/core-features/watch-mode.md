# Modo Vigilancia (La Magia de la Auto-Depuración)

Como gamedev, pasas un **30% de tu tiempo desarrollando lógicas de juego fantásticas** y un doloroso **70% descifrando Errores Rojos semánticos y Excepciones de Referencia Nula** en la pestaña `Debugger / Output` de Godot.

La función **Modo Vigilancia** (Watch Mode) de Gamedev AI elimina esta aterradora segunda fase de depuración manual. Convierte al bot en un ingeniero de QA invisible que trabaja en la habitación de al lado.

## ¿Por qué activarlo? ¿Y cómo activarlo?
En la parte inferior de tu panel de Chat, activa el interruptor llamado **[x] Watch Mode**.

Lo que ocurre entre bastidores:
1. Pulsas `F5` (Ejecutar Escena / Depurar Proyecto) en Godot.
2. Tu jugador choca con un `Area2D` donde olvidaste la inicialización clara de un `NodeGroup`. La engine falla y lanza un texto rojo letal en la Salida (Output): "Attempt to call function 'die' in base 'null instance'".
3. Sin que tengas que hacer clic ni copiar texto, Gamedev AI *se despierta*, lee el registro de errores de sintaxis en los últimos 50 bloques de la consola, reúne los archivos sospechosos indexados, redacta la hipótesis del fallo de referencia y devuelve instantáneamente una **solución de reescritura en Diff**, o explica paso a paso dónde está el Nodo con problemas.

## Límites de "Tolerancia" y Enfriamiento (Cooldown)

Los asistentes demasiado activos queman las cuentas de los Modelos de Pago enviando "Orphan Warnings" repetitivos de Godot Engine (insignificantes advertencias amarillas que no han llegado a romper nada).

Para gestionar tu billetera y el flujo de información, Gamedev AI limita la vigilancia con **Enfriamientos dinámicos**:
* Se dispara como máximo en las primeras **tres** ondas críticas generadas en la Salida informadas por el Log dentro de unas breves fracciones de 30 segundos, o a veces, espera un tiempo prolongado en `standby`.

*Cuidar de la engine se ha convertido casi en un juego de niños al leer consejos autónomos.*
