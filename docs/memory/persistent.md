# Memória Persistente (A IA como Arquiteto)

Se a Indexação (Codebase) ensina à IA **"Onde está"** cada código fonte que o Godot já processou, a Memória Persistente ensina **"O Porquê"** as coisas foram programadas daquele jeito.

Desenvolvedores solo e pequenos estúdios sofrem após semanas sem abrir um projeto. *Por que a classe de Save Game salva em binário e não JSON? Por que usei CharacterBody2D e mudei de ideia depois?* 

## O Botão de "Summarize to Memory"

Na aba central superior do painel de Chat `(ao lado do botão History)`, repousa o botão brilhante de **💾 Summarize to Memory** (Resumir para Memória).

Sempre que você tiver uma sessão longa, árdua e complexa com a IA (ex: Refatorando o sistema de Física inteiro do Carro), siga esse passo:
1. No fim do dia, aperte **Summarize to Memory**.
2. A IA fará uma leitura profunda de tudo que vocês debateram.
3. Ela criará arquivos permanentes de formato *Memory Log* na pasta invisível `.gamedev_ai` do seu projeto.
4. Quando você abrir o projeto 3 semanas depois para corrigir um bug na física do carro, a IA magicamente puxará das entranhas o motivo de você não ter usado "Friction" nativo do Godot sem que você precise abrir 40 janelas do chat antigo pra relembrar o porquê.

*O Plugin Godot se torna efetivamente o Documentador e Engenheiro Soft do seu estúdio.*
