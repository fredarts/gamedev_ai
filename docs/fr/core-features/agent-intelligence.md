# 🧠 Agents et Intelligence

Gamedev AI n'est pas seulement un chat qui écrit du code. Il est propulsé par une architecture d'agents de pointe, basée sur las meilleures pratiques de développement autonome, permettant à l'assistant d'agir de manière méthodique, proactive et consciente du contexte.

---

## 🎭 Personas Spécialisés (Dynamic Routing)

L'IA identifie automatiquement votre objectif en se basant sur votre conversation et adopte une "Persona" spécifique. Cela garantit que le prompt est focalisé uniquement sur ce qui compte, économisant des jetons (tokens) et augmentant la précision.

- **Godot Expert** : L'assistant général pour la logique de jeu et la structure.
- **UI/UX Designer** : Focalisé sur les nœuds de `Control`, les ancres et les mises en page réactives.
- **Technical Artist** : Spécialiste des Shaders, des particules et des effets visuels.
- **Multiplayer Engineer** : Focalisé sur le réseau, les RPC et la synchronisation.

> [!TIP]
> Vous pouvez forcer une persona en mentionnant des mots-clés comme "j'ai besoin d'un menu (UI)" ou "je crée un shader".

---

## ⛩️ Portail Socratique (Stop & Ask)

Pour éviter de générer des codes massifs et génériques qui pourraient ne pas convenir à votre projet, l'IA implémente le **Portail Socratique**.

Chaque fois que vous demandez quelque chose de complexe (ex : "Crée un système d'inventaire"), l'IA :
1. **Arrêtera** la génération de code.
2. **Posera** au moins 2 questions sur les *compromis* ou les cas limites (ex : "Sera-t-il basé sur des emplacements (slots) ou sur le poids ?", "Nécessite-t-il une persistance en base de données ?").
3. **Exécutera** la tâche uniquement après votre clarification.

---

## ⌨️ Workflows via Slash Commands

Vous pouvez utiliser des commandes directes pour changer instantanément le comportement de l'IA :

- `/brainstorm` : L'IA passe en mode découverte. Elle n'écrira pas de code, mais aidera à planifier l'architecture, le GDD et la logique.
- `/plan` : Focalisé sur la structuration des dossiers et des scènes avant le codage.
- `/debug` : Mode d'investigation approfondie. Se concentre uniquement sur les logs d'erreurs et la cause racine.

---

## 🔍 Auto-Audit (Raffinement Autonome)

Après avoir effectué des changements complexes, l'IA a l'autonomie d'exécuter des outils d'audit (`audit_script`, `audit_scene`) para vérifier les erreurs de syntaxe ou les références orphelines avant de considérer la tâche comme terminée. Cela garantit un cycle de feedback beaucoup plus court et un code plus stable.
