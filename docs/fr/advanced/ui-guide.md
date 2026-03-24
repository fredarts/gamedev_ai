# Guide complet de l'interface utilisateur (Tous les boutons)

Cette page décrit **chaque bouton, interrupteur et commande** présent dans l'interface de Gamedev AI au sein de l'éditeur Godot.

![Vue d'ensemble de l'interface principale de Gamedev AI dans Godot](../../images/main_interface.png)

## 🗂️ Onglets principaux

Le plugin dispose de **3 onglets** en haut du panneau :
- **Chat** — Le panneau de conversation principal avec l'IA.
- **Settings** (Paramètres) — Gestion des clés API, préréglages, prompts et indexation.
- **Git** — Contrôle de version intégré avec GitHub.

---

## 💬 Onglet Chat

### Barre supérieure
| Bouton | Fonction |
|-------|--------|
| **Sélecteur de Preset** | Menu déroulant pour changer rapidement de configuration fournisseur/modèle (ex: "Gemini 3.1", "GPT-4o"). |
| **A-** / **A+** | Diminue ou augmente la taille de la police du chat. |
| **+ New Chat** | Efface la conversation actuelle et démarre une session complètement nouvelle. |
| **⊙ History** | Menu déroulant listant toutes les conversations passées. Cliquez sur l'une d'elles pour restaurer le contexte complet de cette session. |
| **💾 Summarize to Memory** | Envoie un prompt automatique demandant à l'IA de résumer les décisions architecturales de la conversation actuelle et de les sauvegarder dans la mémoire persistante du projet. |

