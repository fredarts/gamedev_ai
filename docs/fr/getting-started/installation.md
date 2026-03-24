# Installation

Bienvenue dans la documentation officielle de **Gamedev AI** ! Cette page se concentre sur la manière d'ajouter rapidement l'assistant à votre projet Godot 4.6 actuel.

## Prérequis
* **Godot Engine :** Version 4.6 ou supérieure (le support natif `.gdextension` n'est pas requis, le plugin fonctionne en pur GDScript).
* Compte Google ou OpenRouter pour les clés API.

## Étape par Étape Manuel (GitHub)

1. Créez ou ouvrez un projet existant dans Godot 4.6.
2. Naviguez vers le dossier racine de votre projet (là où se trouve le fichier `project.godot`).
3. Créez un dossier `addons` (s'il n'existe pas déjà).
4. À l'intérieur de `addons/`, téléchargez ou clonez le dépôt du plugin :
```bash
git clone git@github.com:fredarts/gamedev_ai.git
```
*(Ou téléchargez le fichier `.zip` depuis l'onglet Releases sur GitHub et extrayez-le dans `res://addons/gamedev_ai`).*

## Activation dans l'Éditeur

Une fois les fichiers en place :
1. Ouvrez l'éditeur de votre projet Godot.
2. Allez dans le menu `Projet` en haut et choisissez `Paramètres du projet`.
3. Naviguez vers l'onglet `Plugins` en haut.
4. Trouvez **Gamedev AI** dans la liste des plugins installés.
5. Cochez la case `Activer`.

C'est tout ! Lorsque vous l'activez pour la première fois, vous verrez le panneau de Chat Gamedev AI apparaître dans le *Dock* droit de votre éditeur.

[**Étape suivante : Configurer votre clé API** ➔](./configuration.md)
