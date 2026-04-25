# Configuration (Obtenir une clé API)

Gamedev AI ne dispose pas d'un backend propriétaire pour voler vos données. Il effectue des appels directs (interchangeables) aux serveurs LLM que vous préférez utiliser. Toutes les connaissances indexées sont sauvegardées localement sur votre machine pour plus de sécurité !

Pour que le plugin puisse parler et répondre à votre code, nous devons fournir une **Clé API**.

## Utilisation des outils Google (Gemini) - Gratuit
La méthode la plus populaire, incroyablement intelligente et **gratuite** d'utiliser le plugin aujourd'hui consiste à utiliser Google AI Studio avec Gemini 3.1 Pro ou Gemini 3.1 Flash. Gemini 4.0 est actuellement en version bêta.

1. Accédez à [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Connectez-vous avec votre compte Google (aucune carte de crédit n'est requise pour le niveau gratuit).
3. Cliquez sur **"Get API key"** ou **"Create API key"**.
4. Copiez la longue clé générée `(exemple : AIzaSyD......)`.

## Connexion de la clé dans l'Éditeur

1. Cliquez sur l'onglet supérieur caché nommé **"Settings"** à l'intérieur du panneau Gamedev AI dans Godot.
2. Assurez-vous que le fournisseur (Provider) sélectionné dans le menu déroulant est **"Gemini"**.
3. Dans le champ de texte **API Key**, collez votre clé complète, en vous assurant qu'il n'y a pas d'espaces supplémentaires.
4. Saisissez votre modèle préféré dans le champ *Model Name* (la valeur par défaut est généralement `gemini-3.1-pro` ou `gemini-3.1-flash`).

<br>

> **💡 Conseil en or !** 
>
> ![Onglet des paramètres montrant les champs Preset, Provider et API Key](../../images/settings_ui.png)

## Utilisation d'OpenRouter ou d'OpenAI

Si vous préférez accéder à des modèles comme Claude Opus 4.7, GPT-5.5 ou d'autres modèles ouverts de pointe, Gamedev AI prend en charge les API compatibles nativement.

1. Inscrivez-vous et obtenez votre clé API sur :
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. Retournez dans l'onglet caché **Settings** à l'intérieur de Godot.
3. Changez le fournisseur dans le menu déroulant de `Gemini` à `OpenAI / OpenRouter`.
4. Collez votre **API Key**.
5. Dans le champ supplémentaire nommé **Base URL**, saisissez **exactement** l'adresse correspondante :
   * **OpenRouter :** `https://openrouter.ai/api/v1`
   * **OpenAI :** `https://api.openai.com/v1`
6. Changez le champ **Model Name** par l'identifiant du modèle (par exemple, `anthropic/claude-opus-4.7` ou `gpt-5.5`).

## Utilisation de NVIDIA NIM (DeepSeek gratuit et autres)

La plateforme NVIDIA NIM offre un accès rapide et souvent gratuit à plusieurs modèles de pointe, comme les séries **DeepSeek** et **Llama**, via une API compatible avec le standard OpenAI.

1. Accédez au [catalogue d'API NVIDIA](https://build.nvidia.com/) et créez un compte pour obtenir votre clé API.
2. Dans l'onglet **Settings** du plugin, sélectionnez le fournisseur **`OpenAI / OpenRouter`**.
3. Collez votre **API Key** générée par NVIDIA.
4. Dans le champ **Base URL**, vous devez saisir l'URL exacte de NVIDIA NIM :
   * `https://integrate.api.nvidia.com/v1`
5. Dans le champ **Model Name**, saisissez le nom du modèle souhaité.

> **⚠️ Avertissement : Le nom du modèle chez NVIDIA**
> Chez NVIDIA NIM, vous êtes **tenu** d'inclure le "préfixe de l'organisation" avant le nom du modèle.
> Exemple : Pour DeepSeek, vous ne devez pas utiliser simplement `deepseek-v4-pro`, mais plutôt **`deepseek-ai/deepseek-v4-pro`** (ou `deepseek-ai/deepseek-r1`). Pour Llama, ce serait `meta/llama-3.1-70b-instruct`. Si le préfixe de l'organisation n'est pas inclus, l'API renverra une **erreur 404 - Not Found**.

## Utilisation de Modèles Locaux (Ollama / LM Studio)

Préférez-vous exécuter des modèles d'IA directement sur votre machine, sans dépendre d'API externes et tout à fait gratuitement ?

1. Installez [Ollama](https://ollama.ai) et téléchargez un modèle dans votre terminal : `ollama pull llama3.1`
2. Assurez-vous qu'Ollama est en cours d'exécution (via `ollama serve` ou gardez l'application ouverte).
3. Dans l'onglet **Settings**, changez le fournisseur pour **`Local (Ollama / LM Studio)`**.
4. Le champ **Base URL** sera automatiquement renseigné avec `http://localhost:11434/v1`.
5. Saisissez le nom du modèle téléchargé dans le champ **Model Name** (ex : `llama3.1`, `gemma4`, `deepseek-v4-pro`).
6. Le champ API Key sera automatiquement désactivé (les modèles locaux n'en ont pas besoin).

> **⚠️ Note :** La vitesse et la qualité des réponses dépendent purement du matériel (GPU) de votre machine et du modèle choisi.

Nous sommes prêts à chatter !

[**Étape suivante : Dites "Salut" à l'IA** ➔](./quick-start.md)
