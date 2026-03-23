# Chat, Anexos e Contexto (O Pulmão do Plugin)

O Chat é mais do que um chat do ChatGPT embutido na janela direita do editor. Ele é o verdadeiro "sistema respiratório" entre a sua Scene Tree (Arquivos do Jogo) e a Mente da IA.

## A Importância do "Context" (Ler seu código atual)

A Inteligência Artificial não consegue ver seu monitor e nem sabe no que você está programando no momento — *A não ser que você mande ela olhar!*

Abaixo da barra de *"Enviar"*, você verá um Checkbox importante chamado **Context**. 
1. **Marcado (Padrão):** O Gamedev AI irá copiar secretamente cada linha e caractere do arquivo (`.gd`) que estiver com o cursor piscando naquele instante na sua janela de Script. Ela enviará junto na pergunta que você fizer!
2. **Desmarcado:** Economiza os seus "Tokens" limitados de contexto nos modelos pagos (OpenAI), fazendo uma pergunta cega e rápida como no ChatGPT genérico. Quando se tem um problema solto e que não exige a aba da engine.

## Botão Plan First (Projetar antes de Codar)

É muito comum errarmos ao pedir para a IA criar, de primeira, toda a lógica de um RPG gigante. O plugin permite frear a impulsividade robótica ativando o **Plan First** (Projetar).
* **Marcado:** O plugin mandará uma diretiva estrita. *A IA não codará*. Ela responderá exclusivamente com uma lista Markdown numerada enumerando o projeto (Classes, Nomes e Funções Base) a serem alterados.
* Você revê seus passos e comanda a resposta "Aprovado!", caso ela preencha os gargalos estruturais na engine, salvando horas com retrabalhos futuros de lógica na "Hora do Diff Seguro".

## Anexos e Nós Arrastáveis

Precisa analisar como uma Sprite2D está feita, ou o porquê da Scene `Player.tscn` não bater no RigidBody3D `Ground`? 

O plugin Gamedev AI suporta arraste Drag & Drop. Você não precisa gastar tempo abrindo cada aba de Inspector que gerou curiosidade ou falha visível...
1. **Scene Tree:** Clique em um Nó da Scene e araste em direção a barra de texto InputField. A IA usará o atalho para analisar todos os Metadados do Nó (posições ocultas, instanciamentos, tags colisionadoras...) e entender porque os vetores de atrito não parecem funcionar.
2. **Botão 📎 Anexar:** Use para inserir Imagens (.PNG do UI bugado da sua tela sem contexto), arquivos brutos de saves (.JSON) e capturas globais de scripts grandes (embora a indexação seja o método mais pro).
