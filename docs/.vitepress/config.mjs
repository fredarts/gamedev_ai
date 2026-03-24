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
    es: {
      label: 'Español',
      lang: 'es',
      description: "La IA Autónoma que vive en el corazón de Godot 4.",
      themeConfig: {
        nav: [
          { text: 'Inicio', link: '/es/' },
          { text: 'Guía', link: '/es/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ Primeros Pasos',
            collapsed: false,
            items: [
              { text: '1. Instalación', link: '/es/getting-started/installation' },
              { text: '2. Configurar Clave API', link: '/es/getting-started/configuration' },
              { text: '3. Inicio Rápido', link: '/es/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 Workflow Principal',
            collapsed: false,
            items: [
              { text: 'Chat, Contexto y Nodos', link: '/es/core-features/chat-context' },
              { text: 'Diff: Revisión de Código', link: '/es/core-features/diff-apply' },
              { text: 'Modo Vigilancia (Auto-Fix)', link: '/es/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 Conocimiento y DB',
            collapsed: false,
            items: [
              { text: 'Index Codebase (Vector DB)', link: '/es/memory/vector-db' },
              { text: 'Las 25 Skills (Catálogo)', link: '/es/memory/skills' },
              { text: 'Memoria Persistente', link: '/es/memory/persistent' }
            ]
          },
          {
            text: '🚀 Herramientas y Referencia',
            collapsed: false,
            items: [
              { text: 'Guía de Interfaz Completa', link: '/es/advanced/ui-guide' },
              { text: 'Las 27 Tools de la IA', link: '/es/advanced/tools-reference' },
              { text: 'Pestaña Git y GitHub', link: '/es/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/es/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Lanzado bajo la Licencia MIT.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Página anterior', next: 'Siguiente página' },
        outline: { label: 'En esta página', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              es: {
                translations: {
                  button: { buttonText: 'Buscar', buttonAriaLabel: 'Buscar' },
                  modal: {
                    noResultsText: 'No hay resultados para',
                    resetButtonTitle: 'Limpiar búsqueda',
                    footer: { selectText: 'para seleccionar', navigateText: 'para navegar', closeText: 'para cerrar' }
                  }
                }
              }
            }
          }
        }
      }
    },
    fr: {
      label: 'Français',
      lang: 'fr',
      description: "L'IA Autonome qui vit au cœur de Godot 4.",
      themeConfig: {
        nav: [
          { text: 'Accueil', link: '/fr/' },
          { text: 'Guide', link: '/fr/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ Premiers Pas',
            collapsed: false,
            items: [
              { text: '1. Installation', link: '/fr/getting-started/installation' },
              { text: '2. Configurer la Clé API', link: '/fr/getting-started/configuration' },
              { text: '3. Démarrage Rapide', link: '/fr/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 Workflow Principal',
            collapsed: false,
            items: [
              { text: 'Chat, Contexte et Nœuds', link: '/fr/core-features/chat-context' },
              { text: 'Diff : Révision de Code', link: '/fr/core-features/diff-apply' },
              { text: 'Mode Watch (Auto-Fix)', link: '/fr/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 Connaissance et DB',
            collapsed: false,
            items: [
              { text: 'Index Codebase (Vector DB)', link: '/fr/memory/vector-db' },
              { text: 'Les 25 Skills (Catalogue)', link: '/fr/memory/skills' },
              { text: 'Mémoire Persistante', link: '/fr/memory/persistent' }
            ]
          },
          {
            text: '🚀 Outils et Référence',
            collapsed: false,
            items: [
              { text: 'Guide complet de l\'interface', link: '/fr/advanced/ui-guide' },
              { text: 'Les 27 outils de l\'IA', link: '/fr/advanced/tools-reference' },
              { text: 'Onglet Git et GitHub', link: '/fr/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/fr/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Publié sous licence MIT.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Page précédente', next: 'Page suivante' },
        outline: { label: 'Sur cette page', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              fr: {
                translations: {
                  button: { buttonText: 'Rechercher', buttonAriaLabel: 'Rechercher' },
                  modal: {
                    noResultsText: 'Aucun résultat pour',
                    resetButtonTitle: 'Effacer la recherche',
                    footer: { selectText: 'pour sélectionner', navigateText: 'pour naviguer', closeText: 'pour fermer' }
                  }
                }
              }
            }
          }
        }
      }
    },
    de: {
      label: 'Deutsch',
      lang: 'de',
      description: "Die autonome KI im Herzen von Godot 4.",
      themeConfig: {
        nav: [
          { text: 'Startseite', link: '/de/' },
          { text: 'Guide', link: '/de/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ Erste Schritte',
            collapsed: false,
            items: [
              { text: '1. Installation', link: '/de/getting-started/installation' },
              { text: '2. API-Key konfigurieren', link: '/de/getting-started/configuration' },
              { text: '3. Schnellstart', link: '/de/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 Haupt-Workflow',
            collapsed: false,
            items: [
              { text: 'Chat, Kontext und Nodes', link: '/de/core-features/chat-context' },
              { text: 'Diff: Code-Review', link: '/de/core-features/diff-apply' },
              { text: 'Watch-Modus (Auto-Fix)', link: '/de/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 Wissen und DB',
            collapsed: false,
            items: [
              { text: 'Index Codebase (Vector DB)', link: '/de/memory/vector-db' },
              { text: 'Die 25 Skills (Katalog)', link: '/de/memory/skills' },
              { text: 'Persistente Memory', link: '/de/memory/persistent' }
            ]
          },
          {
            text: '🚀 Tools und Referenz',
            collapsed: false,
            items: [
              { text: 'Vollständiger UI-Guide', link: '/de/advanced/ui-guide' },
              { text: 'Die 27 KI-Tools', link: '/de/advanced/tools-reference' },
              { text: 'Git und GitHub Tab', link: '/de/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/de/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Veröffentlicht unter der MIT-Lizenz.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Vorherige Seite', next: 'Nächste Seite' },
        outline: { label: 'Auf dieser Seite', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              de: {
                translations: {
                  button: { buttonText: 'Suchen', buttonAriaLabel: 'Suchen' },
                  modal: {
                    noResultsText: 'Keine Ergebnisse für',
                    resetButtonTitle: 'Suche zurücksetzen',
                    footer: { selectText: 'auswählen', navigateText: 'navigieren', closeText: 'schließen' }
                  }
                }
              }
            }
          }
        }
      }
    },
    hi: {
      label: 'हिन्दी',
      lang: 'hi',
      description: "Godot 4 के केंद्र में रहने वाली स्वायत्त एआई।",
      themeConfig: {
        nav: [
          { text: 'मुख्य पृष्ठ', link: '/hi/' },
          { text: 'गाइड', link: '/hi/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ शुरुआती चरण',
            collapsed: false,
            items: [
              { text: '1. इंस्टॉलेशन', link: '/hi/getting-started/installation' },
              { text: '2. एपीआई कुंजी कॉन्फ़िगर करें', link: '/hi/getting-started/configuration' },
              { text: '3. त्वरित शुरुआत', link: '/hi/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 मुख्य वर्कफ़्लो',
            collapsed: false,
            items: [
              { text: 'चैट, संदर्भ और नोड्स', link: '/hi/core-features/chat-context' },
              { text: 'Diff: कोड समीक्षा', link: '/hi/core-features/diff-apply' },
              { text: 'वॉच मोड (ऑटो-फिक्स)', link: '/hi/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 ज्ञान और डीबी',
            collapsed: false,
            items: [
              { text: 'इंडेक्स कोडबेस (Vector DB)', link: '/hi/memory/vector-db' },
              { text: '25 कौशल (कैटलॉग)', link: '/hi/memory/skills' },
              { text: 'स्थायी मेमोरी', link: '/hi/memory/persistent' }
            ]
          },
          {
            text: '🚀 टूल्स और संदर्भ',
            collapsed: false,
            items: [
              { text: 'पूर्ण यूआई गाइड', link: '/hi/advanced/ui-guide' },
              { text: '27 एआई टूल्स', link: '/hi/advanced/tools-reference' },
              { text: 'Git और GitHub टैब', link: '/hi/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/hi/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'MIT लाइसेंस के तहत प्रकाशित।',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'पिछला पृष्ठ', next: 'अगला पृष्ठ' },
        outline: { label: 'इस पृष्ठ पर', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              hi: {
                translations: {
                  button: { buttonText: 'खोजें', buttonAriaLabel: 'खोजें' },
                  modal: {
                    noResultsText: 'इसके लिए कोई परिणाम नहीं',
                    resetButtonTitle: 'खोज रीसेट करें',
                    footer: { selectText: 'चुनने के लिए', navigateText: 'नेविगेट करने के लिए', closeText: 'बंद करने के लिए' }
                  }
                }
              }
            }
          }
        }
      }
    },
    zh_CN: {
      label: '简体中文',
      lang: 'zh-CN',
      description: "位于 Godot 4 核心的自主 AI。",
      themeConfig: {
        nav: [
          { text: '首页', link: '/zh_CN/' },
          { text: '指南', link: '/zh_CN/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ 开始使用',
            collapsed: false,
            items: [
              { text: '1. 安装', link: '/zh_CN/getting-started/installation' },
              { text: '2. 配置 API 密钥', link: '/zh_CN/getting-started/configuration' },
              { text: '3. 快速开始', link: '/zh_CN/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 核心工作流',
            collapsed: false,
            items: [
              { text: '聊天、上下文和节点', link: '/zh_CN/core-features/chat-context' },
              { text: '差异：代码审查', link: '/zh_CN/core-features/diff-apply' },
              { text: '观察模式 (自动修复)', link: '/zh_CN/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 知识与数据库',
            collapsed: false,
            items: [
              { text: '索引代码库 (Vector DB)', link: '/zh_CN/memory/vector-db' },
              { text: '25 项技能 (目录)', link: '/zh_CN/memory/skills' },
              { text: '持久记忆', link: '/zh_CN/memory/persistent' }
            ]
          },
          {
            text: '🚀 工具与参考',
            collapsed: false,
            items: [
              { text: '完整 UI 指南', link: '/zh_CN/advanced/ui-guide' },
              { text: '27 项 AI 工具', link: '/zh_CN/advanced/tools-reference' },
              { text: 'Git 与 GitHub 标签', link: '/zh_CN/advanced/git-github' },
              { text: '自定义系统提示', link: '/zh_CN/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: '基于 MIT 许可发布。',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: '上一页', next: '下一页' },
        outline: { label: '本页内容', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              zh_CN: {
                translations: {
                  button: { buttonText: '搜索', buttonAriaLabel: '搜索' },
                  modal: {
                    noResultsText: '无相关结果',
                    resetButtonTitle: '清除查询',
                    footer: { selectText: '选择', navigateText: '切换', closeText: '关闭' }
                  }
                }
              }
            }
          }
        }
      }
    },
    ar: {
      label: 'العربية',
      lang: 'ar',
      description: "ذكاء اصطناعي مستقل في قلب Godot 4.",
      themeConfig: {
        nav: [
          { text: 'الرئيسية', link: '/ar/' },
          { text: 'الدليل', link: '/ar/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ خطوات البداية',
            collapsed: false,
            items: [
              { text: '1. التثبيت', link: '/ar/getting-started/installation' },
              { text: '2. تكوين مفتاح API', link: '/ar/getting-started/configuration' },
              { text: '3. البدء السريع', link: '/ar/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 سير العمل الرئيسي',
            collapsed: false,
            items: [
              { text: 'الدردشة والسياق والعقد', link: '/ar/core-features/chat-context' },
              { text: 'Diff: مراجعة الكود', link: '/ar/core-features/diff-apply' },
              { text: 'وضع المراقبة (الإصلاح التلقائي)', link: '/ar/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 المعرفة وقاعدة البيانات',
            collapsed: false,
            items: [
              { text: 'فهرسة الكود (Vector DB)', link: '/ar/memory/vector-db' },
              { text: '25 مهارة (الكتالوج)', link: '/ar/memory/skills' },
              { text: 'الذاكرة الدائمة', link: '/ar/memory/persistent' }
            ]
          },
          {
            text: '🚀 الأدوات والمرجع',
            collapsed: false,
            items: [
              { text: 'دليل واجهة المستخدم الكامل', link: '/ar/advanced/ui-guide' },
              { text: '27 أداة ذكاء اصطناعي', link: '/ar/advanced/tools-reference' },
              { text: 'علامة تبويب Git و GitHub', link: '/ar/advanced/git-github' },
              { text: 'مطالبة النظام المخصصة', link: '/ar/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'نشر بموجب ترخيص MIT.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'الصفحة السابقة', next: 'الصفحة التالية' },
        outline: { label: 'في هذه الصفحة', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              ar: {
                translations: {
                  button: { buttonText: 'بحث', buttonAriaLabel: 'بحث' },
                  modal: {
                    noResultsText: 'لا توجد نتائج لـ',
                    resetButtonTitle: 'إعادة ضبط البحث',
                    footer: { selectText: 'للاختيار', navigateText: 'للتنقل', closeText: 'للإغلاق' }
                  }
                }
              }
            }
          }
        }
      }
    },
    ru: {
      label: 'Русский',
      lang: 'ru',
      description: "Автономный ИИ в сердце Godot 4.",
      themeConfig: {
        nav: [
          { text: 'Главная', link: '/ru/' },
          { text: 'Руководство', link: '/ru/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ Первые шаги',
            collapsed: false,
            items: [
              { text: '1. Установка', link: '/ru/getting-started/installation' },
              { text: '2. Настройка ключа API', link: '/ru/getting-started/configuration' },
              { text: '3. Быстрый старт', link: '/ru/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 Основной рабочий процесс',
            collapsed: false,
            items: [
              { text: 'Чат, контекст и узлы', link: '/ru/core-features/chat-context' },
              { text: 'Diff: Обзор кода', link: '/ru/core-features/diff-apply' },
              { text: 'Режим наблюдения (Auto-Fix)', link: '/ru/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 Знания и база данных',
            collapsed: false,
            items: [
              { text: 'Индексация кода (Vector DB)', link: '/ru/memory/vector-db' },
              { text: '25 навыков (Каталог)', link: '/ru/memory/skills' },
              { text: 'Персистентная память', link: '/ru/memory/persistent' }
            ]
          },
          {
            text: '🚀 Инструменты и справочник',
            collapsed: false,
            items: [
              { text: 'Полное руководство по UI', link: '/ru/advanced/ui-guide' },
              { text: '27 инструментов ИИ', link: '/ru/advanced/tools-reference' },
              { text: 'Вкладка Git и GitHub', link: '/ru/advanced/git-github' },
              { text: 'Пользовательский системный промпт', link: '/ru/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Опубликовано под лицензией MIT.',
          copyright: 'Copyright © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Предыдущая страница', next: 'Следующая страница' },
        outline: { label: 'На этой странице', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              ru: {
                translations: {
                  button: { buttonText: 'Поиск', buttonAriaLabel: 'Поиск' },
                  modal: {
                    noResultsText: 'Нет результатов по запросу',
                    resetButtonTitle: 'Сбросить поиск',
                    footer: { selectText: 'выбрать', navigateText: 'навигация', closeText: 'закрыть' }
                  }
                }
              }
            }
          }
        }
      }
    },
    bn: {
      label: 'বাংলা',
      lang: 'bn',
      description: "Godot 4.6 এর জন্য স্বায়ত্তশাসিত AI অ্যাসিস্ট্যান্ট।",
      themeConfig: {
        nav: [
          { text: 'হোম', link: '/bn/' },
          { text: 'গাইড', link: '/bn/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ প্রথম পদক্ষেপ',
            collapsed: false,
            items: [
              { text: '১. ইনস্টলেশন', link: '/bn/getting-started/installation' },
              { text: '২. API কী কনফিগারেশন', link: '/bn/getting-started/configuration' },
              { text: '৩. কুইক স্টার্ট', link: '/bn/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 প্রধান কাজের ধারা',
            collapsed: false,
            items: [
              { text: 'চ্যাট, কন্টেক্সট এবং নোড', link: '/bn/core-features/chat-context' },
              { text: 'Diff: কোড রিভিউ', link: '/bn/core-features/diff-apply' },
              { text: 'ওয়াচ মোড (Auto-Fix)', link: '/bn/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 নলেজ এবং ডাটাবেস',
            collapsed: false,
            items: [
              { text: 'কোড ইনডেক্সিং (Vector DB)', link: '/bn/memory/vector-db' },
              { text: '২৫টি দক্ষতা (ক্যাটালগ)', link: '/bn/memory/skills' },
              { text: 'পারসিস্টেন্ট মেমরি', link: '/bn/memory/persistent' }
            ]
          },
          {
            text: '🚀 টুলস এবং справочник',
            collapsed: false,
            items: [
              { text: 'সম্পূর্ণ UI গাইড', link: '/bn/advanced/ui-guide' },
              { text: '২৭টি AI টুলস', link: '/bn/advanced/tools-reference' },
              { text: 'Git এবং GitHub ট্যাব', link: '/bn/advanced/git-github' },
              { text: 'কাস্টম সিস্টেম প্রম্পট', link: '/bn/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'MIT লাইসেন্সের অধীনে মুক্তি পেয়েছে।',
          copyright: 'কপিরাইট © ২০২৬ - Gamedev AI'
        },
        docFooter: { prev: 'পূর্ববর্তী পৃষ্ঠা', next: 'পরবর্তী পৃষ্ঠা' },
        outline: { label: 'এই পৃষ্ঠায়', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              bn: {
                translations: {
                  button: { buttonText: 'সার্চ', buttonAriaLabel: 'সার্চ' },
                  modal: {
                    noResultsText: 'ফলাফল পাওয়া যায়নি',
                    resetButtonTitle: 'সার্চ রিসেট করুন',
                    footer: { selectText: 'সিলেক্ট', navigateText: 'ন্যাভিগেট', closeText: 'বন্ধ করুন' }
                  }
                }
              }
            }
          }
        }
      }
    },
    id: {
      label: 'Bahasa Indonesia',
      lang: 'id',
      description: "Software Engineer Otonom untuk Godot 4.6.",
      themeConfig: {
        nav: [
          { text: 'Beranda', link: '/id/' },
          { text: 'Panduan', link: '/id/getting-started/installation' }
        ],
        sidebar: [
          {
            text: '🛠️ Langkah Pertama',
            collapsed: false,
            items: [
              { text: '1. Instalasi', link: '/id/getting-started/installation' },
              { text: '2. Konfigurasi Kunci API', link: '/id/getting-started/configuration' },
              { text: '3. Mulai Cepat', link: '/id/getting-started/quick-start' }
            ]
          },
          {
            text: '💡 Alur Kerja Utama',
            collapsed: false,
            items: [
              { text: 'Chat, Konteks, dan Node', link: '/id/core-features/chat-context' },
              { text: 'Diff: Peninjauan Kode', link: '/id/core-features/diff-apply' },
              { text: 'Watch Mode (Auto-Fix)', link: '/id/core-features/watch-mode' }
            ]
          },
          {
            text: '🧠 Pengetahuan dan Basis Data',
            collapsed: false,
            items: [
              { text: 'Indexing Kode (Vector DB)', link: '/id/memory/vector-db' },
              { text: '25 Keahlian (Katalog)', link: '/id/memory/skills' },
              { text: 'Memori Persisten', link: '/id/memory/persistent' }
            ]
          },
          {
            text: '🚀 Alat dan Referensi',
            collapsed: false,
            items: [
              { text: 'Panduan UI Lengkap', link: '/id/advanced/ui-guide' },
              { text: '27 Alat AI', link: '/id/advanced/tools-reference' },
              { text: 'Tab Git dan GitHub', link: '/id/advanced/git-github' },
              { text: 'Custom System Prompt', link: '/id/advanced/custom-prompts' }
            ]
          }
        ],
        footer: {
          message: 'Dirilis di bawah Lisensi MIT.',
          copyright: 'Hak Cipta © 2026 - Gamedev AI'
        },
        docFooter: { prev: 'Halaman sebelumnya', next: 'Halaman selanjutnya' },
        outline: { label: 'Di halaman ini', level: [2, 3] },
        search: {
          provider: 'local',
          options: {
            locales: {
              id: {
                translations: {
                  button: { buttonText: 'Cari', buttonAriaLabel: 'Cari' },
                  modal: {
                    noResultsText: 'Tidak ada hasil yang ditemukan',
                    resetButtonTitle: 'Atur ulang pencarian',
                    footer: { selectText: 'Pilih', navigateText: 'Navigasi', closeText: 'Tutup' }
                  }
                }
              }
            }
          }
        }
      }
    }
  },

  themeConfig: {
    logo: '/images/gamedevAi_logo.png',
    siteTitle: false,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/fredarts/gamedev_ai' }
    ]
  }
})
