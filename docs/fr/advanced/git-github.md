# Onglet Git & GitHub (Automatisation des versions)

La création de jeux dans Godot génère souvent de la panique chez les débutants lorsqu'il s'agit de *Commiter* des dizaines de fichiers binaires obscurs (Scènes, Matériaux, Ressources). Faire un *Merge* dans le terminal est épuisant.

C'est pourquoi **Gamedev AI** implémente un onglet **Git** natif dans Godot, conçu exclusivement pour la fluidité.

## Comment utiliser l'onglet de versionnage

Dans la fenêtre droite du plugin, passez de l'onglet classique `Chat` ou `Settings` à l'onglet supérieur **Git**.
Là, vous verrez une version visuelle simplifiée et moderne du terminal :

![Interface de l'onglet Git avec boutons de commit, branches et opérations d'urgence](../../images/git_tab.png)

### 1. Initialiser & Connecter
Si le dossier n'est pas versionné, il y aura un bouton vert géant "Initialize Repository". Ensuite, le panneau vous demandera de coller l'**URL GitHub** du dépôt distant que vous avez créé sur le site GitHub.

### 2. Générer le message de commit ✨ (L'Or)
1. Vous venez de programmer, vous avez modifié 4 scènes complexes et refait des scripts (`.gd`).
2. Au lieu de réfléchir à un texte ennuyeux pour le Commit, cliquez sur **"✨ Auto-Generate Commit Message"**.
3. Gamedev AI fera un Diff invisible. L'intelligence artificielle examinera absolument tous les codes rouges supprimés et verts ajoutés que vous avez touchés (ex : *ajout de la logique de roulade au Player et correction du drag UI*) et créera un résumé écrit super poli pour vous.
4. Cliquez simplement sur **Commit & Sync (Push)**. L'IA télécharge tout sur le cloud instantanément !

### 3. Branches isolées (Lignes du temps)
Avez-vous peur de casser votre scène `Level_1.tscn` qui est parfaite aujourd'hui en essayant de tester un nouveau boss ?
Utilisez l'onglet latéral **Current Branch** et cliquez sur [Create/Switch]. Tapez `test_boss` et confirmez. Dès lors, vous êtes en sécurité dans une "copie isolée" du code.

### 4. Mode Panique (Annuler les erreurs)
Le panneau inférieur contient les Super Actions :
* **Undo Uncommitted Changes :** Le moteur Godot a explosé ? Appuyez sur ce bouton et tout revient à votre dernière version sauvegardée sur GitHub sur-le-champ. Un "Ctrl+Z" universel de tout le projet.
* **Force Pull Overwrite :** Écrase tout votre dossier local, le téléchargeant et le remplaçant exactement par l'état protégé dans votre cloud. Une bouée de sauvetage parfaite pour les programmeurs.
* **Force Push :** Écrase la version cloud par la version locale. À utiliser avec précaution !
