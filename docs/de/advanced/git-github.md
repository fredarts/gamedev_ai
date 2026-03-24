# Git & GitHub Tab (Versions-Automatisierung)

Spiele in Godot zu erstellen, löst bei Anfängern oft Panik aus, wenn es darum geht, Dutzende von undurchsichtigen Binärdateien (Szenen, Materialien, Ressourcen) zu *committen*. Ein *Merge* im Terminal ist anstrengend.

Deshalb implementiert **Gamedev AI** einen nativen **Git**-Tab innerhalb von Godot, der exklusiv für einen flüssigen Workflow entwickelt wurde.

## So nutzen Sie den Versionierungs-Tab

Wechseln Sie im rechten Fenster des Plugins vom klassischen `Chat`- oder `Settings`-Tab zum oberen **Git**-Tab.
Dort sehen Sie eine vereinfachte und moderne visuelle Version des Terminals:

![Git-Tab Interface mit Commit-Buttons, Branches und Notfall-Operationen](../../images/git_tab.png)

### 1. Initialisieren & Verbinden
Falls der Ordner nicht versioniert ist, erscheint ein riesiger grüner "Initialize Repository"-Button. Danach bittet Sie das Panel, die **GitHub-URL** des Cloud-Repos einzufügen, das Sie auf der GitHub-Website erstellt haben.

### 2. Commit-Nachricht generieren ✨ (Der Gold-Standard)
1. Sie haben gerade programmiert, 4 komplexe Szenen geändert und Scripts (`.gd`) überarbeitet.
2. Statt über einen langweiligen Text für den Commit nachzugrübeln, klicken Sie auf **"✨ Auto-Generate Commit Message"**.
3. Gamedev AI führt einen unsichtbaren Diff durch. Die künstliche Intelligenz sieht sich absolut alle gelöschten roten und neu hinzugefügten grünen Codes an (z.B. *Roll-Logik für Player hinzugefügt und UI-Drag korrigiert*) und erstellt eine super polierte Beschreibung im Textfeld für Sie.
4. Klicken Sie einfach auf **Commit & Sync (Push)**. Die KI lädt alles sofort in die Cloud hoch!

### 3. Isolierte Branches (Zeitlinien)
Haben Sie Angst, Ihre heute perfekte `Level_1.tscn`-Szene zu ruinieren, während Sie einen neuen Boss testen?
Nutzen Sie den seitlichen **Current Branch**-Reiter und klicken Sie auf [Create/Switch]. Tippen Sie `test_boss` ein und bestätigen Sie. Von nun an sind Sie in einer "isolierten Kopie" des Codes sicher.

### 4. Panik-Modus (Fehler rückgängig machen)
Das untere Panel enthält die Super-Aktionen:
* **Undo Uncommitted Changes:** Ist die Godot-Engine explodiert? Drücken Sie diesen Button und alles kehrt sofort zum Zustand Ihrer letzten auf GitHub gespeicherten Version zurück. Ein universelles "Strg+Z" für das gesamte Projekt.
* **Force Pull Overwrite:** Überschreibt Ihren kompletten lokalen Ordner, indem der exakte Zustand aus Ihrer Cloud heruntergeladen und ersetzt wird. Ein perfekter Lebensretter für Programmierer.
* **Force Push:** Überschreibt die Cloud-Version mit der lokalen Version. Mit Vorsicht genießen!
