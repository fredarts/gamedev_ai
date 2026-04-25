# Configuration (Obtenir une clé API)

Gamedev AI ne dispose pas d'un backend propriétaire pour voler vos données. Il effectue des appels directs (interchangeables) aux serveurs LLM que vous préférez utiliser. Toutes les connaissances indexées sont sauvegardées localement sur votre machine pour plus de sécurité !

Pour que le plugin puisse parler et répondre à votre code, nous devons fournir une **Clé API**.

## Utilisation des outils Google (Gemini) - Gratuit
La méthode la plus populaire, incroyablement intelligente et **gratuite** d'utiliser le plugin aujourd'hui consiste à utiliser Google AI Studio avec Gemini 2.5 Pro ou Gemini 2.5 Flash. Gemini 3.0 et 3.1 Pro sont payants.

1. Accédez à [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Connectez-vous avec votre compte Google (aucune carte de crédit n'est requise pour le niveau gratuit).
3. Cliquez sur **"Get API key"** ou **"Create API key"**.
4. Copiez la longue clé générée `(exemple : AIzaSyD......)`.

## Connexion de la clé dans l'Éditeur

1. Cliquez sur l'onglet supérieur caché nommé **"Settings"** à l'intérieur du panneau Gamedev AI dans Godot.
2. Assurez-vous que le fournisseur (Provider) sélectionné dans le menu déroulant est **"Gemini"**.
3. Dans le champ de texte **API Key**, collez votre clé complète, en vous assurant qu'il n'y a pas d'espaces supplémentaires.
4. Saisissez votre modèle préféré dans le champ *Model Name* (la valeur par défaut est généralement `gemini-2.5-pro` ou `gemini-2.5-flash`).

<br>

> **💡 Conseil en or !** 
>
> ![Onglet des paramètres montrant les champs Preset, Provider et API Key](../../images/settings_ui.png)

## Utilisation d'OpenRouter ou d'OpenAI

Préférence pour GPT-5.4, Claude Opus 4.6, Qwen3 Coder.
Gamedev AI prend en charge l'écosystème OpenAI/OpenRouter sans changer une seule ligne de code :
1. Retournez dans l'onglet **Settings**.
2. Changez le fournisseur dans le menu déroulant de `Gemini` à `OpenAI / OpenRouter`.
3. Ajoutez votre clé OpenAI ou OpenRouter.
4. Dans le champ supplémentaire nommé `Base URL`, saisissez :
   * Pour OpenAI : `https://api.openai.com/v1`
   * Pour OpenRouter : `https://openrouter.ai/api/v1`
5. Changez le nom du modèle (par exemple, `gpt-5.4` ou `anthropic/claude-opus-4.6`).

## Utilisation de Modèles Locaux (Ollama / LM Studio)

Préférez-vous exécuter des modèles d'IA directement sur votre machine, sans dépendre d'API externes ?
Gamedev AI prend en charge n'importe quel serveur compatible avec l'API OpenAI exécuté localement :

1. Installez [Ollama](https://ollama.ai) et téléchargez un modèle : `ollama pull llama3.1`
2. Assurez-vous qu'Ollama est en cours d'exécution (`ollama serve`).
3. Dans l'onglet **Settings**, changez le fournisseur pour **`Local (Ollama / LM Studio)`**.
4. Le champ **Base URL** sera automatiquement renseigné avec `http://localhost:11434/v1`.
5. Saisissez le nom du modèle dans le champ **Model Name** (ex : `llama3.1`, `gemma3`, `qwen3`).
6. Le champ API Key sera automatiquement désactivé (les modèles locaux n'en ont pas besoin).

> **⚠️ Note :** La qualité des réponses dépend du modèle local choisi et de vos ressources matérielles disponibles.

Nous sommes prêts à chatter !

[**Étape suivante : Dites "Salut" à l'IA** ➔](./quick-start.md)
