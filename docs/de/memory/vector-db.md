# Index Codebase (Der analytische Verstand)

Einer der wertvollsten Aspekte von Gamedev AI, der es radikal von herkömmlichen ChatGPT-Lösungen oder anderen VSCode-Copiloten unterscheidet, ist sein tiefes Verständnis der verbindenden Struktur Ihres Spielprojekts.

Wenn der "Open Context" das aktuelle Auge der KI ist, dann ist die **Index Codebase** das latente neurale Netzwerk des Bots.

## Was ist die vektorielle Indexierung (Vector DB)?

Bei der Arbeit mit gewaltigen Frameworks wie Godot gehören viele benutzerdefinierte Klassen wie `PlayerStats`, `InventoryManager` oder `WeaponBuilder` nicht zum klassischen GDScript-Handbuch, das die KI vor Jahren bei OpenAI gelernt hat. Das sind Klassen, die **Sie** erstellt haben.

Immer wieder das `PlayerStats`-Script in den Chat zu kopieren, um Fragen zum Inventar zu stellen, verschlingt Tausende redundanter Token und wertvolle Zeit. Dank der DB-Indexierung (Vektorsuche) gehört das der Vergangenheit an.

### Die Indexierung nutzen (Settings-Button)
1. Gehen Sie in das Gamedev AI Panel und klicken Sie auf den oben versteckten Reiter mit dem Zahnrad-Symbol für Kontext-Optionen ("⚙️ Settings" in der unteren Ecke).
2. Scrollen Sie das Einstellungs-Panel nach unten, um das Fenster **Vector Database** zu öffnen.
3. Klicken Sie auf **🔍 Scan Changes**. Das Plugin prüft alle Dateinamen auf der Festplatte nach nicht gemeldeten Löschungen oder Änderungen.
4. Die visuelle *Dateiliste* füllt sich mit Farben, die wichtige Ergänzungen und unveränderte alte Dateien anzeigen. Wenn es eine Abweichung zur letzten finalen Indexierung gibt:
5. Klicken Sie abschließend auf **⚡ Index Database**.

Dies aktiviert den unsichtbaren Indexierungsmodus mit der Gemini Text-Embedding API. Am Ende des Vorgangs wird ein sémantisches RAG-JSON-Netzwerk lokal auf der Festplatte unter `.gamedev_ai/vector_db.json` verschlüsselt gespeichert.

Probieren Sie es nun im Chat aus:
* *"Wie kann ich den Fehler im Inventar beheben?"*

Die KI wird antworten: *"Oh, ich habe anhand Ihrer Scripts in `res://src/player_inventory.gd` und dem Aufruf in `Network.gd` bemerkt, dass die Klassen nicht persistent verbunden sind. Ich werde das anpassen."*

[**Nächster Schritt: Verstehen Sie die 25 "Skills"-Dateien, die dem RAG helfen** ➔](./skills.md)
