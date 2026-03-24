# Die 25 integrierten Skills (Vollständiger Katalog)

Gamedev AI ist keine generische KI, die sich nur auf ein aus dem Internet trainiertes Gedächtnis verlässt. Sie verfügt über **25 Expertenmodule**, die speziell für Godot 4.6 geschrieben wurden. Diese werden bei Gesprächen automatisch konsultiert, um sicherzustellen, dass der generierte Code den besten Industriestandards entspricht.

Im Folgenden werden alle 25 Skills mit ihrem Zweck und Beispielen für die Nutzung durch die KI aufgeführt.

---

## 📜 GDScript & Sprache

### 1. `gdscript_style_guide`
**GDScript Style Guide.** Benennungskonventionen (snake_case, PascalCase), Dateiorganisation, statische Typisierung, Deklarationsreihenfolge und Best Practices für die Formatierung nach offiziellem Godot-Standard.

### 2. `gdscript_modern_features`
**Moderne GDScript-Features.** Lambdas, erweiterte statische Typisierung, `await`, `super()`, typisierte Enums, fortgeschrittene `match`-Pattern und alle neuen GDScript 2.0+ Funktionen, die veraltete Syntax ersetzt haben.

### 3. `gdscript_deprecated`
**Veraltete GDScript-Funktionen.** Vollständige Liste der Funktionen, Methoden und Pattern, die zwischen Godot 3 und Godot 4 entfernt oder ersetzt wurden. Die KI konsultiert diesen Skill, um niemals veralteten Code vorzuschlagen.

### 4. `gdscript_recipes_and_patterns`
**GDScript-Rezepte und Pattern.** Vorgefertigte Lösungen für gängige Probleme: Singleton, Object Pooling, Dependency Injection, Observer und idiomatische Implementierungen in GDScript.

### 5. `gdscript_signals_and_tweens`
**Signale und Tweens.** Tiefgreifender Leitfaden zum Signalsystem von Godot 4, `SceneTreeTween`, Erstellung prozeduraler Animationen, Tween-Chaining und Best Practices für Entkopplung mittels Signalen.

---

## 🏗️ Architektur & Struktur

### 6. `common_architectures`
**Gängige Spielarchitekturen.** Architekturmuster wie Entity-Component, MVC für Spiele, Service Locator, Event Bus und wie man Godot-Projekte mittlerer bis großer Größe strukturiert.

### 7. `project_structure_guidelines`
**Richtlinien zur Projektstruktur.** Ideale Ordnerorganisation (`src/`, `assets/`, `ui/`, `autoloads/`), Dateibenennungskonventionen, Autoloads vs. Dependency Injection und wann welcher Ansatz zu wählen ist.

### 8. `state_machine_implementation`
**Implementation von State Machines.** State-Machine-Pattern mit Child-Nodes, saubere Übergänge, hierarchische Zustände und Integration mit AnimationTree für komplexe Charaktere.

---

## 🎮 Spielsysteme

### 9. `inventory_and_item_systems`
**Inventar- und Item-Systeme.** Ressourcen-basierte Inventar-Architektur, Slots, Stacking, Drag & Drop von Items, Serialisierung für Spielstände und reaktives Inventar-UI.

### 10. `quest_and_dialogue_systems`
**Quest- und Dialogsysteme.** Implementierung von Dialogbäumen, Quest-System mit Zuständen (aktiv/abgeschlossen/fehlgeschlagen), NPCs, Fortschrittsbedingungen und UI-Anbindung.

### 11. `save_system_and_persistence`
**Save-System und Persistenz.** Vollständige Serialisierung des Spielstatus in JSON/Binär, Auto-Save, mehrere Speicherplätze, Versionierung von Spielständen und Migration bei Updates.

### 12. `data_management_and_crafting`
**Datenmanagement und Crafting.** Crafting-Systeme mit Ressourcen-basierten Rezepten, Item-Datenbanken, Loot-Tabellen und Balancing der Spielökonomie.

---

## 🕹️ Mechanik & Physik

