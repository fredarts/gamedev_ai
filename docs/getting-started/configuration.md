# Configuração (Obtendo API Key)

O Gamedev AI não possui um backend proprietário para roubar seus dados. Ele faz chamadas diretas (comutáveis) para os servidores LLMs de ponta que você preferir utilizar. Todo o conhecimento indexado é salvo localmente na sua máquina!

Para o plugin falar e responder aos seus códigos, precisamos fornecer uma **Chave de API** (API Key).

## Utilizando as Ferramentas Google (Gemini) - Gratuito
A forma mais popular, incrivelmente inteligente e **gratuita** de usar o plugin hoje é utilizando o Google AI Studio com o Gemini 1.5 Pro ou 2.0 Flash.

1. Acesse o [Google AI Studio](https://aistudio.google.com/app/apikey).
2. Faça login com sua conta Google (não exige cartão de crédito no Tier Gratuito).
3. Clique em **"Get API key"** ou **"Create API key"**.
4. Copie a chave longa gerada `(exemplo: AIzaSyD......)`.

## Conectando a Chave no Editor

1. Clique na aba oculta superior chamada **"Settings"** dentro do painel Gamedev AI no Godot.
2. Certifique-se de que o provedor (Provider) selecionado no menu suspenso é **"Gemini"**.
3. No campo de texto **API Key**, cole a sua chave inteira copiando-a sem espaços extras.
4. Digite no campo *Model Name* o seu modelo de eleição (o padrão costuma ser `gemini-1.5-pro` ou `gemini-2.5-flash`).

<br>

> **💡 Dica de Ouro!** 
> _(Recomendado: Inserir Print da Aba Settings mostrando os campos API e Provider preenchidos)_

## Utilizando OpenRouter ou OpenAI

Preferêcia por GPT-4o, Claude 3.5 Sonnet ou Meta Llama 3?
O Gamedev AI suporta o ecossistema OpenAI/OpenRouter sem trocar uma linha de código:
1. Volte na aba **Settings**.
2. Troque o provedor (Provider) na caixa suspensa de `Gemini` para `OpenAI / OpenRouter`.
3. Adicione sua chave da OpenAI ou OpenRouter.
4. No campo extra chamado `Base URL`, coloque:
   * Para OpenAI: `https://api.openai.com/v1`
   * Para OpenRouter: `https://openrouter.ai/api/v1`
5. Altere o nome do modelo (ex: `gpt-4o` ou `anthropic/claude-3.5-sonnet`).

Estamos prontos para conversar!

[**Próximo Passo: Dê um "Oi" para a IA** \u27A4](./quick-start.md)
