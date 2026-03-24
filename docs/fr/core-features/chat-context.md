# Chat, Pièces Jointes et Contexte (Les poumons du plugin)

Le Chat est plus qu'un simple chat ChatGPT intégré dans la fenêtre droite de votre éditeur. C'est le véritable "système respiratoire" entre vos **fichiers de jeu** et l'**esprit de l'IA**.

## L'importance du "Context" (Lire votre code actuel)

L'intelligence artificielle ne peut pas voir votre écran et ne sait pas ce que vous programmez actuellement — *Sauf si vous lui demandez de regarder !*

Sous la barre *"Envoyer"*, vous verrez une case à cocher importante nommée **Context**.
1. **Cochée (Par défaut) :** Gamedev AI copiera secrètement chaque ligne et caractère du fichier (`.gd`) où se trouve le curseur dans votre fenêtre de script à ce moment-là. Il sera envoyé en même temps que la question que vous posez !
2. **Décochée :** Économise vos "Tokens" de contexte limité sur les modèles payants (OpenAI), effectuant une question rapide sans voir votre code, comme ChatGPT générique. Utilisez-le lorsque vous avez un problème isolé qui ne nécessite pas le contexte du moteur.

## 📸 Capture d'écran (Instantané automatique)

À côté de l'interrupteur Context, il y a un interrupteur **Screenshot**. Cette fonctionnalité permet à l'IA de "voir" littéralement ce qui se trouve sur votre écran Godot.

### Comment ça fonctionne
1. **Activez l'interrupteur "Screenshot"** dans la barre inférieure du Chat.
2. Le prochain message que vous enverrez sera accompagné d'une **capture d'écran automatique** de toute la fenêtre de l'éditeur Godot.
3. L'IA recevra l'image complète et pourra analyser visuellement : la scène 2D/3D ouverte, l'Arbre de Scène (Scene Tree), l'Inspecteur, la Sortie (Output) et tout autre panneau visible.

### Quand l'utiliser
- **UI cassée :** Votre interface de jeu est mal alignée mais vous ne savez pas quel Label ou Container est en cause ? Activez la capture, envoyez "Quel est le problème avec cette mise en page ?" et l'IA analysera visuellement les nœuds.
- **Arbre de Scène complexe :** Vous voulez que l'IA comprenne comment la hiérarchie des nœuds est organisée sans avoir à les décrire manuellement.

::: tip Conseil
L'IA dispose également de l'outil `capture_editor_screenshot` qu'elle peut appeler elle-même à tout moment au cours d'une conversation si elle a besoin de "regarder" l'éditeur de son propre chef.
:::

## Bouton Plan First (Planifier d'abord)

Il est très fréquent de commettre des erreurs en demandant immédiatement à l'IA de créer toute la logique d'un RPG massif. Le plugin vous permet de freiner l'impulsivité robotique en activant **Plan First**.

![Interrupteur Plan First actif avec le bouton Execute Plan visible](../../images/plan_first.png)

* **Activé :** Le plugin enverra une directive stricte. *L'IA ne créera pas de code*. Elle répondra exclusivement par une liste Markdown numérotée énumérant les éléments du projet (Classes, Noms et Fonctions de base) à modifier.
* Après avoir examiné et approuvé le plan, cliquez sur le bouton **"Execute Plan"** qui apparaîtra automatiquement. L'IA commencera alors à implémenter tout ce qu'elle a planifié.

## Pièces jointes et Nœuds glissables

Besoin d'analyser comment un Sprite2D est fabriqué, ou pourquoi la scène `Player.tscn` n'entre pas en collision avec le RigidBody3D `Ground` ?

Le plugin Gamedev AI prend en charge le glisser-déposer (Drag & Drop). Vous n'avez pas à perdre de temps à ouvrir chaque onglet de l'Inspecteur qui a suscité de la curiosité ou une défaillance visuelle...

![Fichiers joints par glisser-déposer dans le champ de chat](../../images/drag_and_drop.png)

1. **Arbre de Scène (Scene Tree) :** Cliquez sur un nœud dans la scène et faites-le glisser vers la barre de texte. L'IA utilisera le raccourci pour analyser toutes les métadonnées du nœud (positions cachées, instanciations, tags de collisionneur...) et comprendre pourquoi les vecteurs de friction ne semblent pas fonctionner.
2. **Bouton 📎 Joindre :** Utilisez-le pour insérer des images (`.png` d'interface buggée), des fichiers de sauvegarde bruts (`.json`) et des captures globales de scripts longs (bien que l'indexation vectorielle soit la méthode la plus professionnelle).

