# Toutes les outils IA (Tool Reference)

Gamedev AI dispose de **27 outils intégrés** que l'IA peut appeler de manière autonome lors d'une conversation. Ces outils sont le "bras mécanique" qui permet à l'IA d'interagir directement avec le moteur Godot, et chacun est décrit ci-dessous, regroupé par catégorie.

## 🔧 Scripts (Création et édition de code)

### `create_script`
Crée un nouveau fichier GDScript (`.gd`) au chemin spécifié avec le contenu fourni. L'IA utilise cet outil pour générer des scripts à partir de zéro.
- **Paramètres :** `path` (res://...), `content` (code GDScript complet)

### `edit_script`
Remplace l'intégralité du contenu d'un script existant par une nouvelle version. L'IA lira d'abord le fichier pour s'assurer qu'elle dispose de la dernière version.
- **Paramètres :** `path`, `content`
- ⚠️ *Obsolète au profit de `patch_script` pour les modifications chirurgicales.*

### `patch_script`
Modification chirurgicale : recherche un bloc de code exact dans le script et remplace uniquement cet extrait par le nouveau contenu. Idéal pour les petites corrections sans réécrire tout le fichier.
- **Paramètres :** `path`, `search_content` (bloc exact à trouver), `replace_content` (nouveau bloc)

### `replace_selection`
Remplace le texte actuellement sélectionné dans l'éditeur de script Godot. Fonctionne en conjonction avec les boutons d'action rapide (Refactoriser, Corriger, Expliquer).
- **Paramètres :** `text` (nouveau code pour remplacer la sélection)

### `view_file_outline`
Renvoie la structure d'un script sans le code complet : `class_name`, `extends`, fonctions, signaux, exports, enums, classes internes et constantes avec les numéros de ligne.
- **Paramètres :** `path`

---

## 🌳 Nœuds (Manipulation de l'Arbre de Scène)

### `add_node`
Ajoute un nouveau nœud à la scène ouverte dans l'éditeur. Peut créer n'importe quel type de nœud Godot (Node2D, CharacterBody3D, Label, Button, etc.).
- **Paramètres :** `parent_path` (utiliser `.` pour la racine), `type` (classe du nœud), `name`, `script_path` (facultatif)

### `remove_node`
Supprime un nœud de l'Arbre de Scène actuel. Nécessite une confirmation de l'utilisateur car il s'agit d'une action destructive.
- **Paramètres :** `node_path`

### `set_property`
Définit une propriété sur un nœud de scène (position, taille, texte, color, etc.). Accepte les nombres, les vecteurs, les couleurs et les chaînes de caractères.
- **Paramètres :** `node_path`, `property`, `value`

### `set_theme_override`
Définit une surcharge de thème sur un nœud de contrôle (taille de police, couleur de police, style).
- **Paramètres :** `node_path`, `override_type` (color/constant/font/font_size/stylebox), `name`, `value`

### `connect_signal`
Connecte le signal d'un nœud émetteur à la méthode d'un nœud récepteur dans la scène actuelle.
- **Paramètres :** `source_path`, `signal_name`, `target_path`, `method_name`, `binds` (facultatif), `flags` (facultatif)

### `disconnect_signal`
Déconnecte un signal précédemment connecté entre deux nœuds.
- **Paramètres :** `source_path`, `signal_name`, `target_path`, `method_name`

### `attach_script`
Attache un script GDScript existant à un nœud de la scène.
- **Paramètres :** `node_path`, `script_path`

### `analyze_node_children`
Renvoie un dump détaillé de la sous-arborescence d'un nœud spécifique dans la scène éditée. Utile pour explorer des hiérarchies profondes.
- **Paramètres :** `node_path`, `max_depth` (par défaut : 5)

---

## 📂 Fichiers et Projet

### `read_file`
Lit le contenu complet de n'importe quel fichier du projet.
- **Paramètres :** `path`

### `list_dir`
Répertorie le contenu d'un répertoire du projet.
- **Paramètres :** `path`

### `find_file`
Recherche un fichier du projet par son nom (correspondance partielle).
- **Paramètres :** `pattern`

### `remove_file`
Supprime un fichier ou un répertoire du projet. Nécessite une confirmation.
- **Paramètres :** `path`

### `move_files_batch`
Déplace ou renomme plusieurs fichiers/répertoires en une seule opération groupée. Met automatiquement à jour toutes les références internes de Godot (`.tscn`, `.tres`).
- **Paramètres :** `moves` (dictionnaire associant les anciens chemins aux nouveaux)

### `create_scene`
Crée un nouveau fichier de scène (`.tscn`) et l'ouvre dans l'éditeur.
- **Paramètres :** `path`, `root_type`, `root_name`

### `instance_scene`
Instancie une scène `.tscn` existante comme enfant d'un autre nœud dans la scène actuelle.
- **Paramètres :** `parent_path`, `scene_path`, `name`

### `create_resource`
Crée un nouveau fichier de ressource (`.tres`). Utile pour les actifs tels que les éléments, les statistiques ou les configurations personnalisées.
- **Paramètres :** `path`, `type`, `properties` (facultatif)

---

## 🔍 Recherche et Analyse

### `grep_search`
Recherche du texte à l'intérieur des fichiers du projet. Renvoie les lignes correspondantes avec le chemin et le numéro de ligne.
- **Paramètres :** `query`, `include` (filtre d'extension, facultatif), `max_results` (par défaut : 20)

### `search_in_files`
Recherche des motifs regex dans tous les fichiers `.gd` du projet pour trouver des utilisations de variables, de fonctions ou d'une logique spécifique.
- **Paramètres :** `pattern` (expression régulière)

### `get_class_info`
Renvoie des informations détaillées sur une classe Godot (moteur ou personnalisée) : classe de base, propriétés, méthodes et signaux.
- **Paramètres :** `class_name`

### `capture_editor_screenshot`
Prend une capture d'écran de toute la fenêtre de l'éditeur Godot et l'attache automatiquement au prochain prompt pour analyse visuelle.

---

## 🧠 Mémoire et connaissance

### `save_memory`
Enregistre un fait persistant dans la mémoire du projet qui sera disponible dans toutes les sessions de chat futures.
- **Paramètres :** `category` (architecture/convention/preference/bug_fix/project_info), `content`

### `list_memories`
Répertorie tous les faits persistants stockés pour ce projet.

### `delete_memory`
Supprime un fait mémoriel spécifique par son identifiant.
- **Paramètres :** `id`

### `read_skill`
Lit un fichier de documentation de compétence de la bibliothèque interne de l'IA pour apprendre les meilleures pratiques avant de programmer.
- **Paramètres :** `skill_name`

---

## 🗄️ Base de données vectorielle (RAG)

### `index_codebase`
Indexe l'intégralité du projet (`.gd`) dans une base de données vectorielle locale pour la recherche sémantique. Doit être exécuté avant d'utiliser `semantic_search`.

### `semantic_search`
Effectue une recherche vectorielle sémantique sur la base de code indexée pour trouver des extraits de code hautement pertinents basés sur le sens, et non sur une correspondance textuelle exacte.
- **Paramètres :** `query`

---

## 🧪 Tests

### `run_tests`
Exécute un script ou une commande de test. Utile pour vérifier les changements avec GUT, GdUnit4 ou des scripts de test personnalisés.
- **Paramètres :** `test_script_path` (facultatif)
