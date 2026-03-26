# Vollständiger UI-Guide (Alle Buttons)

Diese Seite beschreibt **jeden Button, Schalter und jedes Bedienelement** im Gamedev AI Interface innerhalb des Godot-Editors.

![Übersicht des Gamedev AI Haupt-Interface in Godot](../../images/main_interface.png)

## 🗂️ Haupt-Tabs

Das Plugin verfügt oben im Panel über **3 Tabs**:
- **Chat** — Das Haupt-Kommunikationspanel mit der KI.
- **Settings** (Einstellungen) — API-Key-Management, Presets, Prompts und Indexierung.
- **Git** — Integrierte Versionskontrolle mit GitHub.

---

## 💬 Chat-Tab

### Obere Leiste
| Button | Funktion |
|-------|--------|
| **Preset Selector** | Dropdown zum schnellen Wechseln zwischen verschiedenen Anbieter-/Modell-Einstellungen (z.B. "Gemini 3.1", "GPT-4o"). |
| **A-** / **A+** | Verkleinert oder vergrößert die Schriftgröße im Chat. |
| **+ New Chat** | Löscht das aktuelle Gespräch und startet eine komplett neue Sitzung. |
| **⊙ History** | Dropdown-Menü aller vergangenen Gespräche. Klicken Sie auf eines, um den vollen Kontext dieser Sitzung wiederherzustellen. |
| **💾 Summarize to Memory** | Sendet einen automatischen Prompt an die KI, um die architektonischen Entscheidungen des aktuellen Gesprächs zusammenzufassen und in der persistenten Memory des Projekts zu speichern. |

### Chat-Bereich (OutputDisplay)
- Zeigt BBCode-formatierte Nachrichten mit **Fett**, *Kursiv*, `Inline-Code` und Syntax-Highlighting für Code-Blöcke an.
- Klickbare Links zu Projektdateien (Klick öffnet sie im Editor).
- Ein schwebender **Copy**-Button erscheint beim Markieren von Text, um diesen schnell zu kopieren.

### TTS-Player (Text-to-Speech)

![Kompakter TTS-Player mit Wiedergabe-Steuerung](../../images/tts_player.png)

| Steuerung | Funktion |
|----------|--------|
| **▶ Vorlesen** | Wandelt die letzte Antwort der KI in Audio um und spielt sie ab. Ideal, um beim Programmieren Erklärungen zuzuhören. |
| **⏹ Stop** | Stoppt die Audiowiedergabe. |
| **Fortschrittsbalken** | Zum Vor- oder Zurückspulen des Audios. |
| **Tempo (1.0x - 2.0x)** | Steuert die Wiedergabegeschwindigkeit. |

### Schnellaktions-Buttons
| Button | Was er tut |
|-------|-----------|
| **✧ Refactor** | Sendet den markierten Code im Editor mit dem Prompt "Refactor this code". Die KI analysiert und schlägt strukturelle Verbesserungen vor. |
| **◆ Fix** | Sendet den markierten Code mit "Fix errors in this code". Die KI identifiziert Bugs und generiert Fixes. |
| **💡 Explain** | Sendet den markierten Code mit "Explain what this code does". Die KI erklärt jeden Teil auf Deutsch. |
| **↺ Undo** | Macht die letzte Aktion rückgängig, die die KI im Projekt ausgeführt hat (nutzt Godots Undo/Redo-System). |
| **🖥 Fix Console** | Liest die neuesten roten Fehler aus der Godot Output-Konsole und sendet sie direkt an die KI, um Fixes vorzuschlagen. |

### Eingabebereich
| Element | Funktion |
|----------|--------|
| **Textfeld** | Geben Sie Ihre Nachricht ein. `Umschalt + Enter` zum Senden. |
| **📎 Attach** | Öffnet einen File Picker, um Bilder, Scripts oder beliebige Dateien an den Prompt anzuhängen. |
| **➤ Send** | Sendet die Nachricht zur Verarbeitung an die KI. |
| **Drag & Drop** | Ziehen Sie Scene Tree Nodes oder FileSystem-Dateien direkt in das Textfeld oder den Chat-Bereich. Die KI erhält die vollen Metadaten. |

### Prompt-Einstellungen (Dropdown)
Diese Optionen sind unter dem ⚙️-Symbol neben der Senden-Schaltfläche gruppiert.

| Einstellung | Funktion |
|--------|--------|
| **Kontext einbeziehen** | Wenn aktiviert, fügt das Plugin automatisch den vollständigen Inhalt des aktuell im Editor geöffneten Skripts an die gesendete Nachricht an. |
| **Screenshot senden** | Wenn aktiviert, wird automatisch ein Screenshot des Godot-Fensters aufgenommen und zur visuellen Analyse an die KI gesendet. |
| **Zuerst planen** | Wenn aktiviert, schreibt die KI keinen Code. Sie antwortet nur mit einem detaillierten Plan. Nach der Überprüfung klicken Sie auf die Schaltfläche "Plan ausführen", damit sie programmiert. |
| **Watch-Modus** | Wenn aktiviert, überwacht die KI automatisch die Godot-Ausgabekonsole. Wenn kritische Fehler erkannt werden, schlägt sie automatisch Korrekturen vor. |

