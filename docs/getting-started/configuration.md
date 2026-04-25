# Configuração (Obtendo API Key)

O Gamedev AI não possui um backend proprietário para roubar seus dados. Ele faz chamadas diretas (comutáveis) para os servidores LLMs de ponta que você preferir utilizar. Todo o conhecimento indexado é salvo localmente na sua máquina para sua segurança!

Para o plugin falar e responder aos seus códigos, precisamos fornecer uma **Chave de API** (API Key).

## Utilizando as Ferramentas Google (Gemini)
A forma mais popular e incrivelmente inteligente de usar o plugin hoje é utilizando o Google AI Studio com o Gemini 3.1 Pro ou Gemini 3.1 Flash. O Gemini 4.0 está em beta.

1. Acesse o [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Faça login com sua conta Google (não exige cartão de crédito no Tier Gratuito).
3. Clique em **"Get API key"** ou **"Create API key"**.
4. Copie a chave longa gerada `(exemplo: AIzaSyD......)`.

## Conectando a Chave no Editor

1. Clique na aba oculta superior chamada **"Settings"** dentro do painel Gamedev AI no Godot.
2. Certifique-se de que o provedor (Provider) selecionado no menu suspenso é **"Gemini"**.
3. No campo de texto **API Key**, cole a sua chave inteira copiando-a sem espaços extras.
4. Digite no campo *Model Name* o seu modelo de eleição (o padrão costuma ser `gemini-3.1-pro` ou `gemini-3.1-flash`).

<br>

> **💡 Dica de Ouro!** 

![Aba Settings mostrando campos de Preset, Provedor e API Key](../images/settings_ui.png)

## Utilizando OpenRouter ou OpenAI

Se você prefere acessar modelos como o Claude 3.5 Sonnet, GPT-4o, ou outros modelos abertos de ponta, o Gamedev AI suporta APIs compatíveis nativamente.

1. Registre-se e obtenha sua API Key em:
   * [OpenRouter](https://openrouter.ai/keys)
   * [OpenAI](https://platform.openai.com/api-keys)
2. Volte na aba oculta **Settings** dentro do Godot.
3. Troque o provedor (Provider) na caixa suspensa de `Gemini` para `OpenAI / OpenRouter`.
4. Cole sua **API Key**.
5. No campo extra chamado **Base URL**, coloque **exatamente** o endereço correspondente:
   * **OpenRouter:** `https://openrouter.ai/api/v1`
   * **OpenAI:** `https://api.openai.com/v1`
6. Altere o campo **Model Name** para o identificador do modelo (ex: `anthropic/claude-opus-4.7` ou `gpt-5.5`).

## Utilizando NVIDIA NIM (DeepSeek Gratuito e Outros)

A plataforma NVIDIA NIM oferece acesso rápido e muitas vezes gratuito a vários modelos de ponta, como as linhas **DeepSeek** e **Llama**, através de uma API compatível com o padrão OpenAI.

1. Acesse o [NVIDIA API Catalog](https://build.nvidia.com/) e crie uma conta para obter sua API Key.
2. Na aba **Settings** do plugin, selecione o provedor **`OpenAI / OpenRouter`**.
3. Cole a sua **API Key** gerada pela NVIDIA.
4. No campo **Base URL**, você deve colocar a URL exata da NVIDIA NIM:
   * `https://integrate.api.nvidia.com/v1`
5. No campo **Model Name**, você deve colocar o nome do modelo desejado. 

> **⚠️ Atenção: O Nome do Modelo na NVIDIA**
> Na NVIDIA NIM, você é **obrigado** a colocar o "prefixo da organização" antes do nome do modelo. 
> Exemplo: Para o DeepSeek, você não deve usar apenas `deepseek-v4-pro`, mas sim **`deepseek-ai/deepseek-v4-pro`** (ou `deepseek-ai/deepseek-r1`). Para o Llama, seria `meta/llama-3.1-70b-instruct`. Se o prefixo da organização não for incluído, a API retornará um **erro 404 - Não Encontrado**.

## Utilizando Modelos Locais (Ollama / LM Studio)

Prefere rodar modelos de IA diretamente na sua máquina, sem depender de APIs externas e sem custo algum? 

1. Instale o [Ollama](https://ollama.ai) e baixe um modelo no seu terminal: `ollama pull llama3.1`
2. Certifique-se de que o Ollama está rodando (comando `ollama serve` ou deixe o aplicativo aberto).
3. Na aba **Settings**, troque o Provider para **`Local (Ollama / LM Studio)`**.
4. O campo **Base URL** será preenchido automaticamente com `http://localhost:11434/v1`.
5. Digite o nome do modelo baixado no campo **Model Name** (ex: `llama3.1`, `gemma4`, `deepseek-v4-pro`).
6. O campo API Key será desabilitado automaticamente (modelos locais não necessitam de chave).

> **⚠️ Nota:** A velocidade e qualidade das respostas dependem puramente do hardware (Placa de Vídeo) da sua máquina e do modelo escolhido.

Estamos prontos para conversar!

[**Próximo Passo: Dê um "Oi" para a IA** \u27A4](./quick-start.md)
