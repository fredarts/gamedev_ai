# 🧠 Agenten & Intelligenz

Gamedev AI ist nicht nur ein Chat, der Code schreibt. Es wird von einer hochmodernen Agenten-Architektur angetrieben, die auf bewährten Methoden der autonomen Entwicklung basiert. Dies ermöglicht es dem Assistenten, methodisch, proaktiv und kontextbewusst zu handeln.

---

## 🎭 Spezialisierte Personas (Dynamic Routing)

Die KI erkennt automatisch Ihr Ziel basierend auf Ihrem Gespräch und nimmt eine spezifische "Persona" an. Dies stellt sicher, dass der Prompt nur auf das Wesentliche fokussiert ist, was Token spart und die Präzision erhöht.

- **Godot Expert**: Der allgemeine Assistent für Spiellogik und Struktur.
- **UI/UX Designer**: Fokussiert auf `Control`-Nodes, Anchor und responsive Layouts.
- **Technical Artist**: Spezialist für Shader, Partikel und visuelle Effekte.
- **Multiplayer Engineer**: Fokussiert auf Netzwerke, RPCs und Synchronisation.

> [!TIP]
> Sie können eine Persona erzwingen, indem Sie Schlüsselwörter wie "Ich brauche ein Menü (UI)" oder "Ich erstelle einen Shader" verwenden.

---

## ⛩️ Sokratisches Tor (Stop & Ask)

Um zu vermeiden, dass massiver und generischer Code generiert wird, der möglicherweise nicht für Ihr Projekt geeignet ist, implementiert die KI das **Sokratische Tor**.

Wann immer Sie etwas Komplexes anfordern (z. B.: "Erstelle ein Inventarsystem"), wird die KI:
1. Den Codegenerierungsprozess **stoppen**.
2. Mindestens 2 **Fragen** zu Trade-offs oder Grenzfällen stellen (z. B.: "Soll es auf Slots oder Gewicht basieren?", "Wird eine Datenbank-Persistenz benötigt?").
3. Die Aufgabe erst nach Ihrer Klärung **ausführen**.

---

## ⌨️ Workflows via Slash Commands

Sie können direkte Befehle verwenden, um das Verhalten der KI sofort zu ändern:

- `/brainstorm`: Die KI wechselt in den Entdeckungsmodus. Sie schreibt keinen Code, sondern hilft bei der Planung der Architektur, des GDD und der Logik.
- `/plan`: Fokussiert auf die Strukturierung von Ordnern und Szenen vor der Codierung.
- `/debug`: Tiefer Untersuchungsmodus. Konzentriert sich nur auf Fehlerprotokolle und die Ursachenanalyse.

---

## 🔍 Auto-Audit (Autonome Verfeinerung)

Nach der Durchführung komplexer Änderungen hat die KI die Autonomie, Audit-Tools (`audit_script`, `audit_scene`) auszuführen, um Syntaxfehler oder verwaiste Referenzen zu überprüfen, bevor die Aufgabe als abgeschlossen gilt. Dies garantiert einen wesentlich kürzeren Feedback-Zyklus und stabileren Code.