---

## 🎙️ Lecture à voix haute (TTS - Text-to-Speech)

Gamedev AI dispose d'un lecteur de **narration vocale** intégré qui convertit les réponses de l'IA en audio. Cela vous permet d'écouter les explications tout en continuant à programmer sans vous arrêter pour lire des murs de texte.

![Lecteur TTS compact avec bouton de lecture et contrôle de vitesse](../../images/tts_player.png)

### Comment l'utiliser
1. Une fois que l'IA a répondu à une question dans le chat, cliquez sur le bouton **"▶ Lire à voix haute"** (situé juste en dessous de la zone de chat).
2. Le plugin enverra une demande de conversion du texte de la dernière réponse en audio.
3. Un lecteur audio compact apparaîtra avec toutes les commandes :

| Commande | Fonction |
|----------|--------|
| **▶ Lire à voix haute** | Démarre la lecture de la narration. |
| **⏹ (Arrêter)** | Arrête la lecture immédiatement. |
| **Barre de progression** | Vous permet d'avancer ou de reculer dans la narration en faisant glisser le curseur. |
| **Vitesse (1.0x à 2.0x)** | Contrôle la vitesse de la narration. Utilisez 1.5x ou 2.0x pour écouter plus rapidement. |

### Quand c'est utile
- **Réponses longues :** L'IA a-t-elle expliqué 3 paragraphes sur le fonctionnement de `NavigationAgent3D` ? Écoutez-la tout en ajustant les nœuds dans l'Arbre de Scène.
- **Accessibilité :** Pour les développeurs qui préfèrent apprendre par l'écoute ou qui ont des difficultés avec la lecture prolongée sur écran.
- **Révision passive :** Laissez l'IA narrer le plan de refactorisation pendant que vous allez prendre un café !

::: info Note
La fonction TTS utilise l'API du fournisseur configuré pour synthétiser l'audio. Le flux est mis en cache, donc mettre en pause et reprendre ne génère aucun coût supplémentaire en tokens.
:::

---

## ⚡ Boutons d'action rapide

Dans la barre située juste en dessous de la zone de chat (et au-dessus du champ de texte), se trouvent **5 boutons d'action rapide** qui agissent comme des raccourcis intelligents. Ils envoient automatiquement un prompt préconfiguré ainsi que le code que vous avez sélectionné dans l'éditeur de script Godot.

### Comment ils fonctionnent
1. **Ouvrez n'importe quel script** (`.gd`) dans l'éditeur de code Godot.
2. **Sélectionnez un morceau de code** avec votre souris ou votre clavier (par exemple, une fonction entière, un bloc `if` ou quelques lignes).
3. **Cliquez sur l'un des boutons** ci-dessous :

### Les 5 Boutons

| Bouton | Prompt envoyé | Ce que fait l'IA |
|-------|---------------|----------------|
| **✧ Refactoriser** | "Refactor this code" | Analyse l'extrait sélectionné et propose une version plus propre et plus efficace avec de meilleures pratiques GDScript. |
| **◆ Corriger** | "Fix errors in this code" | Identifie les bogues, les erreurs de syntaxe, les types incorrects ou la logique défaillante dans l'extrait et génère un correctif en Diff. |
| **💡 Expliquer** | "Explain what this code does" | Explique ligne par ligne ce que fait l'extrait en langage naturel, parfait pour apprendre ou documenter. |
| **↺ Annuler** | *(Action directe)* | Annule la dernière modification effectuée par l'IA dans le projet à l'aide du système natif Annuler/Rétablir de Godot. Pas de prompt. |
| **🖥 Corriger Console** | *(Lit la Sortie)* | Lit les dernières erreurs rouges de la console de Sortie Godot et les envoie directement à l'IA pour diagnostic et proposition de correctif. |

### Exemple avec "Corriger Console"
1. Vous lancez le jeu via Godot (`F5`).
2. Le jeu plante et une erreur rouge apparaît : `Attempt to call function 'die' in base 'null instance'`.
3. Sans rien copier, cliquez sur **🖥 Corriger Console**.
4. L'IA lira elle-même le journal de Sortie, trouvera le script problématique et suggérera le correctif dans un Diff sécurisé.

::: tip Conseil
Le bouton **"Corriger Console"** est différent du **"Watch Mode"**. La console nécessite un clic manuel, tandis que le mode Watch fonctionne automatiquement en arrière-plan une fois activé.
:::
