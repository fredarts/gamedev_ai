import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Gamedev AI",
  description: "A IA Autônoma que mora no coração do Godot 4.",
  base: '/gamedev_ai/',

  head: [
    ['link', { rel: 'icon', type: 'image/x-icon', href: '/gamedev_ai/favicon.ico' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/gamedev_ai/favicon-32x32.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/gamedev_ai/favicon-16x16.png' }],
    ['link', { rel: 'apple-touch-icon', sizes: '180x180', href: '/gamedev_ai/apple-touch-icon.png' }],
    ['link', { rel: 'manifest', href: '/gamedev_ai/site.webmanifest' }]
  ],

  locales: {
    root: {
      label: 'Português',
      lang: 'pt-BR',
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
              { text: 'As 25 Skills (Catálogo)', link: '/memory/skills' },
              { text: 'Memória Persistente', link: '/memory/persistent' }
            ]
          },
          {
            text: '🚀 Ferramentas & Referência',
            collapsed: false,
            items: [
              { text: 'Guia Completo da Interface', link: '/advanced/ui-guide' },
              { text: 'Todas as 27 Tools da IA', link: '/advanced/tools-reference' },
              { text: 'Aba Git & GitHub', link: '/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Lançado sob a Licença MIT.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Página Anterior', next: 'Próxima Página' },
        outline: { label: 'Nesta Página', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              root: {
                translations: {
                  button: { buttonText: 'Pesquisar', buttonAriaLabel: 'Pesquisar' },
                  modal: {
                    noResultsText: 'Nenhum resultado para',
                    resetButtonTitle: 'Limpar pesquisa',
                    footer: { selectText: 'para selecionar', navigateText: 'para navegar', closeText: 'para fechar' }
                  }
                }
              }
            }
          }
        }
      }
    },
    en: {
      label: 'English',
      lang: 'en',
      description: "The Autonomous AI living in the heart of Godot 4.",
      themeConfig: {
        nav: [
          { text: 'Home', link: '/en/' },
          { text: 'Guide', link: '/en/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ Getting Started',
            collapsed: false,
            items: [
              { text: '1. Installation', link: '/en/getting-started/installation' },
              { text: '2. Setup API Key', link: '/en/getting-started/configuration' },
              { text: '3. Quick Start', link: '/en/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 Main Workflow',
            collapsed: false,
            items: [
              { text: 'Chat, Context & Nodes', link: '/en/core-features/chat-context' },
              { text: 'Diff: Code Review', link: '/en/core-features/diff-apply' },
              { text: 'Watch Mode (Auto-Fix)', link: '/en/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 Knowledge & DB',
            collapsed: false,
            items: [
              { text: 'Index Codebase (Vector DB)', link: '/en/memory/vector-db' },
              { text: 'The 25 Skills (Catalog)', link: '/en/memory/skills' },
              { text: 'Persistent Memory', link: '/en/memory/persistent' }
            ]
          },
          {
            text: '🚀 Tools & Reference',
            collapsed: false,
            items: [
              { text: 'Full UI Guide', link: '/en/advanced/ui-guide' },
              { text: 'All 27 AI Tools', link: '/en/advanced/tools-reference' },
              { text: 'Git & GitHub Tab', link: '/en/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/en/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Released under the MIT License.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Previous Page', next: 'Next Page' },
        outline: { label: 'On this page', level: [2, 3] },
        search: { provider: 'local' }
      }
    },
    es: { label: 'Español', lang: 'es' },
    fr: { label: 'Français', lang: 'fr' },
    de: { label: 'Deutsch', lang: 'de' },
    hi: { label: 'हिन्दी', lang: 'hi' },
    zh_CN: { label: '简体中文', lang: 'zh-CN' },
    ar: { label: 'العربية', lang: 'ar' },
    ru: { label: 'Русский', lang: 'ru' },
    bn: { label: 'বাংলা', lang: 'bn' },
    id: { label: 'Bahasa Indonesia', lang: 'id' }
  },

  themeConfig: {
    logo: '/images/gamedevAi_logo.png',
    siteTitle: false,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/fredarts/gamedev_ai' }
    ]
  }
})
