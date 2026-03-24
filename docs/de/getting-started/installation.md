# Installation

Willkommen in der offiziellen Dokumentation von **Gamedev AI**! Diese Seite konzentriert sich darauf, wie Sie den Assistenten schnell zu Ihrem aktuellen Godot 4.6 Projekt hinzufügen können.

## Voraussetzungen
* **Godot Engine:** Version 4.6 oder höher (native `.gdextension` Unterstützung ist nicht erforderlich, das Plugin läuft in reinem GDScript).
* Google- oder OpenRouter-Konto für API-Keys.

## Manuelle Schritt-für-Schritt-Anleitung (GitHub)

1. Erstellen oder öffnen Sie ein bestehendes Projekt in Godot 4.6.
2. Navigieren Sie zum Stammverzeichnis Ihres Projekts (dort, wo sich die Datei `project.godot` befindet).
3. Erstellen Sie einen Ordner namens `addons` (falls dieser noch nicht existiert).
4. Laden Sie das Plugin-Repository in `addons/` herunter oder klonen Sie es:
```bash
git clone git@github.com:fredarts/gamedev_ai.git
```
*(Oder laden Sie die `.zip`-Datei vom GitHub Releases-Tab herunter und extrahieren Sie sie nach `res://addons/gamedev_ai`).*

## Aktivierung im Editor

Sobald die Dateien vorhanden sind:
1. Öffnen Sie den Editor Ihres Godot-Projekts.
2. Gehen Sie oben auf das Menü `Projekt` und wählen Sie `Projekteinstellungen`.
3. Navigieren Sie oben zum Reiter `Plugins`.
4. Suchen Sie **Gamedev AI** in der Liste der installierten Plugins.
5. Setzen Sie ein Häkchen bei `Aktiviert`.

Das ist alles! Wenn Sie es zum ersten Mal aktivieren, erscheint das Gamedev AI Chat-Panel im rechten *Dock* Ihres Editors.

[**Nächster Schritt: Konfigurieren Sie Ihren API-Key** ➔](./configuration.md)
