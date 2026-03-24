# Watch-Modus (Die Magie des Auto-Debuggings)

Als Gamedev verbringen Sie **30 % Ihrer Zeit mit dem Entwickeln fantastischer Spiellogik** und mühsame **70 % damit, rote semantische Fehler und Null-Referenz-Exceptions** im Reiter `Debugger / Output` von Godot zu entziffern.

Die **Watch Mode**-Funktion von Gamedev AI eliminiert diese mühsame zweite Phase des manuellen Debuggings. Sie verwandelt den Bot in einen unsichtbaren QA-Ingenieur, der im Zimmer nebenan für Sie arbeitet.

## Warum und wie man ihn aktiviert
Aktivieren Sie unten in Ihrem Chat-Panel den Schalter namens **[x] Watch Mode**.

Was im Hintergrund passiert:
1. Sie drücken `F5` (Szene abspielen / Projekt debuggen) in Godot.
2. Ihr Spieler kollidiert mit einer `Area2D`, in der Sie die Initialisierung der `NodeGroup` vergessen haben. Die Engine stürzt ab und gibt einen tödlichen roten Text im Output aus ("Attempt to call function 'die' in base 'null instance'").
3. Ohne dass Sie klicken oder Text kopieren müssen, _wacht Gamedev AI auf_, liest das Log der Syntaxfehler in den letzten 50 Blöcken der Konsole, sammelt die verdächtigen indexierten Dateien, formuliert die Hypothese des Referenzfehlers und schickt sofort eine **Diff-Umschreib-Lösung** zurück oder erklärt Schritt für Schritt, wo der problematische Node liegt.

## "Toleranzgrenzen" und Cooldown

Zu aktive Assistenten verbrennen Token-Guthaben bei kostenpflichtigen Modellen, indem sie repetitive "Orphan Warnings" von Godot Engine senden (unbedeutende gelbe Warnungen, die eigentlich nichts kaputt gemacht haben).

Um Ihren Geldbeutel und den Workflow zu schonen, limitiert Gamedev AI die Überwachung mit **dynamischen Cooldowns**:
* Er wird spätestens bei den ersten **drei** kritischen Output-Wellen ausgelöst, die vom Log in 30-Sekunden-Abschnitten gemeldet werden, oder er verharrt zeitweise im `Standby`.

*Die Pflege der Engine ist fast zu einem Kinderspiel geworden, während man autonome Ratschläge liest.*
