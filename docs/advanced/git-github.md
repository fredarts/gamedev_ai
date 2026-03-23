# Aba Git & GitHub (Automação de Versões)

Criar jogos em Godot muitas vezes gera pânico em inciantes quando o assunto é fazer *Commit* de dezenas de arquivos binários obscuros (Cenas, Materiais, Resources). Fazer *Merg* no terminal é exaustivo.

Por isso, o **Gamedev AI** implementa uma Guia nativa de **Git** dentro do Godot, desenhada pensando exclusivamente em fluidez.

## Como Usar a Guia de Versionamento

Na janela direita do plugin, mude da clássica aba `Chat` ou `Settings` para a aba superior **Git**.
A lá, você dará de cara com uma versão visual simplificada e moderna do terminal:

### 1. Initialize & Connect
Se a pasta não for versionada, existerá um botão gigante verde "Initialize Repository". Depois o painel pedirá para você colar o **GitHub URL** do Repo Nuvem que você criou lá no site do Github.

### 2. Auto-Generate Commit Message ✨ (O Ouro)
1. Você acabou de programar, alterou 4 cenas complexas e refez roteiros (`.gd`). 
2. Invés de pensar num texto chato pro Commit. Clique no **"✨ Auto-Generate Commit Message"**.
3. O Gamedev AI fará um Diff invisível. A Inteligência artificial vai olhar absolutamente todos os códigos vermelhos e verdes apagados que você mexeu (ex: *adicionado lógica de rolamento no Player e fixo arrasto do UI*) e criará o resumo escrito super polido na caixa pra você.
4. Apenas clique em **Commit & Sync (Push)**. A IA sobe tudo pra nuvem na hora!

### 3. Branches Isoladas (Linhas do Tempo)
Tem medo de quebrar sua cena `Level_1.tscn` que está perfeita hoje tentando testar um boss novo?
Use a aba lateral **Current Branch** e clique em [Create/Switch]. Digite `teste_boss` e confirme. A partir daí você está seguro numa "cópia isolada" do código.

### 4. Modo Pânico (Desfazer Erros)
O painel inferior detém as Super Actions:
* **Undo Uncommitted Changes:** Estourou a godot engine? Aperte esse botão e tudo volta para sua última versão salva no Github no ato. Um "Ctrl+Z" universal do projeto inteiro.
* **Force Pull:** Esmaga sua pasta local inteira, baixando e substituindo exatamente pelo estado que está blindado na sua nuvem. Perfeito de salvação de vida de programadores.
