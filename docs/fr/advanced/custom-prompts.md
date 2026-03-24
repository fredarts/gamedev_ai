# Prompt système personnalisé

Parfois, les projets de studio comportent des contraintes strictes, et nous ne voulons pas que l'IA prenne des décisions génériques pour tout le code créé. Comment façonner le comportement "mental" par défaut de Gamedev AI ?

## Le panneau "Instructions personnalisées"

Dans l'onglet caché **Settings**, sous le champ du fournisseur de "API Key".
Il y a la grande boîte libre **Custom Instructions (appended to system prompt)**.

![Panneau des paramètres montrant la zone d'instructions personnalisées](../../images/settings_ui.png)

Chaque fois que l'IA "réfléchit", les instructions qui y sont placées seront lues comme la règle numéro 1 universelle avant qu'elle ne vous réponde.

### Exemples de ce qu'il faut coller dans cette boîte :
* *"Veuillez ne pas écrire de longues explications ou de salutations, montrez simplement la fenêtre Diff ciblée"*
* *"L'ensemble du projet Godot de ce studio utilise la convention Clean Code. Les méthodes doivent commencer par des lettres minuscules anglaises et les nœuds de scène par du PascalCase. Utilise strictement le typage statique (: String, : int, -> void) dans toutes les fonctions créées."*
* *"J'interdis l'utilisation des balises _process(). Je veux que tu te concentres sur une architecture utilisant intensément les signaux pour la performance."*

Grâce à cela, Gamedev AI devient un développeur spécifiquement modelé par le CTO (Vous) et créera du code de la manière approuvée par votre équipe plutôt que selon la syntaxe libre conventionnelle des LLM.
