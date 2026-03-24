# Custom System Prompt

Manchmal haben Studio-Projekte strikte Vorgaben, und wir möchten nicht, dass die KI generische Entscheidungen für den gesamten erstellten Code trifft. Wie formen Sie das standardmäßige "mentale" Verhalten von Gamedev AI?

## Das "Custom Instructions" Panel

Im versteckten **Settings**-Tab, unter dem Feld für den "API Key"-Anbieter.
Dort befindet sich das große Freitextfeld **Custom Instructions (appended to system prompt)**.

![Settings-Panel zeigt den Bereich für Custom Instructions](../../images/settings_ui.png)

Wann immer die KI "nachdenkt", werden die dort hinterlegten Anweisungen als universelle Regel Nummer 1 gelesen, bevor sie Ihnen antwortet.

### Beispiele für Inhalte in diesem Feld:
* *"Bitte schreibe keine langen Erklärungen oder Begrüßungen, zeige nur das fokussierte Diff-Fenster"*
* *"Das gesamte Godot-Projekt dieses Studios nutzt Clean Code Konventionen. Methoden müssen mit kleinen englischen Buchstaben beginnen und Scene Nodes in PascalCase. Nutze strikt statische Typisierung (: String, : int, -> void) in allen erstellten Funktionen."*
* *"Ich verbiete die Nutzung von _process()-Tags. Ich möchte, dass du dich auf eine Architektur mit intensivem Einsatz von Signalen für die Performance konzentrierst."*

Damit wird Gamedev AI zu einem Entwickler, der speziell vom CTO (Ihnen) geformt wurde und Code so erstellt, wie Ihr Team es gutheißt, statt der herkömmlichen freien Syntax von LLMs zu folgen.
