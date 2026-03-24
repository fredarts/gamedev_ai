# Index Codebase (L'esprit analytique)

L'un des points les plus précieux de Gamedev AI, qui le différencie radicalement de ChatGPT conventionnel ou d'autres copilotes VSCode, est sa connaissance approfondie de la structure connective de votre projet de jeu.

Si le "Open Context" est l'œil actuel de l'IA, l'**Index Codebase** est le réseau neuronal latent du robot.

## Qu'est-ce que l'indexation vectorielle (Vector DB) ?

Lorsque l'on travaille avec d'immenses frameworks comme Godot, de nombreuses classes personnalisées comme `PlayerStats`, `InventoryManager` ou `WeaponBuilder` n'appartiennent pas au manuel GDScript classique que l'IA a étudié il y a des années chez OpenAI. Ce sont des classes que **vous** avez créées.

Aller là-bas et coller le script `PlayerStats` à chaque fois dans le chat pour poser des questions sur l'inventaire dévore des milliers de tokens répétitifs et votre temps. Grâce à l'indexation DB (Recherche Vectorielle), c'est terminé.

### Utiliser l'indexation (Bouton Settings)
1. Allez dans le panneau Gamedev AI et cliquez sur l'onglet caché en forme d'engrenage pour les options de contexte ("⚙️ Settings" dans le coin inférieur).
2. Faites défiler le panneau d'options vers le bas pour révéler la fenêtre **Vector Database**.
3. Cliquez sur **🔍 Scan Changes**. Le plugin balayera tous vos noms de fichiers sur le disque, à la recherche de suppressions ou de modifications non signalées.
4. La *Liste des Fichiers* visuelle se remplira de couleurs indiquant les ajouts cruciaux et les anciens fichiers inchangés. S'il y a une divergence par rapport à la dernière indexation finale :
5. Enfin, cliquez sur **⚡ Index Database**.

Cela activera le mode d'indexation invisible avec l'API text-embedding de Gemini. À la fin de la progression, un réseau RAG JSON sémantique sera caché et chiffré sur le disque sous le nom `.gamedev_ai/vector_db.json`.

Maintenant, essayez dans le chat :
* *"Comment puis-je corriger le bug de l'inventaire ?"*

L'IA répondra : *"Oh, j'ai remarqué d'après vos scripts dans `res://src/player_inventory.gd` et l'appel dans `Network.gd` que les classes ne sont pas connectées de manière persistante. Je vais ajuster cela."*

[**Étape suivante : Comprendre les 25 fichiers "Skills" qui aident le RAG** ➔](./skills.md)
