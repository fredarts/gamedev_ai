# Les 25 compétences intégrées (Catalogue complet)

Gamedev AI n'est pas une IA générique qui s'appuie uniquement sur une mémoire entraînée sur Internet. Elle dispose de **25 modules d'expertise** écrits spécifiquement pour Godot 4.6, qui sont automatiquement consultés lors des conversations pour s'assurer que le code généré suit les meilleures pratiques de l'industrie.

Ci-dessous, chacune des 25 compétences est détaillée avec son objectif et des exemples d'utilisation par l'IA.

---

## 📜 GDScript & Langage

### 1. `gdscript_style_guide`
**Guide de style GDScript.** Conventions de nommage (snake_case, PascalCase), organisation des fichiers, typage statique, ordre de déclaration et meilleures pratiques de formatage suivant le standard officiel de Godot.

### 2. `gdscript_modern_features`
**Fonctionnalités modernes de GDScript.** Lambdas, typage statique étendu, `await`, `super()`, enums typés, modèles `match` avancés et toutes les nouvelles fonctionnalités de GDScript 2.0+ qui ont remplacé la syntaxe héritée.

### 3. `gdscript_deprecated`
**Fonctions GDScript obsolètes.** Liste complète des fonctions, méthodes et modèles supprimés ou remplacés entre Godot 3 et Godot 4. L'IA consulte cette compétence pour ne jamais suggérer de code obsolète.

### 4. `gdscript_recipes_and_patterns`
**Recettes et modèles GDScript.** Solutions prêtes à l'emploi aux problèmes courants : singleton, object pooling, injection de dépendances, observateur et implémentations idiomatiques en GDScript.

### 5. `gdscript_signals_and_tweens`
**Signaux et Tweens.** Guide approfondi sur le système de signaux de Godot 4, `SceneTreeTween`, création d'animations procédurales, chaînage de tweens et meilleures pratiques de découplage avec les signaux.

---

## 🏗️ Architecture & Structure

### 6. `common_architectures`
**Architectures de jeu courantes.** Modèles architecturaux tels que Entité-Composant, MVC pour les jeux, Service Locator, Event Bus et comment structurer des projets Godot à moyenne/grande échelle.

### 7. `project_structure_guidelines`
**Directives de structure de projet.** Organisation idéale des dossiers (`src/`, `assets/`, `ui/`, `autoloads/`), conventions de nommage des fichiers, autoloads vs injection de dépendances, et quand utiliser chaque approche.

### 8. `state_machine_implementation`
**Implémentation de machine à états.** Modèle de machine à états avec des nœuds enfants, transitions propres, états hiérarchiques et intégration avec AnimationTree pour les personnages complexes.

---

## 🎮 Systèmes de Jeu

### 9. `inventory_and_item_systems`
**Systèmes d'inventaire et d'objets.** Architecture d'inventaire basée sur les Ressources, emplacements (slots), empilage, glisser-déposer d'objets, sérialisation pour les sauvegardes de jeu et interface d'inventaire réactive.

### 10. `quest_and_dialogue_systems`
**Systèmes de quêtes et de dialogues.** Implémentation d'arbres de dialogue, système de quêtes avec états (actif/terminé/échoué), PNJ, conditions de progression et intégration de l'interface utilisateur.

### 11. `save_system_and_persistence`
**Système de sauvegarde et persistance.** Sérialisation complète de l'état du jeu en JSON/binaire, sauvegarde automatique, emplacements multiples, versionnage des sauvegardes et migration entre versions.

### 12. `data_management_and_crafting`
**Gestion des données et artisanat.** Systèmes d'artisanat avec des recettes basées sur les Ressources, bases de données d'objets, tables de butin (loot tables) et équilibrage de l'économie du jeu.

---

## 🕹️ Mécaniques & Physique

### 13. `physics_and_collision_handling`
**Physique et collisions.** Configuration des calques/masques (layer/mask), CharacterBody2D/3D, RigidBody, raycasting, zones de détection et résolution des problèmes de physique courants.

