# Watch Mode (A Mágica da Auto-Depuração)

Como gamedev, você passa **30% do tempo desenvolvendo lógicas de jogo fantásticas** e dolorosos **70% decifrando Erros Vermelhos semânticos e Null Reference Exceptions** na aba `Debugger / Output` do Godot.

O recurso **Watch Mode** do Gamedev AI elimina essa segunda fase assustadora de depuração manual. Ele torna o bot um Engenheiro Q&A invisível trabalhando na sala ao lado.

## Por que Ativar? E como Ativar? 
Na base do seu painel do Chat, ative a Checkbox reluzente chamada **[x] Watch Mode**.

O que acontece por trás dos palcos:
1. Você dá `F5` (Jogar A Cena / Debug Project) no Godot.
2. Seu jogador esbarra numa `Area2D` onde você esqueceu a inicialização nítida de grupo `NodeGroup`. A engine desaba e espirra um texto vermelho letal no Output ("Attempt to call function 'die' in base 'null instance'").
3. Sem você clicar ou copiar o texto. O Gamedev AI _acorda_, lê o log do erro de sintaxe nos 50 últimos blocos do console, se junta os arquivos suspeitos indexados, escreve a hipótese da falha da referência e te devolve com **solução de reescrita em Diff** instantaneamente, ou explica passo a passo onde está o Node cego.

## Limites de "Tolerância" e Cooldown

Assistentes superativos queimam a conta dos Modelos Pagos enviando "Warnings Orfãos" repetitivos da Engine do Godot (erros soltos insignificantes amarelos que não cracharam nada de fato).

Para gerenciar o bolso e o flood, o Gamedev AI limita a vigia com **Cool-downs dinâmicos**:
* Ele engatilha no máximo as primeiras **três** ondas de Output Críticas relatadas pelo Log dentro de algumas frações curtas de 30 segundos, ou as vezes, ele espera longamente em `standby`.

_Cuidar da engine se tornou quase brincadeira lendo conselhos autônomos._
