# Index Codebase (A Mente Analítica)

Um dos pontos de mais valia do Gamedev AI, diferenciando-o drasticamente do ChatGPT convencional ou de outros co-pilotos no VSCode, é o seu conhecimento profundo da malha conectiva do seu projeto de jogo.

Se o "Contexto Aberto" é o olho atual da IA, o **Indexar Codebase** é a teia neural dormente do robô.

## O Que é a Indexação Vetorial (Vector DB)?

Quando trabalhamos com frameworks imensos como Godot, muitas classes customizadas como `PlayerStats`, `InventoryManager` ou `WeaponBuilder` não pertencem ao manual clássico do GDScript que a IA estudou anos atrás lá pela OpenAI. São classes que **você** cunhou. 

Ir lá e colar o script do `PlayerStats` toda vez no chat para perguntar sobre inventário devora milhares de tokens repetitivos e seu tempo. Embutindo a Indexação DB (Vector Search), isso acaba.

### Operando a Indexação (Botão Configurações)
1. Vá no painel do Gamedev AI e clique aba engrenagem oculta de opções de Contexto ("⚙️ Configurações" no canto inferior).
2. Role o painel de opções para revelar a janela de **Banco de Dados Vetorial**.
3. Clique em **🔍 Escanear Mudanças**. O plugin vasculhará todos os seus Nomes de Arquivos no disco, procurando por exclusões ou edições não reportadas.
4. O *File List* visual se populará em cores apontando adições cruciais e as velhas sem alterações. Se houver discrepância da Indexação final anterior:
5. Por fim, aperte **⚡ Indexar Banco de Dados**.

Isso ativará o modo indexador invisível com a API de Embeddings da Gemini text-embedding. Ao final da ampulheta de progresso, uma rede RAG semântica em JSon será encriptada oculta de disco chamada `.gamedev_ai/vector_db.json`. 

Agora, tente no chat:
* *"Como eu arrumo o bug no inventário?"* 

A IA responderá: *"Oh, notei pelos seus scripts em `res://src/player_inventory.gd` e pela chamada em `Network.gd` que as classes não são conectadas de forma persistente. Vou ajustar isso."* 



[**Próximo Passo: Entenda os 25 Arquivos de "Skills" que Ajudam o RAG** \u27A4](./skills.md)
