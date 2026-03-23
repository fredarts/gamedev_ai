import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Gamedev AI",
  description: "A IA Autônoma que mora no coração do Godot 4.",
  base: '/gamedev_ai/',
  
  head: [
    ['link', { rel: 'icon', href: '/favicon.ico' }]
  ],
  
  themeConfig: {
    nav: [
      { text: 'Início', link: '/' },
      { text: 'Guia de Uso', link: '/getting-started/installation' }
    ],

    sidebar: [
      {
        text: '🛠️ Começando',
        collapsed: false,
        items: [
          { text: '1. Instalação', link: '/getting-started/installation' },
          { text: '2. Configurar a API Key', link: '/getting-started/configuration' },
          { text: '3. Primeiro Uso (O Básico)', link: '/getting-started/quick-start' }
        ]
      },
      {
        text: '💡 Workflow Principal',
        collapsed: false,
        items: [
          { text: 'Chat, Anexos e Nodes', link: '/core-features/chat-context' },
          { text: 'Diff: Revisando Código', link: '/core-features/diff-apply' },
          { text: 'Watch Mode (Auto-Fix)', link: '/core-features/watch-mode' }
        ]
      },
      {
        text: '🧠 Conhecimento & Banco',
        collapsed: false,
        items: [
          { text: 'Index Codebase (Vector DB)', link: '/memory/vector-db' },
          { text: 'O Sistema de Skills', link: '/memory/skills' },
          { text: 'Memória Persistente', link: '/memory/persistent' }
        ]
      },
      {
        text: '🚀 Ferramentas Exclusivas',
        collapsed: false,
        items: [
          { text: 'Aba Git & GitHub', link: '/advanced/git-github' },
          { text: 'Custom System Prompt', link: '/advanced/custom-prompts' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/fredericoBSS/Gamedev-Ai' }
    ],
    
    search: {
      provider: 'local',
      options: {
        locales: {
          root: {
            translations: {
              button: {
                buttonText: 'Pesquisar',
                buttonAriaLabel: 'Pesquisar'
              },
              modal: {
                noResultsText: 'Nenhum resultado para',
                resetButtonTitle: 'Limpar pesquisa',
                footer: {
                  selectText: 'para selecionar',
                  navigateText: 'para navegar',
                  closeText: 'para fechar'
                }
              }
            }
          }
        }
      }
    },
    
    footer: {
      message: 'Lançado sob a Licença MIT.',
      copyright: 'Copyright © 2023-presente Gamedev AI Contributors'
    },
    
    outline: {
      label: 'Nesta Página',
      level: [2, 3]
    },
    
    docFooter: {
      prev: 'Página Anterior',
      next: 'Próxima Página'
    }
  }
})
