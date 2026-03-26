---
layout: home

hero:
  name: "Gamedev AI"
  text: "El Ingeniero de Software Autónomo para Godot 4.6"
  tagline: "Escribe código GDScript, manipula nodos, corrige errores del console de la engine automáticamente y aplica cambios complejos revisando los Diffs en tiempo real. Todo integrado en el editor al alcance de tus dedos."
  actions:
    - theme: brand
      text: Comenzar ahora
      link: /es/getting-started/installation
    - theme: alt
      text: Ver en GitHub
      link: https://github.com/fredarts/gamedev_ai

features:
  - title: Construcción vía Chat
    tag: CORE
    details: "Describe la mecánica, adjunta archivos y arrastra Nodes directamente desde el Scene Tree al panel de chat para que la IA estructure el sistema por ti."
  - title: "Diff Seguro y Visual"
    tag: SAFE
    details: "La IA no rompe tu código a ciegas. El complemento muestra una ventana lado a lado (Antes/Después) para que apliques solo las líneas que apruebes."
  - title: Modo Vigilancia (Auto-Corrección)
    tag: ENGINE
    details: "¡Deja que la IA vigile la ventana de Output! Si tu juego falla al presionar Play, propone inmediatamente una corrección para el script que causó la falla."
  - title: Indexación Vectorial (RAG)
    tag: ENGINE
    details: "Index Codebase escanea tus scripts en una base de datos vectorial local. La IA encuentra tus clases automáticamente al programar."
  - title: 25 Habilidades Integradas
    tag: SMART
    details: "El asistente está entrenado con 25 áreas de especialización (Shaders, Multijugador, UI/UX, Inventarios) implementando los mejores estándares del mercado."
  - title: Git sin Complicaciones
    tag: CORE
    details: "Pestaña nativa para gestionar GitHub. Crea líneas de tiempo alternativas (Branches), rescata proyectos y deja que la IA lea tus scripts para generar mensajes de Commit claros automáticamente."
  - title: Personas Especialistas
    tag: SMART
    details: "Enrutamiento inteligente de contexto (UI, Shaders, Multijugador) que carga solo el conocimiento necesario para tu problema actual."
  - title: "Puerta Socrática (Stop & Ask)"
    tag: SAFE
    details: "La IA se detiene y hace preguntas estratégicas antes de generar sistemas complejos, evitando alucinaciones y código roto desde el principio."
  - title: Workflows vía Slash (/)
    tag: CORE
    details: "Usa comandos como `/brainstorm`, `/plan` y `/debug` para cambiar instantáneamente la postura y la metodología del asistente."

modern_header:
  title: "¿Por qué Gamedev AI é diferente?"
  description: "No somos solo un chat. Somos un motor de inteligencia integrado directamente en el flujo de trabajo de Godot, enfocado en la seguridad, el contexto real y la autonomía controlada por el desarrollador."

feature_showcase:
  - title: "Autonomía Real"
    tag: "Workflow"
    description: "La IA no solo sugiere, actúa. Del borrador a la implementación final con un solo clic."
    steps: ["Analizando contexto...", "Accediendo a Vector DB...", "Validando arquitectura...", "Generando Diff Seguro"]
  - title: "Motor de Conocimiento"
    tag: "RAG / Vector DB"
    description: "Tus scripts se indexan localmente, lo que permite a la IA comprender tus clases y funciones personalizadas sin alucinar."
  - title: "Seguridad y Revisor"
    tag: "Socratic Gate"
    description: "El asistente se detiene y hace preguntas estratégicas antes de cambiar sistemas críticos, evitando código roto."
    question: "Espera, noté que estás usando un singleton. ¿Deberíamos implementar esto como un recurso compartido para optimizar la memoria?"
    opt1: "Sí, buena idea."
    opt2: "No, mantener singleton."
---
