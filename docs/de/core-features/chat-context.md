# Chat, Anhänge und Kontext (Das Herzstück des Plugins)

Der Chat ist mehr als nur ein in das rechte Fenster Ihres Editors integrierter ChatGPT. Er ist das eigentliche "Atmungssystem" zwischen Ihren **Projektdateien** und dem **Verstand der KI**.

## Die Bedeutung von "Context" (Ihren aktuellen Code lesen)

Die künstliche Intelligenz kann Ihren Bildschirm nicht sehen und weiß nicht, was Sie gerade programmieren — *es sei denn, Sie fordern sie dazu auf!*

Unter der Zeile *"Senden"* sehen Sie eine wichtige Checkbox namens **Context**.
1. **Aktiviert (Standard):** Gamedev AI kopiert heimlich jede Zeile und jedes Zeichen der Datei (`.gd`), in der sich der Cursor in Ihrem Script-Fenster in diesem Moment befindet. Diese Informationen werden zusammen mit Ihrer Frage gesendet!
2. **Deaktiviert:** Spart Ihre begrenzten Kontext-Token bei kostenpflichtigen Modellen (OpenAI). Hierbei wird eine schnelle Frage gestellt, ohne Ihren Code zu sehen, ähnlich wie bei einem generischen ChatGPT. Nutzen Sie dies bei isolierten Problemen, die keinen Engine-Kontext erfordern.

## 📸 Screenshot (Auto-Snapshot)

Neben dem Context-Schalter befindet sich der **Screenshot**-Schalter. Diese Funktion erlaubt es der KI, buchstäblich zu "sehen", was auf Ihrem Godot-Bildschirm passiert.

### Wie es funktioniert
1. **Aktivieren Sie den "Screenshot"-Schalter** in der unteren Leiste des Chats.
2. Die nächste Nachricht, die Sie senden, wird von einem **automatischen Screenshot** des gesamten Godot-Editor-Fensters begleitet.
3. Die KI erhält das vollständige Bild und kann visuell analysieren: die geöffnete 2D/3D-Szene, den Scene Tree, den Inspektor, den Output und jedes andere sichtbare Panel.

### Wann man es nutzt
- **Defektes UI:** Ihr Spiel-Interface ist falsch ausgerichtet, aber Sie wissen nicht, welches Label oder welcher Container schuld ist? Aktivieren Sie den Screenshot, senden Sie "Was stimmt mit diesem Layout nicht?" und die KI wird die Nodes visuell analysieren.
- **Komplexer Scene Tree:** Sie möchten, dass die KI versteht, wie die Node-Hierarchie organisiert ist, ohne sie manuell beschreiben zu müssen.

::: tip Tipp
Die KI verfügt auch über das Tool `capture_editor_screenshot`, das sie jederzeit während eines Gesprächs selbst aufrufen kann, wenn sie einen eigenen "Blick" auf den Editor werfen muss.
:::

## Plan First Button (Zuerst planen)

Es ist ein häufiger Fehler, die KI sofort anzuweisen, die gesamte Logik eines gewaltigen RPGs zu erstellen. Das Plugin ermöglicht es Ihnen, den robotischen Impuls zu bremsen, indem Sie **Plan First** aktivieren.

![Aktivierter Plan First Schalter mit sichtbarem Execute Plan Button](../../images/plan_first.png)

* **Aktiviert:** Das Plugin sendet eine strikte Anweisung. *Die KI wird keinen Code erstellen*. Sie wird ausschließlich mit einer nummerierten Markdown-Liste antworten, die die zu ändernden Projektelemente (Klassen, Namen und Basisfunktionen) aufzählt.
* Nachdem Sie den Plan geprüft und bestätigt haben, klicken Sie auf den Button **"Execute Plan"**, der automatisch erscheint. Erst dann beginnt die KI mit der Implementierung dessen, was sie geplant hat.

## Anhänge und ziehbare Nodes

Müssen Sie analysieren, wie ein Sprite2D aufgebaut ist oder warum die Szene `Player.tscn` nicht mit dem RigidBody3D `Ground` kollidiert?

Das Gamedev AI Plugin unterstützt Drag & Drop. Sie müssen keine Zeit damit verschwenden, jeden Tab im Inspektor zu öffnen, der Neugier oder einen visuellen Fehler geweckt hat...

![Per Drag & Drop angehängte Dateien im Chat-Feld](../../images/drag_and_drop.png)

1. **Scene Tree:** Klicken Sie auf einen Node in der Szene und ziehen Sie ihn in die Textzeile. Die KI nutzt den Shortcut, um alle Metadaten des Nodes zu analysieren (versteckte Positionen, Instuziierungen, Collision-Tags...) und zu verstehen, warum die Reibungsvektoren scheinbar nicht funktionieren.
2. **📎 Anhängen-Button:** Nutzen Sie diesen, um Bilder einzufügen (`.png` von fehlerhaften Interfaces), rohe Speicherdateien (`.json`) und globale Snapshots langer Scripts (obwohl die vektorielle Indexierung die professionellere Methode ist).