---

## ⚙️ Settings-Tab (Einstellungen)

### Preset-Verwaltung
| Element | Funktion |
|----------|--------|
| **Preset Selector** | Dropdown zur Auswahl gespeicherter Presets. |
| **Add** | Erstellt ein neues, leeres Preset. |
| **Edit** | Öffnet das Edit-Panel (Name, Provider, API Key, Base URL, Model). |
| **Delete** | Löscht das ausgewählte Preset dauerhaft. |
| **Done Editing** | Schließt das Edit-Panel und speichert die Änderungen. |

### Preset-Edit-Felder
| Feld | Beschreibung |
|-------|-----------|
| **Preset Name** | Anzeigename zur Identifizierung (z.B. "Gemini 3.1 Free"). |
| **Provider** | Dropdown-Auswahl zwischen "Gemini" und "OpenAI / OpenRouter". |
| **API Key** | Ihr API-Key des gewählten Anbieters. |
| **Base URL** | Basis-API-URL (nur für OpenAI/OpenRouter). |
| **Model Name** | Exakter Name des Modells (z.B. `gemini-2.5-flash`, `gpt-4o`). |

### Sprache
| Element | Funktion |
|----------|--------|
| **Language Selector** | Dropdown zur Wahl der Interface- und KI-Antwort-Sprache (Deutsch, Português BR, English etc.). |

### Custom System Prompt
Ein großes Textfeld für feste Regeln, denen die KI immer folgen wird. Beispiel: *"Nutze statisches Typisierung bei allen Funktionen. Kommentiere auf Deutsch."*

| Button | Funktion |
|-------|--------|
| **✨ Enhance Instructions with AI** | Sendet Ihre aktuellen Instruktionen an die KI, um diese automatisch zu verbessern (technische Details, Best Practices). Vorschau vor Annahme. |

### Vector Database
| Element | Funktion |
|----------|--------|
| **File List** | Visuelle Liste aller Projekt-`.gd`-Dateien mit Indexierungsstatus. |
| **🔍 Scan Changes** | Scannt das Projekt nach neuen, geänderten oder gelöschten Dateien seit der letzten Indexierung. |
| **⚡ Index Codebase** | Startet den vektoriellen Indexierungsprozess aller geänderten Scripts via Embeddings-API. |

---

## 🐙 Git-Tab

### Erst-Setup
| Element | Funktion |
|----------|--------|
| **Initialize Repository** | Initialisiert ein Git-Repository im Projektordner (falls nicht vorhanden). |
| **Remote URL** | Feld zum Einfügen der GitHub-Repo-URL (z.B. `https://github.com/user/repo.git`). |
| **Set Remote** | Setzt die URL für das Remote-Repository. |

### Hauptoperationen
| Button | Funktion |
|-------|--------|
| **🔃 Refresh Status** | Aktualisiert den Git-Status (geänderte/untracked Dateien, aktueller Branch). |
| **⬇️ Pull** | Lädt die neuesten Änderungen vom Remote-Repository herunter. |
| **✨ Auto-Generate Commit Message** | Die KI analysiert alle Änderungen (Diff) und generiert automatisch eine professionelle Commit-Nachricht. |
| **Commit & Sync (Push)** | Committet alle Änderungen mit der Nachricht und pusht sie zu GitHub. |

### Branches
| Element | Funktion |
|----------|--------|
| **Branch Label** | Zeigt den aktuellen Branch-Namen an. |
| **Branch Name Input** | Feld zur Eingabe eines neuen oder bestehenden Branch-Namens. |
| **Checkout/Create Branch** | Erstellt einen neuen Branch oder wechselt zu einem bestehenden. |

### Notfall-Aktionen
| Button | Funktion |
|-------|--------|
| **⚠️ Undo Uncommitted Changes** | Verwirft ALLE uncommitteten lokalen Änderungen (Reset auf letzten Commit). Bestätigung erforderlich. |
| **⚠️ Force Pull Overwrite** | Ersetzt das lokale Projekt komplett durch den Zustand des Remote-Repositorys. Bestätigung erforderlich. |
| **⚠️ Force Push** | Pusht den lokalen Zustand zum Remote-Repository und überschreibt dort die Historie. Bestätigung erforderlich. |

---

## 📋 Diff Panel (Code Review)

Wenn die KI Code generiert oder ändert, erscheint ein Diff Panel im Chat:

![Diff Panel zeigt gelöschten Code (rot) und hinzugefügten (grün)](../../images/diff_preview.png)

| Element | Funktion |
|----------|--------|
| **Diff View** | Side-by-Side-Ansicht mit gelöschten (rot) und hinzugefügten (grün) Zeilen. |
| **Apply Changes** | Akzeptiert die Änderungen und wendet sie auf die echte Datei an. Aktion wird im Godot-Undo/Redo geloggt. |
| **Skip** | Lehnt die Änderungen ab. Keine Dateien werden verändert. |
