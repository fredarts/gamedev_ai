# Persistente Memory (Die KI als Architekt)

Während die Indexierung (Codebase) der KI beibringt, **"Wo"** sich jede von Godot verarbeitete Quelldatei befindet, lehrt die Persistente Memory sie, **"Warum"** Dinge auf diese Weise programmiert wurden.

Solo-Entwickler und kleine Studios leiden oft darunter, wenn sie ein Projekt nach Wochen wieder öffnen. *Warum speichert die Save Game-Klasse im Binärformat und nicht als JSON? Warum habe ich einen CharacterBody2D genutzt, bevor ich meine Meinung später änderte?*

## Der "Summarize to Memory"-Button

Oben im mittleren Reiter des Chat-Panels `(neben dem History-Button)` befindet sich der brillante Button **💾 Summarize to Memory**.

Wann immer Sie eine lange, mühsame und komplexe Session mit der KI hatten (z.B. das Refactoring des gesamten Fahrzeugphysik-Systems), folgen Sie diesem Schritt:
1. Klicken Sie am Ende des Tages auf **Summarize to Memory**.
2. Die KI liest alles Gelesene und Diskutierte gründlich durch.
3. Sie erstellt permanente Dateien im *Memory Log*-Format im unsichtbaren Ordner `.gamedev_ai` Ihres Projekts.
4. Wenn Sie das Projekt 3 Wochen später öffnen, um einen Bug in der Fahrzeugphysik zu beheben, wird die KI auf magische Weise aus ihrem Inneren extrahieren, warum Sie nicht Godots native "Friction" genutzt haben, ohne dass Sie 40 alte Chat-Fenster öffnen müssen, um sich zu erinnern.

*Damit wird das Godot-Plugin zum Dokumentator und führenden Software-Ingenieur Ihres Studios.*
