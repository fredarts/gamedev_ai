# Configuração (Obtendo API Key)

O Gamedev AI não possui um backend proprietário para roubar seus dados. Ele faz chamadas diretas (comutáveis) para os servidores LLMs de ponta que você preferir utilizar. Todo o conhecimento indexado é salvo localmente na sua máquina para sua segurança!

Para o plugin falar e responder aos seus códigos, precisamos fornecer uma **Chave de API** (API Key).

## Utilizando as Ferramentas Google (Gemini) - Gratuito
A forma mais popular, incrivelmente inteligente e **gratuita** de usar o plugin hoje é utilizando o Google AI Studio com o Gemini 2.5 Pro ou Gemini 2.5 Flash. O Gemini 3.0 e 3.1 pro são pagos.

1. Acesse o [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Faça login com sua conta Google (não exige cartão de crédito no Tier Gratuito).
3. Clique em **"Get API key"** ou **"Create API key"**.
4. Copie a chave longa gerada `(exemplo: AIzaSyD......)`.

## Conectando a Chave no Editor

1. Clique na aba oculta superior chamada **"Settings"** dentro do painel Gamedev AI no Godot.
2. Certifique-se de que o provedor (Provider) selecionado no menu suspenso é **"Gemini"**.
3. No campo de texto **API Key**, cole a sua chave inteira copiando-a sem espaços extras.
4. Digite no campo *Model Name* o seu modelo de eleição (o padrão costuma ser `gemini-2.5-pro` ou `gemini-2.5-flash`).

<br>

> **💡 Dica de Ouro!** 

![Aba Settings mostrando campos de Preset, Provedor e API Key](../images/settings_ui.png)

## Utilizando OpenRouter ou OpenAI

Preferêcia por GPT-5.4, Claude Opus 4.6, Qwen3 Coder.
O Gamedev AI suporta o ecossistema OpenAI/OpenRouter sem trocar uma linha de código:
1. Volte na aba **Settings**.
2. Troque o provedor (Provider) na caixa suspensa de `Gemini` para `OpenAI / OpenRouter`.
3. Adicione sua chave da OpenAI ou OpenRouter.
4. No campo extra chamado `Base URL`, coloque:
   * Para OpenAI: `https://api.openai.com/v1`
   * Para OpenRouter: `https://openrouter.ai/api/v1`
5. Altere o nome do modelo (ex: `gpt-5.4` ou `anthropic/claude-opus-4.6`).

## Utilizando Modelos Locais (Ollama / LM Studio)

Prefere rodar modelos de IA diretamente na sua máquina, sem depender de APIs externas? 
O Gamedev AI suporta qualquer servidor compatível com a API OpenAI rodando localmente:

1. Instale o [Ollama](https://ollama.ai) e baixe um modelo: `ollama pull llama3.1`
2. Certifique-se de que o Ollama está rodando (`ollama serve`).
3. Na aba **Settings**, troque o Provider para **`Local (Ollama / LM Studio)`**.
4. O campo **Base URL** será preenchido automaticamente com `http://localhost:11434/v1`.
5. Digite o nome do modelo no campo **Model Name** (ex: `llama3.1`, `gemma3`, `qwen3`).
6. O campo API Key será desabilitado automaticamente (modelos locais não necessitam).

> **⚠️ Nota:** A qualidade das respostas depende do modelo local escolhido e dos recursos de hardware disponíveis.

Estamos prontos para conversar!

[**Próximo Passo: Dê um "Oi" para a IA** \u27A4](./quick-start.md)
