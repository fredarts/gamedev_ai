# Der Diff-Bildschirm (Grünes Licht für Entwickler)

Gamedev AI schreibt Code asynchron. Das bedeutet, dass es Ihre Datei umschreibt und Dutzende Instanzen editiert, während Sie das Log in der Engine lesen.
Aber Moment mal, dem Bot die automatische Schreibkontrolle über Ihre Festplatte zu geben – zerstört das nicht die gestalterische Freiheit des Entwicklers?

Nein! *Der Diff-Bildschirm sichert Ihre Arbeit und Ihr Projekt vor versehentlichen Schäden.*

Das Gamedev AI Plugin implementiert das "Safe View Diff"-Fenster, vergleichbar mit den bekannten Versionierungs-Ansichten (GitHub/GitLens) in VSCode.

## Wie das Diff entsteht
1. Wenn Sie anfordern, ein `EnemyAttack.gd` zu erstellen oder zu korrigieren, zeigt das Log den Fortschritt beim Umschreiben der Klassen-Metadaten an...
2. Sie hören einen visuellen "Ping" und ein **dunkler Diff-Tab** mit dem Text [Original Code] neben [New Code Changes] erscheint sofort und füllt den Chat-Bildschirm mit Text.
3. Die **[color=red]Rot markierten Zeilen -[/color]** stehen für den originalen Code, der (potenziell) gelöscht wird.
4. Die **[color=green]Grün markierten Zeilen +[/color]** zeigen die neuen Neuerungen der künstlichen Intelligenz an.

## Anwenden oder Überspringen (Die Macht der Ablehnung)

Am Ende des Diffs (scrollen Sie den Balken bis zum Ende oder analysieren Sie ihn in Ruhe) erscheinen entscheidende Sicherheits-Buttons:
* **"Apply Changes" (Änderungen anwenden):** Gamedev AI nutzt den offiziellen Undo/Redo-Verlauf von Godot Engine und modifiziert das tatsächliche Ziel-Script. Wenn Sie im Script `Strg + Z` drücken, kehren Sie zum Zustand vor dem Eingriff der KI zurück.
* **"Skip" (Überspringen):** Gefällt Ihnen die Idee der KI nach Sichtung des Diffs nicht? Drücken Sie "Skip". Keine Zeile wird geändert (nicht einmal im Cache) und es entsteht kein technischer Schaden, es wurden lediglich *Token* verbraucht.

> _(Visualisierung des Diffs in der Praxis:)_

![Diff-Fenster zeigt gelöschten Code in Rot und hinzugefügten in Grün, mit Buttons zum Anwenden und Überspringen](../../images/diff_preview.png)
