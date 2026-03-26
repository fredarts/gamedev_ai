# 🧠 Agentes & Inteligência

O Gamedev AI não é apenas um chat que escreve código. Ele é alimentado por uma arquitetura de agentes de última geração, baseada nas melhores práticas de desenvolvimento autônomo, permitindo ao assistente agir de forma metódica, proativa e consciente do contexto.

---

## 🎭 Personas Especialistas (Dynamic Routing)

A IA identifica automaticamente o seu objetivo baseado na sua conversa e assume uma "Persona" específica. Isso garante que o prompt seja focado apenas no que importa, economizando tokens e aumentando a precisão.

- **Godot Expert**: O assistente geral para lógica de jogo e estrutura.
- **UI/UX Designer**: Focado em nodes de `Control`, âncoras e layouts responsivos.
- **Technical Artist**: Especialista em Shaders, partículas e efeitos visuais.
- **Multiplayer Engineer**: Focado em rede, RPCs e sincronização.

> [!TIP]
> Você pode forçar uma persona mencionando palavras-chave como "preciso de um menu (UI)" ou "estou fazendo um shader".

---

## ⛩️ Portão Socrático (Stop & Ask)

Para evitar gerar códigos massivos e genéricos que podem não servir para o seu projeto, a IA implementa o **Portão Socrático**.

Sempre que você pedir algo complexo (ex: "Crie um sistema de inventário"), a IA irá:
1. **Parar** a geração de código.
2. **Perguntar** pelo menos 2 questões de *trade-off* ou casos de borda (ex: "Será baseado em slots ou peso?", "Precisa de persistência em banco de dados?").
3. **Executar** apenas após a sua clarificação.

---

## ⌨️ Workflows via Slash Commands

Você pode usar comandos diretos para mudar o comportamento da IA instantaneamente:

- `/brainstorm`: A IA entra em modo de descoberta. Ela não escreverá código, apenas ajudará a planejar a arquitetura, GDD e lógica.
- `/plan`: Focado em estruturar pastas e cenas antes de codificar.
- `/debug`: Modo de investigação profunda. Foca apenas em logs de erro e causa raiz.

---

## 🔍 Auto-Audit (Refinamento Autônomo)

Após realizar mudanças complexas, a IA possui a autonomia de rodar ferramentas de auditoria (`audit_script`, `audit_scene`) para verificar erros de sintaxe ou referências órfãs antes de considerar a tarefa concluída. Isso garante um ciclo de feedback muito mais curto e código mais estável.