### 13. `physics_and_collision_handling`
**Physik und Kollisionsabfrage.** Konfiguration von Layern/Masken, CharacterBody2D/3D, RigidBody, Raycasting, Detektionsbereiche und Behebung gängiger Physikprobleme.

### 14. `input_handling_and_remapping`
**Eingabeverarbeitung und Remapping.** InputMap, benutzerdefinierte Aktionen, Unterstützung für Gamepad/Tastatur/Touch, Remapping zur Laufzeit, Input-Buffering und Deadzones.

### 15. `ai_and_pathfinding`
**KI und Pathfinding.** NavigationServer2D/3D, NavigationAgent, Hindernisvermeidung (Avoidance), vereinfachte Behavior Trees, Verfolgung, Patrouillen und Gegner-KI basierend auf Zuständen.

---

## 🎨 Visuelles & Audio

### 16. `shaders_and_vfx`
**Shader und VFX.** Godot Shading Language, Dissolve-Effekte, Outlines, Distorsion, GPU-Partikel, Trails und VFX-Techniken für 2D- und 3D-Spiele.

### 17. `post_processing_and_environment`
**Post-Processing und Umgebung.** WorldEnvironment, Glow, Fog, SSAO, SSR, Tonemapping, Farbkorrektur und filmische Umgebungs-Setups.

### 18. `animation_and_cutscenes`
**Animationen und Cutscenes.** AnimationPlayer, AnimationTree, Blend Spaces, Animations-Zustandsmaschinen, AnimationPlayer-Cutscenes und weiche Übergänge.

### 19. `audio_management_best_practices`
**Audio-Management.** AudioBus, AudioStreamPlayer2D/3D, Pooling von Soundeffekten, adaptive Musik, Crossfades, Abmischung und Organisation des Audiosystems.

---

## 🖥️ Interface & Plattform

### 20. `ui_ux_patterns`
**UI/UX-Muster.** Reaktive Menüs, HUD, globale Themes, Gamepad-Navigation, Bildschirmübergänge, Popups und Best Practices für UI in Godot.

### 21. `mobile_and_resolution_scaling`
**Mobilgeräte und Resolution Scaling.** Stretch-Modus-Konfiguration, Aspect Ratio, Touch-Eingabe, virtuelle Joysticks, Mobiloptimierungen und Multi-Auflösungs-Tests.

### 22. `localization_and_i18n`
**Lokalisierung und i18n.** Übersetzungssystem mit `.csv`/`.po`, TranslationServer, Sprachwechsel zur Laufzeit, Zahlen-/Datumsformatierung und Unterstützung von RTL (Right-to-Left).

---

## 🌐 Multiplayer & Performance

### 23. `multiplayer_and_networking_api`
**Multiplayer und Networking.** ENet, WebSocket, MultiplayerSpawner/Synchronizer, RPCs, Authority, Client-Server-Architektur, Lobbysysteme und Statussynchronisierung.

### 24. `performance_optimization`
**Performance-Optimierung.** Profiling, Object Pooling, LOD, Culling, Batch Rendering, GDScript-Optimierung, Reduzierung von Draw Calls und Techniken für 60Hz-Gaming.

### 25. `level_generation_and_pcg`
**Levelgenerierung und PCG.** Prozedurale Dungeon-Generierung, Wave Function Collapse, Noise-basiertes Terrain, Auto-TileMaps und reproduzierbare Random-Seeds.

---

## 🛠️ Eigene Skills erstellen

Das Skillsystem ist **erweiterbar**! Sie können eigene `.md`-Dateien im Ordner `addons/gamedev_ai/skills/` erstellen, um der KI projektbezogene Regeln beizubringen.

**Beispiel:** Erstellen Sie eine Datei namens `mein_art_style.md` mit:
```markdown
# Art-Regeln unseres Studios

- Alle Assets müssen 16x16 oder 32x32 Pixel groß sein.
- Nutze eine limitierte Palette (max 32 Farben).
- Charakter-Animationen brauchen mind. 4 Frames.
- Benenne Sprites so: typ_name_aktion_frame.png
```

Die KI wird diese Regeln bei jeder Erstellung oder Änderung visueller Assets in Ihrem Projekt befolgen.