---

## 🎙️ Vorlesefunktion (TTS - Text-to-Speech)

Gamedev AI verfügt über einen integrierten **Sprachausgabe-Player**, der die Antworten der KI in Audio umwandelt. So können Sie sich Erklärungen anhören, während Sie weiter programmieren, ohne für lange Textwände unterbrechen zu müssen.

![Kompakter TTS-Player mit Play-Button und Geschwindigkeitskontrolle](../../images/tts_player.png)

### Wie man es nutzt
1. Sobald die KI im Chat auf eine Frage geantwortet hat, klicken Sie auf den Button **"▶ Vorlesen"** (direkt unter dem Chat-Bereich).
2. Das Plugin sendet eine Anfrage, um den Text der letzten Antwort in Audio umzuwandeln.
3. Ein kompakter Audio-Player erscheint mit allen Bedienelementen:

| Steuerung | Funktion |
|----------|--------|
| **▶ Vorlesen** | Startet die Wiedergabe der Erzählung. |
| **⏹ (Stop)** | Stoppt die Wiedergabe sofort. |
| **Fortschrittsbalken** | Ermöglicht es Ihnen, durch Ziehen des Reglers in der Erzählung vor- oder zurückzuspringen. |
| **Geschwindigkeit (1.0x bis 2.0x)** | Steuert das Tempo der Erzählung. Nutzen Sie 1.5x oder 2.0x für schnelleres Zuhören. |

### Wann es nützlich ist
- **Lange Antworten:** Hat die KI 3 Absätze darüber erklärt, wie `NavigationAgent3D` funktioniert? Hören Sie zu, während Sie die Nodes im Scene Tree anpassen.
- **Barrierefreiheit:** Für Entwickler, die lieber hörend lernen oder Schwierigkeiten mit längerem Lesen am Bildschirm haben.
- **Passives Review:** Lassen Sie die KI den Refactoring-Plan vorlesen, während Sie sich einen Kaffee holen!

::: info Hinweis
Die TTS-Funktion nutzt die API des konfigurierten Anbieters zur Audiosynthese. Der Stream wird zwischengespeichert, sodass Pausieren und Fortsetzen keine neuen Token-Kosten verursacht.
:::

---

## ⚡ Schnellaktions-Buttons

In der Leiste direkt unter dem Chat-Bereich (und über dem Textfeld) befinden sich **5 Schnellaktions-Buttons**, die wie intelligente Shortcuts funktionieren. Sie senden automatisch einen vorkonfigurierten Prompt zusammen mit dem Code, den Sie im Godot Script-Editor markiert haben.

### Wie sie funktionieren
1. **Öffnen Sie ein beliebiges Script** (`.gd`) im Godot Code-Editor.
2. **Markieren Sie einen Code-Ausschnitt** mit der Maus oder Tastatur (z.B. eine ganze Funktion, einen `if`-Block oder einige Zeilen).
3. **Klicken Sie auf einen der unten stehenden Buttons**:

### Die 5 Buttons

| Button | Gesendeter Prompt | Was die KI tut |
|-------|---------------|----------------|
| **✧ Refactor** | "Refactor this code" | Analysiert den markierten Ausschnitt und schlägt eine sauberere, effizientere Version mit besseren GDScript-Praktiken vor. |
| **◆ Fix** | "Fix errors in this code" | Identifiziert Bugs, Syntaxfehler, falsche Typen oder fehlerhafte Logik im Ausschnitt und generiert einen Fix per Diff. |
| **💡 Explain** | "Explain what this code does" | Erklärt Zeile für Zeile in natürlicher Sprache, was der Ausschnitt tut – perfekt zum Lernen oder Dokumentieren. |
| **↺ Undo** | *(Direkte Aktion)* | Macht die letzte von der KI am Projekt vorgenommene Änderung rückgängig (nutzt Godots natives Undo/Redo-System). Kein Prompt. |
| **🖥 Fix Console** | *(Liest Output)* | Liest die neuesten roten Fehler aus der Godot Output-Konsole und sendet sie direkt an die KI zur Diagnose und für einen Fix-Vorschlag. |

### Beispiel mit "Fix Console"
1. Sie starten das Spiel über Godot (`F5`).
2. Das Spiel stürzt ab und ein roter Fehler erscheint: `Attempt to call function 'die' in base 'null instance'`.
3. Ohne etwas zu kopieren, klicken Sie auf **🖥 Fix Console**.
4. Die KI liest selbst das Output-Log, findet das problematische Script und schlägt den Fix in einem sicheren Diff vor.

::: tip Tipp
Der Button **"Fix Console"** unterscheidet sich vom **"Watch Mode"**. Die Konsole erfordert einen manuellen Klick, während der Watch-Modus nach der Aktivierung automatisch im Hintergrund arbeitet.
:::
