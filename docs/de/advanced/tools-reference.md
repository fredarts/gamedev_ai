# Alle KI-Tools (Tool Reference)

Gamedev AI verfügt über **27 integrierte Tools**, die die KI während eines Gesprächs autonom aufrufen kann. Diese Tools sind der "mechanische Arm", der es der KI ermöglicht, direkt mit der Godot Engine zu interagieren. Jedes Tool wird im Folgenden nach Kategorien gruppiert beschrieben.

## 🔧 Scripts (Code-Erstellung und -Edition)

### `create_script`
Erstellt eine neue GDScript-Datei (`.gd`) am angegebenen Pfad mit dem bereitgestellten Inhalt. Die KI nutzt dieses Tool, um Scripts von Grund auf zu generieren.
- **Parameter:** `path` (res://...), `content` (vollständiger GDScript-Code)

### `edit_script`
Ersetzt den gesamten Inhalt eines bestehenden Scripts durch eine neue Version. Die KI liest die Datei zuerst, um sicherzustellen, dass sie die neueste Version hat.
- **Parameter:** `path`, `content`
- ⚠️ *Veraltet zugunsten von `patch_script` für punktuelle Änderungen.*

### `patch_script`
Punktuelle Änderung (Surgical Edit): Sucht nach einem exakten Code-Block im Script und ersetzt nur diesen Ausschnitt durch den neuen Inhalt. Ideal für kleine Fixes, ohne die gesamte Datei neu zu schreiben.
- **Parameter:** `path`, `search_content` (exakter zu suchender Block), `replace_content` (neuer Block)

### `replace_selection`
Ersetzt den aktuell markierten Text im Godot Script Editor. Funktioniert in Verbindung mit Schnellaktions-Buttons (Refactor, Fix, Explain).
- **Parameter:** `text` (neuer Code zum Ersetzen der Markierung)

### `view_file_outline`
Gibt die Struktur eines Scripts ohne den vollen Code zurück: `class_name`, `extends`, Funktionen, Signale, Exports, Enums, Inner Classes und Konstanten mit Zeilennummern.
- **Parameter:** `path`

---

## 🌳 Nodes (Scene Tree Manipulation)

### `add_node`
Fügt der im Editor geöffneten Szene einen neuen Node hinzu. Kann jeden Godot Node-Typ erstellen (Node2D, CharacterBody3D, Label, Button etc.).
- **Parameter:** `parent_path` (nutze `.` für den Root), `type` (Node-Klasse), `name`, `script_path` (optional)

### `remove_node`
Entfernt einen Node aus dem aktuellen Scene Tree. Erfordert eine Bestätigung des Benutzers, da dies eine destruktive Aktion ist.
- **Parameter:** `node_path`

### `set_property`
Setzt eine Eigenschaft an einem Scene Node (Position, Größe, Text, Farbe etc.). Akzeptiert Zahlen, Vektoren, Farben und Strings.
- **Parameter:** `node_path`, `property`, `value`

### `set_theme_override`
Setzt einen Theme-Override an einem Control Node (Schriftgröße, Schriftfarbe, Style).
- **Parameter:** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
Verbindet das Signal eines sendenden Nodes mit der Methode eines empfangenden Nodes in der aktuellen Szene.
- **Parameter:** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (optional), `flags` (optional)

### `disconnect_signal`
Trennt ein zuvor verbundenes Signal zwischen zwei Nodes.
- **Parameter:** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
Hängt ein bestehendes GDScript an einen Node in der Szene an.
- **Parameter:** `node_path`, `script_path`

### `analyze_node_children`
Gibt einen detaillierten Dump des Sub-Trees eines spezifischen Nodes in der editierten Szene zurück. Nützlich zur Erkundung tiefer Hierarchien.
- **Parameter:** `node_path`, `max_depth` (Standard: 5)

---

## 📂 Dateien und Projekt

### `read_file`
Liest den vollständigen Inhalt einer beliebigen Projektdatei.
- **Parameter:** `path`

### `list_dir`
Listet den Inhalt eines Projektverzeichnisses auf.
- **Parameter:** `path`

### `find_file`
Sucht nach einer Projektdatei anhand des Namens (Partial Match).
- **Parameter:** `pattern`

### `remove_file`
Löscht eine Datei oder ein Verzeichnis aus dem Projekt. Erfordert Bestätigung.
- **Parameter:** `path`

### `move_files_batch`
Verschiebt oder benennt mehrere Dateien/Verzeichnisse in einer einzigen Batch-Operation um. Aktualisiert automatisch alle internen Godot-Referenzen (`.tscn`, `.tres`).
- **Parameter:** `moves` (Dictionary, das alte Pfade auf neue mappt)

### `create_scene`
Erstellt eine neue Szenendatei (`.tscn`) und öffnet sie im Editor.
- **Parameter:** `path`, `root_type`, `root_name`

### `instance_scene`
Instanziiert eine bestehende `.tscn`-Szene als Kind eines anderen Nodes in der aktuellen Szene.
- **Parameter:** `parent_path`, `scene_path`, `name`

### `create_resource`
Erstellt eine neue Resource-Datei (`.tres`). Nützlich für Assets wie Items, Stats oder benutzerdefinierte Konfigurationen.
- **Parameter:** `path`, `type`, `properties` (optional)

---

## 🔍 Suche und Analyse

### `grep_search`
Sucht nach Text innerhalb von Projektdateien. Gibt gefundene Zeilen mit Pfad und Zeilennummer zurück.
- **Parameter:** `query`, `include` (Erweiterungsfilter, optional), `max_results` (Standard: 20)

### `search_in_files`
Sucht per Regex in allen Projekt-`.gd`-Dateien nach Variablen, Funktionen oder spezifischer Logik.
- **Parameter:** `pattern` (Regulärer Ausdruck)

### `get_class_info`
Gibt detaillierte Informationen über eine Godot-Klasse (Engine oder Custom) zurück: Basisklasse, Properties, Methoden und Signale.
- **Parameter:** `class_name`

### `capture_editor_screenshot`
Erstellt einen Screenshot des gesamten Godot-Editor-Fensters und hängt ihn automatisch an den nächsten Prompt für eine visuelle Analyse an.

---

## 🧠 Memory und Wissen

### `save_memory`
Speichert einen persistenten Fakt in der Projekt-Memory, der in allen zukünftigen Chat-Sitzungen verfügbar ist.
- **Parameter:** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
Listet alle für dieses Projekt gespeicherten persistenten Fakten auf.

### `delete_memory`
Löscht einen spezifischen Memory-Fakt anhand seiner ID.
- **Parameter:** `id`

### `read_skill`
Liest eine Skill-Dokumentationsdatei aus der internen Bibliothek der KI, um vor der Programmierung Best Practices zu lernen.
- **Parameter:** `skill_name`

---

## 🗄️ Vector Database (RAG)

### `index_codebase`
Indexiert das gesamte Projekt (`.gd`) in eine lokale Vektor-Datenbank für die semantische Suche. Muss vor der Nutzung von `semantic_search` ausgeführt werden.

### `semantic_search`
Führt eine semantische Vektorsuche auf der indexierten Codebasis durch, um hochrelevante Code-Schnipsel basierend auf der Bedeutung (nicht nur auf exaktem Textmatch) zu finden.
- **Parameter:** `query`

---

## 🧪 Tests

### `run_tests`
Führt ein Test-Script oder einen Befehl aus. Nützlich zur Prüfung von Änderungen mit GUT, GdUnit4 oder benutzerdefinierten Test-Scripts.
- **Parameter:** `test_script_path` (optional)
