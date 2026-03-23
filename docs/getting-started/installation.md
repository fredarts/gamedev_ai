# Instalação

Bem-vindo à documentação oficial do **Gamedev AI**! Esta página vai focar em como adicionar rapidamente o assistente ao seu projeto atual do Godot 4.

## Requisitos
* **Godot Engine:** Versão 4.2 ou superior (suporte nativo ao `.gdextension` não é necessário, o plugin roda puro em GDScript).
* Conta Google ou OpenRouter para chaves de API.

## Passo a Passo Manual (GitHub)

1. Crie ou abra um projeto existente no Godot 4.
2. Navegue até a pasta raiz do seu projeto (onde fica o arquivo `project.godot`).
3. Crie uma pasta chamada `addons` (se já não existir).
4. Dentro de `addons/`, baixe ou clone o repositório do plugin:
```bash
git clone https://github.com/fredericoBSS/Gamedev-Ai.pm gamedev_ai
```
*(Ou baixe o arquivo `.zip` da aba de Releases no GitHub e extraia dentro de `addons/gamedev_ai`).*

## Ativando no Editor

Com os arquivos no lugar:
1. Abra o editor do seu projeto Godot.
2. Vá no menu `Project` no topo e escolha `Project Settings`.
3. Navegue até a aba `Plugins` no canto superior.
4. Encontre **Gamedev AI** na lista de plugins instalados.
5. Marque a caixinha `Enable` (Ativar).

Pronto! Ao ativá-lo pela primeira vez, você verá o painel verde de Chat do Gamedev AI aparecer na *Dock* direita do seu editor.

[**Próximo Passo: Configure sua Chave de API** \u27A4](./configuration.md)
