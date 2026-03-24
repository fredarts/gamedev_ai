# Mémoire persistante (L'IA comme architecte)

Si l'Indexation (Codebase) enseigne à l'IA **"Où"** se trouve chaque fichier source que Godot a traité, la Mémoire Persistante lui enseigne **"Pourquoi"** les choses ont été programmées de cette manière.

Les développeurs en solo et les petits studios souffrent après des semaines sans ouvrir un projet. *Pourquoi la classe Save Game sauvegarde-t-elle en binaire et non en JSON ? Pourquoi ai-je utilisé un CharacterBody2D avant de changer d'avis plus tard ?*

## Le bouton "Summarize to Memory"

Dans l'onglet central supérieur du panneau de Chat `(à côté du bouton History)`, se trouve le brillant bouton **💾 Summarize to Memory**.

Chaque fois que vous avez une session longue, ardue et complexe avec l'IA (par exemple, la refactorisation de tout le système de physique des voitures), suivez cette étape :
1. À la fin de la journée, cliquez sur **Summarize to Memory**.
2. L'IA effectue une lecture approfondie de tout ce dont vous avez discuté.
3. Elle créera des fichiers au format *Memory Log* permanent dans le dossier invisible `.gamedev_ai` de votre projet.
4. Lorsque vous ouvrirez le projet 3 semaines plus tard pour corriger un bug dans la physique de la voiture, l'IA extraira magiquement de ses entrailles la raison pour laquelle vous n'avez pas utilisé la "Friction" native de Godot, sans que vous ayez à ouvrir 40 anciennes fenêtres de chat pour vous en souvenir.

*Le plugin Godot devient ainsi le documentateur et l'ingénieur logiciel attitré de votre studio.*
