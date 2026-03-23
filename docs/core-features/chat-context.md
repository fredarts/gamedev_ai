# Chat, Anexos e Contexto (O Pulmão do Plugin)

O Chat é mais do que um chat do ChatGPT embutido na janela direita do editor. Ele é o verdadeiro "sistema respiratório" entre a seus **Arquivos do Jogo** e a **Mente da IA**.

## A Importância do "Context" (Ler seu código atual)

A Inteligência Artificial não consegue ver seu monitor e nem sabe no que você está programando no momento — *A não ser que você mande ela olhar!*

Abaixo da barra de *"Enviar"*, você verá um Checkbox importante chamado **Contexto**. 
1. **Marcado (Padrão):** O Gamedev AI irá copiar secretamente cada linha e caractere do arquivo (`.gd`) que estiver com o cursor piscando naquele instante na sua janela de Script. Ela enviará junto na pergunta que você fizer!
2. **Desmarcado:** Economiza os seus "Tokens" limitados de contexto nos modelos pagos (OpenAI), fazendo uma pergunta cega e rápida como no ChatGPT genérico. Quando se tem um problema solto e que não exige a aba da engine.

## 📸 Captura de Tela (Screenshot Automático)

Ao lado do toggle de Contexto, existe o toggle **Captura de Tela**. Essa funcionalidade permite que a IA literalmente "veja" o que está na sua tela do Godot.

### Como Funciona
1. **Ative o toggle "Captura de Tela"** na barra inferior do Chat.
2. A próxima mensagem que você enviar virá acompanhada de uma **screenshot automática** de toda a janela do editor Godot.
3. A IA receberá a imagem completa e poderá analisar visualmente: a cena 2D/3D aberta, a Scene Tree, o Inspector, o Output, e qualquer outro painel visível.

### Quando Usar
- **UI quebrada:** Sua interface do jogo está desalinhada mas você não sabe qual Label ou Container é o culpado? Ative a captura, mande um "O que está errado com esse layout?" e a IA analisará visualmente os nós.
- **Scene Tree complexa:** Quer que a IA entenda como está organizada a hierarquia de nós sem descrever cada um manualmente.

::: tip Dica
A IA também possui a ferramenta `capture_editor_screenshot` que ela mesma pode chamar a qualquer momento durante uma conversa se precisar "olhar" para o editor por conta própria.
:::

## Botão Planejar Antes (Plan First)

É muito comum errarmos ao pedir para a IA criar, de primeira, toda a lógica de um RPG gigante. O plugin permite frear a impulsividade robótica ativando o **Planejar Antes**.
* **Marcado:** O plugin mandará uma diretiva estrita. *A IA não criará código*. Ela responderá exclusivamente com uma lista Markdown numerada enumerando o projeto (Classes, Nomes e Funções Base) a serem alterados.
* Após você revisar e aprovar, clique no botão **"Executar Plano"** que surgirá automaticamente. A IA então começará a implementar tudo que planejou.

## Anexos e Nós Arrastáveis

Precisa analisar como uma Sprite2D está feita, ou o porquê da Scene `Player.tscn` não bater no RigidBody3D `Ground`? 

O plugin Gamedev AI suporta arraste Drag & Drop. Você não precisa gastar tempo abrindo cada aba de Inspector que gerou curiosidade ou falha visível...
1. **Scene Tree:** Clique em um Nó da Scene e arraste em direção à barra de texto. A IA usará o atalho para analisar todos os Metadados do Nó (posições ocultas, instanciamentos, tags colisionadoras...) e entender porque os vetores de atrito não parecem funcionar.
2. **Botão 📎 Anexar:** Use para inserir Imagens (`.png` do UI bugado), arquivos brutos de saves (`.json`) e capturas globais de scripts grandes (embora a indexação vetorial seja o método mais profissional).

---

## 🎙️ Ler em Voz Alta (TTS - Text-to-Speech)

O Gamedev AI possui um player de **narração por voz** embutido que converte as respostas da IA em áudio. Isso permite que você ouça as explicações enquanto continua programando sem parar para ler paredes de texto.

### Como Usar
1. Após a IA responder qualquer pergunta no chat, clique no botão **"▶ Ler em Voz Alta"** (localizado logo abaixo da área de chat).
2. O plugin enviará uma requisição para converter o texto da última resposta em áudio.
3. Um player de áudio compacto aparecerá com controles completos:

| Controle | Função |
|----------|--------|
| **▶ Ler em Voz Alta** | Inicia a reprodução da narração. |
| **⏹ (Stop)** | Para a reprodução imediatamente. |
| **Barra de Progresso** | Permite avançar ou retroceder na narração arrastando o slider. |
| **Velocidade (1.0x a 2.0x)** | Controla a velocidade da narração. Use 1.5x ou 2.0x para ouvir mais rápido. |

### Quando é Útil
- **Respostas longas:** A IA explicou 3 parágrafos sobre como funciona o `NavigationAgent3D`? Ouça enquanto ajusta os nós na Scene Tree.
- **Acessibilidade:** Para desenvolvedores que preferem aprender ouvindo ou que têm dificuldade com leitura prolongada de telas.
- **Revisão passiva:** Deixe a IA narrar o plano de refatoração enquanto você toma um café!

::: info Nota
O recurso TTS utiliza a API do provedor configurado para sintetizar o áudio. O stream é armazenado em cache, então pausar e retomar não gera custo adicional de tokens.
:::

---

## ⚡ Botões de Ação Rápida

Na barra logo abaixo da área de chat (e acima do campo de texto), existem **5 botões de ação rápida** que funcionam como atalhos inteligentes. Eles enviam automaticamente um prompt pré-configurado junto com o código que você selecionou no Editor de Scripts do Godot.

### Como Funcionam
1. **Abra qualquer script** (`.gd`) na janela de edição do Godot.
2. **Selecione um trecho de código** com o mouse ou teclado (ex: uma função inteira, um bloco `if`, ou algumas linhas).
3. **Clique em um dos botões** abaixo:

### Os 5 Botões

| Botão | Prompt Enviado | O que a IA Faz |
|-------|---------------|----------------|
| **✧ Refatorar** | "Refactor this code" | Analisa o trecho selecionado e propõe uma versão mais limpa, eficiente e com melhores práticas de GDScript. |
| **◆ Corrigir** | "Fix errors in this code" | Identifica bugs, erros de sintaxe, tipos incorretos ou lógica falha no trecho e gera a correção em Diff. |
| **💡 Explicar** | "Explain what this code does" | Explica linha a linha o que o trecho faz em linguagem natural (português), ideal para aprender ou documentar. |
| **↺ Desfazer** | *(Ação direta)* | Desfaz a última modificação que a IA fez no projeto usando o sistema Undo/Redo nativo do Godot. Sem prompt. |
| **🖥 Corrigir Console** | *(Lê o Output)* | Lê os últimos erros vermelhos do console de Output do Godot e os envia para a IA diagnosticar e propor conserto. |

### Exemplo de Uso do "Corrigir Console"
1. Você dá Play no jogo pelo Godot (`F5`).
2. O jogo crasha e aparece um erro vermelho: `Attempt to call function 'die' in base 'null instance'`.
3. Sem copiar nada, clique em **🖥 Corrigir Console**.
4. A IA lerá o log do Output sozinha, encontrará o script problemático e sugerirá a correção em uma Diff segura.

::: tip Dica
O botão **"Corrigir Console"** é diferente do **"Modo Vigiar"**. O Console requer um clique manual, enquanto o Modo Vigiar opera automaticamente em background depois de ativado.
:::