### 14. `input_handling_and_remapping`
**Gestion des entrées et remappage.** InputMap, actions personnalisées, prise en charge des manettes/claviers/tactile, remappage au moment de l'exécution, mise en mémoire tampon des entrées et zones mortes.

### 15. `ai_and_pathfinding`
**IA et Pathfinding.** NavigationServer2D/3D, NavigationAgent, évitement, arbres de comportement simplifiés, poursuite, patrouille et IA ennemie basée sur les états.

---

## 🎨 Visuels & Audio

### 16. `shaders_and_vfx`
**Shaders et VFX.** Shaders Godot Shading Language, effets de dissolution, contour (outline), distorsion, particules GPU, traînées (trails) et techniques VFX pour les jeux 2D et 3D.

### 17. `post_processing_and_environment`
**Post-traitement et environnement.** WorldEnvironment, glow, brouillard, SSAO, SSR, tonemap, correction des couleurs et configuration d'environnement cinématique.

### 18. `animation_and_cutscenes`
**Animation et cinématiques.** AnimationPlayer, AnimationTree, espaces de mélange (blend spaces), machines à états d'animation, cinématiques AnimationPlayer et transitions fluides.

### 19. `audio_management_best_practices`
**Gestion de l'audio.** AudioBus, AudioStreamPlayer2D/3D, pooling d'effets sonores, musique adaptative, fondu enchaîné (crossfade), mixage et organisation du système audio.

---

## 🖥️ Interface & Plateforme

### 20. `ui_ux_patterns`
**Modèles UI/UX.** Menus réactifs, HUD, thèmes globaux, navigation au gamepad, transitions d'écran, pop-ups et meilleures pratiques UI dans Godot.

### 21. `mobile_and_resolution_scaling`
**Mobiles et mise à l'échelle de la résolution.** Configuration du mode d'étirement (stretch mode), rapport d'aspect (aspect ratio), entrée tactile, joystick virtuel, optimisations mobiles et tests multi-résolutions.

### 22. `localization_and_i18n`
**Localisation et i18n.** Système de traduction avec `.csv`/`.po`, TranslationServer, changement de langue au moment de l'exécution, formatage des nombres/dates et prise en charge du RTL (Right-to-Left).

---

## 🌐 Multijoueur & Performance

### 23. `multiplayer_and_networking_api`
**Multijoueur et réseau.** ENet, WebSocket, MultiplayerSpawner/Synchronizer, RPCs, autorité, architecture client-serveur, systèmes de lobby et synchronisation d'état.

### 24. `performance_optimization`
**Optimisation des performances.** Profilage (profiling), pooling d'objets, LOD, culling, rendu par lots (batch rendering), optimisation GDScript, réduction des appels de dessin (draw calls) et techniques pour les jeux à 60 Hz.

### 25. `level_generation_and_pcg`
**Génération de niveaux et PCG.** Génération procédurale de donjons, wave function collapse, terrain basé sur le bruit, TileMap automatique et graines aléatoires reproductibles.

---

## 🛠️ Créer vos propres compétences

Le système de compétences est **extensible** ! Vous pouvez créer vos propres fichiers `.md` dans le dossier `addons/gamedev_ai/skills/` pour enseigner à l'IA les règles spécifiques de votre projet.

**Exemple :** Créez un fichier nommé `mon_style_artistique.md` avec :
```markdown
# Règles artistiques de notre studio

- Tous les sprites doivent avoir une résolution de 16x16 ou 32x32 pixels.
- Utilisez une palette de couleurs limitée (max 32 couleurs).
- Les animations de personnages doivent comporter au moins 4 images.
- Nommez les sprites comme ceci : type_nom_action_image.png
```

L'IA suivra ces règles chaque fois qu'elle créera ou modifiera des actifs visuels dans votre projet.
