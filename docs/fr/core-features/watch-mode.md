# Mode Watch (La magie de l'auto-débogage)

En tant que gamedev, vous passez **30 % de votre temps à développer des logiques de jeu fantastiques** et un pénible **70 % à déchiffrer des erreurs rouges sémantiques et des exceptions de référence nulle** dans l'onglet `Debugger / Output` de Godot.

La fonctionnalité **Watch Mode** de Gamedev AI élimine cette terrifiante deuxième phase de débogage manuel. Elle transforme le bot en un ingénieur QA invisible travaillant dans la pièce d'à côté.

## Pourquoi l'activer ? Et comment l'activer ?
Au bas de votre panneau de Chat, activez l'interrupteur nommé **[x] Watch Mode**.

Ce qui se passe en coulisses :
1. Vous appuyez sur `F5` (Lancer la scène / Déboguer le projet) dans Godot.
2. Votre joueur entre en collision avec un `Area2D` où vous avez oublié l'initialisation de `NodeGroup`. Le moteur plante et affiche un texte rouge mortel dans la Sortie ("Attempt to call function 'die' in base 'null instance'").
3. Sans que vous ayez à cliquer ou à copier du texte, Gamedev AI _se réveille_, lit le journal des erreurs de syntaxe dans les 50 derniers blocs de la console, rassemble les fichiers suspects indexés, rédige l'hypothèse de la défaillance de référence et renvoie instantanément une **solution de réécriture Diff**, ou explique étape par étape où se trouve le nœud problématique.

## Limites de "tolérance" et Cooldown

Les assistants trop actifs brûlent les comptes des modèles payants en envoyant des "Orphan Warnings" répétitifs de Godot Engine (des avertissements jaunes insignifiants qui n'ont rien cassé en réalité).

Pour gérer votre portefeuille et le flux, Gamedev AI limite la surveillance avec des **Cool-downs dynamiques** :
* Il se déclenche au plus tard lors des **trois** premières vagues de sortie critiques signalées par le journal dans des fractions de 30 secondes, ou parfois, il attend longuement en `standby`.

*Prendre soin du moteur est devenu presque un jeu d'enfant en lisant des conseils autonomes.*