### Zone de Chat (OutputDisplay)
- Affiche les messages formatés en BBCode supportant le **gras**, l'*italique*, le `code en ligne` et les blocs de code avec coloration syntaxique.
- Liens cliquables vers les fichiers du projet (cliquez pour ouvrir dans l'éditeur).
- Un bouton flottant **Copier** apparaît lors de la sélection de texte pour le copier rapidement.

### Lecteur TTS (Text-to-Speech)

![Lecteur TTS compact avec commandes de lecture](../../images/tts_player.png)

| Commande | Fonction |
|----------|--------|
| **▶ Lire à voix haute** | Convertit la dernière réponse de l'IA en audio et la lance. Utile pour écouter des explications tout en programmant. |
| **⏹ Arrêter** | Arrête la lecture audio. |
| **Barre de progression** | Pour reculer ou avancer dans l'audio. |
| **Vitesse (1.0x - 2.0x)** | Contrôle la vitesse de lecture. |

### Boutons d'action rapide
| Bouton | Action |
|-------|-----------|
| **✧ Refactoriser** | Envoie le code sélectionné dans l'éditeur avec le prompt "Refactoriser ce code". L'IA propose des améliorations structurelles. |
| **◆ Corriger** | Envoie le code sélectionné avec "Corriger les erreurs dans ce code". L'IA identifie les bugs et génère des correctifs. |
| **💡 Expliquer** | Envoie le code sélectionné avec "Expliquer ce que fait ce code". L'IA explique chaque partie en français. |
| **↺ Annuler** | Annule la dernière action exécutée par l'IA dans le projet (en utilisant le système Annuler/Rétablir de Godot). |
| **🖥 Corriger Console** | Lit les dernières erreurs rouges de la console de Sortie de Godot et les envoie directement à l'IA pour analyse et proposition de correctifs. |

### Zone de saisie
| Élément | Fonction |
|----------|--------|
| **Champ de texte** | Saisissez votre message. Utilisez `Shift + Enter` pour envoyer. |
| **📎 Joindre** | Ouvre un sélecteur de fichiers pour joindre des images, des scripts ou tout autre fichier au prompt. |
| **➤ Envoyer** | Envoie le message à l'IA pour traitement. |
| **Drag & Drop** | Faites glisser des nœuds de l'Arbre de Scène ou des fichiers du FileSystem directement dans le champ de texte ou la zone de chat. L'IA recevra toutes les métadonnées. |

### Interrupteurs inférieurs
| Interrupteur | Fonction |
|--------|--------|
| **Context** | Une fois activé, le plugin ajoute automatiquement le contenu complet du script ouvert dans l'éditeur au message envoyé. |
| **Screenshot** | Une fois activé, il prend automatiquement une capture d'écran de la fenêtre Godot et l'envoie avec le message pour analyse visuelle par l'IA. |
| **Plan First** | Une fois activé, l'IA n'écrira pas de code. Elle répondra par un plan Markdown détaillé. Après examen, cliquez sur le bouton "Execute Plan" qui apparaît. |
| **Watch Mode** | Une fois activé, l'IA surveille la console de Sortie. Si elle détecte des erreurs critiques (rouges), elle propose automatiquement des correctifs. Cooldown de 30s, limite de 3 correctifs par cycle. |

---

## ⚙️ Onglet Settings (Paramètres)

### Gestion des Presets
| Élément | Fonction |
|----------|--------|
| **Sélecteur de Preset** | Menu déroulant pour choisir parmi les préréglages sauvegardés. |
| **Add** | Crée un nouveau preset vide. |
| **Edit** | Ouvre le panneau d'édition (Nom, Fournisseur, Clé API, URL de base, Modèle). |
| **Delete** | Supprime définitivement le preset sélectionné. |
| **Done Editing** | Ferme le panneau d'édition en enregistrant les modifications. |

### Champs d'édition des Presets
| Champ | Description |
|-------|-----------|
| **Nom du Preset** | Nom convivial (ex: "Gemini 3.1 Gratuit"). |
| **Fournisseur** | Choix entre "Gemini" et "OpenAI / OpenRouter". |
| **Clé API** | Votre clé API du fournisseur sélectionné. |
| **URL de base** | URL de base de l'API (uniquement pour OpenAI/OpenRouter). |
| **Nom du modèle** | Nom exact du modèle (ex: `gemini-2.5-flash`, `gpt-4o`). |

### Langue
| Élément | Fonction |
|----------|--------|
| **Sélecteur de langue** | Menu déroulant pour choisir la langue de l'interface et de l'IA (Français, Português BR, English, etc.). |

### Prompt de système personnalisé
Une grande boîte de texte pour insérer des règles fixes que l'IA suivra toujours. Exemple : *"Utilise le typage statique sur toutes les fonctions. Commente en français."*

| Bouton | Fonction |
|-------|--------|
| **✨ Améliorer les instructions avec l'IA** | Envoie vos instructions actuelles pour que l'IA les améliore automatiquement. Aperçu affiché avant acceptation. |

### Base de données vectorielle
| Élément | Fonction |
|----------|--------|
| **Liste des fichiers** | Liste visuelle des fichiers `.gd` avec statut d'indexation. |
| **🔍 Scan Changes** | Analyse le projet à la recherche de fichiers nouveaux, modifiés ou supprimés. |
| **⚡ Index Codebase** | Lance le processus d'indexation vectorielle des scripts modifiés. |

---

## 🐙 Onglet Git

### Configuration initiale
| Élément | Fonction |
|----------|--------|
| **Initialize Repository** | Initialise un dépôt Git dans le dossier du projet. |
| **URL distante** | Champ pour coller l'URL du dépôt GitHub (ex: `https://github.com/utilisateur/repo.git`). |
| **Définir la destination** | Définit l'URL du dépôt distant. |

### Opérations principales
| Bouton | Fonction |
|-------|--------|
| **🔃 Refresh Status** | Actualise le statut Git (fichiers modifiés, non suivis, branche actuelle). |
| **⬇️ Pull** | Télécharge les derniers changements depuis le dépôt distant. |
| **✨ Générer automatiquement le message de commit** | L'IA analyse les modifications (diff) et génère un message de commit professionnel. |
| **Commit & Sync (Push)** | Valide les changements avec le message généré et les pousse sur GitHub. |

### Branches
| Élément | Fonction |
|----------|--------|
| **Label de branche** | Affiche le nom de la branche actuelle. |
| **Saisie du nom de branche** | Champ pour saisir le nom d'une nouvelle branche ou d'une branche existante. |
| **Checkout/Create Branch** | Crée une nouvelle branche ou bascule vers une existante. |

### Actions d'urgence
| Bouton | Fonction |
|-------|--------|
| **⚠️ Annuler les changements non validés** | Supprime TOUTES les modifications locales non commitées. |
| **⚠️ Écraser par un Force Pull** | Remplace complètement le dossier local par l'état du dépôt distant. |
| **⚠️ Force Push** | Pousse l'état local sur le dépôt distant en écrasant l'historique. |

---

## 📋 Panneau de Diff (Révision de code)

Lorsque l'IA génère ou modifie du code, un panneau de Diff apparaît dans le chat :

![Panneau de Diff montrant le code supprimé (rouge) et ajouté (vert)](../../images/diff_preview.png)

| Élément | Fonction |
|----------|--------|
| **Vue Diff** | Vue côte à côte montrant les lignes supprimées (rouge) et ajoutées (vert). |
| **Appliquer les changements** | Accepte les modifications et les applique au fichier réel. |
| **Ignorer (Skip)** | Rejette les modifications. Aucun fichier n'est altéré. |
