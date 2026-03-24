# Guia Completo da Interface (Todos os Botões)

Esta página descreve **cada botão, toggle e controle** presente na interface do Gamedev AI dentro do editor Godot.

![Visão geral da interface principal do Gamedev AI no Godot](../images/main_interface.png)

## 🗂️ Abas Principais

O plugin possui **3 abas** no topo do painel:
- **Chat** — O painel principal de conversa com a IA.
- **Configurações** — Gerenciamento de API Keys, presets, prompts e indexação.
- **Git** — Controle de versão integrado com GitHub.

---

## 💬 Aba Chat

### Barra Superior
| Botão | Função |
|-------|--------|
| **Seletor de Preset** | Dropdown para trocar rapidamente entre diferentes configurações de provedor/modelo (ex: "Gemini 3.1", "GPT-4o"). |
| **A-** / **A+** | Diminui ou aumenta o tamanho da fonte do chat. |
| **+ Novo Chat** | Limpa a conversa atual e inicia uma sessão completamente nova. |
| **⊙ Histórico** | Menu dropdown que lista todas as conversas passadas. Clique em uma para restaurar o contexto completo daquela sessão. |
| **💾 Summarize to Memory** | Envia um prompt automático pedindo à IA para resumir as decisões arquiteturais da conversa atual e salvá-las na memória persistente do projeto. |

### Área de Chat (OutputDisplay)
- Exibe as mensagens formatadas em BBCode com suporte a **negrito**, *itálico*, `código inline` e blocos de código com syntax highlighting.
- Links clicáveis para arquivos do projeto (clique para abrir no editor).
- Botão **Copy** flutuante aparece ao selecionar texto para copiar rapidamente.

### Player TTS (Text-to-Speech)

![Player TTS compacto com controles de reprodução](../images/tts_player.png)

| Controle | Função |
|----------|--------|
| **▶ Ler em Voz Alta** | Converte a última resposta da IA em áudio e reproduz. Útil para ouvir explicações enquanto programa. |
| **⏹ Stop** | Para a reprodução do áudio. |
| **Seek Slider** | Barra de progresso para avançar ou voltar no áudio. |
| **Velocidade (1.0x - 2.0x)** | Controla a velocidade de reprodução do TTS. |

### Botões de Ação Rápida
| Botão | O que faz |
|-------|-----------|
| **✧ Refatorar** | Envia o código selecionado no editor com o prompt "Refactor this code". A IA analisa e propõe melhorias estruturais. |
| **◆ Corrigir** | Envia o código selecionado com "Fix errors in this code". A IA identifica bugs e gera correções. |
| **💡 Explicar** | Envia o código selecionado com "Explain what this code does". A IA explica cada trecho em português. |
| **↺ Desfazer** | Desfaz a última ação que a IA executou no projeto (usando o sistema Undo/Redo do Godot). |
| **🖥 Corrigir Console** | Lê os últimos erros vermelhos do console de Output do Godot e envia diretamente para a IA analisar e propor correções. |

### Área de Input
| Elemento | Função |
|----------|--------|
| **Campo de Texto** | Digite sua mensagem. Use `Shift + Enter` para enviar. |
| **📎 Anexar** | Abre um seletor de arquivos para anexar imagens, scripts ou qualquer arquivo ao prompt. |
| **➤ Enviar** | Envia a mensagem para a IA processar. |
| **Drag & Drop** | Arraste nós da Scene Tree ou arquivos do FileSystem diretamente para o campo de texto ou área do chat. A IA receberá os metadados completos do nó/arquivo arrastado. |

### Toggles Inferiores
| Toggle | Função |
|--------|--------|
| **Contexto** | Quando ativado, o plugin automaticamente anexa o conteúdo completo do script aberto no editor à mensagem enviada. |
| **Captura de Tela** | Quando ativado, tira automaticamente uma screenshot da janela do Godot e a envia junto com a mensagem para análise visual pela IA. |
| **Planejar Antes** | Quando ativado, a IA não escreverá código. Ela apenas responderá com um plano detalhado em Markdown listando as mudanças propostas. Após revisar, clique no botão "Executar Plano" que aparece para ela codar. |
| **Modo Vigiar** | Quando ativado, a IA monitora automaticamente o console de Output do Godot. Se detectar erros críticos (vermelhos) ao rodar o jogo, ela propõe correções automaticamente. Tem cooldown de 30s e limite de 3 correções por ciclo. |

---

## ⚙️ Aba Configurações

