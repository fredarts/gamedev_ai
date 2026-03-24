# L'Écran de Diff (Feu vert pour les développeurs)

Gamedev AI écrit le code de manière asynchrone. Cela signifie qu'il réécrit votre fichier et édite des dizaines d'instances pendant que vous lisez le journal dans le moteur.
Mais attendez, donner le contrôle d'écriture automatique à un bot sur votre disque dur ne détruit-il pas les racines auctoriales du développeur ?

Non ! *L'Écran de Diff sécurise votre travail et votre projet sans dommage accidentel.*

Le plugin Gamedev AI implémente la "Fênêtre Safe View Diff", comparable aux célèbres vues de versionnage (GitHub/GitLens) dans VSCode.

## Comment se produit le Diff
1. En demandant de créer ou de corriger un `EnemyAttack.gd`, le journal indique la progression de la réécriture des métadonnées de la classe...
2. Vous entendrez un "Ping" visuel et un **onglet Diff sombre** avec les mots [Original Code] à côté de [New Code Changes] émergera instantanément, envahissant l'écran de chat avec du texte.
3. Les lignes surlignées **[color=red]en Rouge -[/color]** représentent le code original dangereusement supprimé.
4. Les lignes surlignées **[color=green]en Vert +[/color]** représentent l'injection sans précédent de l'intelligence artificielle.

## Appliquer ou Ignorer (Le pouvoir du rejet)

À la fin du Diff (faites défiler la barre de défilement jusqu'à la fin ou analysez-le froidement), des boutons de sécurité décisifs apparaissent :
* **"Apply Changes" (Appliquer les changements) :** Gamedev AI utilisera le Proxy d'historique Annuler/Rétablir officiel de Godot Engine et modifiera le script cible réel. Si vous appuyez sur `Ctrl + Z` dans le script, vous reviendrez à l'état antérieur à l'intervention de l'IA.
* **"Skip" (Ignorer) :** Vous détestez l'idée de l'IA après avoir vu le Diff ? Appuyez sur "Skip". Aucune ligne ne sera modifiée (pas même en cache) et il n'y a pas de dommage technique, seuls les *tokens* ont été consommés.

> _(Visualisez en pratique comment fonctionne le Diff :)_

![Fenêtre de Diff montrant le code supprimé en rouge et ajouté en vert, avec les boutons Appliquer et Ignorer](../../images/diff_preview.png)