### Gerenciamento de Presets
| Elemento | Função |
|----------|--------|
| **Seletor de Predefinição** | Dropdown para escolher entre os presets salvos. |
| **Adicionar** | Cria um novo preset vazio para configurar outro provedor/modelo. |
| **Editar** | Abre o painel de edição mostrando campos de Nome, Provedor, API Key, URL Base e Modelo. |
| **Excluir** | Remove o preset selecionado permanentemente. |
| **Concluir Edição** | Fecha o painel de edição salvando as alterações. |

### Campos de Edição do Preset
| Campo | Descrição |
|-------|-----------|
| **Nome do Preset** | Nome amigável para identificar o preset (ex: "Gemini 3.1 Free"). |
| **Provedor** | Dropdown entre "Gemini" e "OpenAI / OpenRouter". |
| **Chave da API** | Sua API Key do provedor selecionado. |
| **URL Base** | URL base da API (apenas para OpenAI/OpenRouter). |
| **Nome do Modelo** | Nome exato do modelo (ex: `gemini-2.5-flash`, `gpt-4o`). |

### Idioma
| Elemento | Função |
|----------|--------|
| **Seletor de Idioma** | Dropdown para escolher o idioma da interface e das respostas da IA (Português BR, English, etc.). |

### Instruções Personalizadas (Custom System Prompt)
Uma caixa de texto grande onde você pode inserir regras fixas que a IA sempre seguirá. Exemplo: *"Use tipagem estática em todas as funções. Comente em português."*

| Botão | Função |
|-------|--------|
| **✨ Enhance Instructions with AI** | Envia suas instruções atuais para a IA aprimorar automaticamente, adicionando detalhes técnicos e boas práticas. Um preview é exibido antes de aceitar. |

### Vector Database
| Elemento | Função |
|----------|--------|
| **File List** | Lista visual de todos os arquivos `.gd` do projeto com status de indexação (novo, modificado, inalterado). |
| **🔍 Scan Changes** | Vasculha o projeto procurando arquivos novos, modificados ou deletados desde a última indexação. |
| **⚡ Index Codebase** | Inicia o processo de indexação vetorial de todos os scripts modificados usando a API de Embeddings. |

---

## 🐙 Aba Git

### Configuração Inicial
| Elemento | Função |
|----------|--------|
| **Inicializar Repositório** | Inicializa um repositório Git na pasta do projeto (se ainda não existir). |
| **Remote URL** | Campo para colar a URL do repositório GitHub (ex: `https://github.com/user/repo.git`). |
| **Set Remote** | Define a URL remota do repositório. |

### Operações Principais
| Botão | Função |
|-------|--------|
| **🔃 Atualizar Status** | Atualiza o status do Git mostrando arquivos modificados, não rastreados e o branch atual. |
| **⬇️ Puxar** | Baixa as alterações mais recentes do repositório remoto. |
| **✨ Gerar Mensagem de Commit** | A IA analisa todos os arquivos modificados (diff) e gera automaticamente uma mensagem de commit profissional e descritiva. |
| **Commit e Sincronizar (Push)** | Faz commit de todas as mudanças com a mensagem digitada/gerada e envia (push) para o GitHub. |

### Branches
| Elemento | Função |
|----------|--------|
| **Branch Label** | Mostra o nome do branch atual. |
| **Branch Name Input** | Campo para digitar o nome de um novo branch ou branch existente. |
| **Checkout/Create Branch** | Cria um novo branch ou muda para um existente. |

### Ações de Emergência
| Botão | Função |
|-------|--------|
| **⚠️ Desfazer Alterações Não Commitadas** | Descarta TODAS as alterações locais não commitadas, voltando ao estado do último commit. Requer confirmação. |
| **⚠️ Forçar Puxar** | Substitui completamente o projeto local pelo estado do repositório remoto. Requer confirmação. |
| **⚠️ Forçar Push** | Força o envio do estado local para o remoto, sobrescrevendo o histórico. Requer confirmação. |

---

## 📋 Painel de Diff (Revisão de Código)

Quando a IA gera ou modifica código, um painel de Diff aparece no chat:

![Painel de Diff mostrando código removido (vermelho) e adicionado (verde)](../images/diff_preview.png)

| Elemento | Função |
|----------|--------|
| **Visualização de Diff** | Visualização lado-a-lado mostrando linhas removidas (vermelho) e adicionadas (verde). |
| **Aplicar Mudanças** | Aceita as mudanças e aplica no arquivo real. A ação é registrada no Undo/Redo do Godot. |
| **Pular** | Rejeita as mudanças. Nenhum arquivo é alterado. |
