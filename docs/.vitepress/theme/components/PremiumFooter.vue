<script setup>
import { useData } from 'vitepress'
import { computed } from 'vue'

const { localeIndex, theme, site } = useData()

// Dicionário de traduções para o Footer
const translations = {
  root: { product: 'Produto', resources: 'Recursos', community: 'Comunidade', installation: 'Instalação', quickStart: 'Guia Rápido', config: 'Configuração', tools: 'Ferramentas', ui: 'Interface', git: 'Git & GitHub', support: 'Apoie o Projeto', bugs: 'Reportar Bug', contribute: 'Contribuir', license: 'Distribuído sob a Licença MIT. Criado por Fred Arts.', copyright: '© 2026 Gamedev AI. Todos os direitos reservados.' },
  en: { product: 'Product', resources: 'Resources', community: 'Community', installation: 'Installation', quickStart: 'Quick Start', config: 'Configuration', tools: 'Tools Reference', ui: 'UI Guide', git: 'Git & GitHub', support: 'Support Project', bugs: 'Report Bug', contribute: 'Contribute', license: 'Released under the MIT License. Created by Fred Arts.', copyright: '© 2026 Gamedev AI. All rights reserved.' },
  es: { product: 'Producto', resources: 'Recursos', community: 'Comunidad', installation: 'Instalación', quickStart: 'Guía Rápida', config: 'Configuración', tools: 'Herramientas', ui: 'Guía de UI', git: 'Git y GitHub', support: 'Apoya el Proyecto', bugs: 'Reportar Error', contribute: 'Contribuir', license: 'Distribuido bajo la Licencia MIT. Creado por Fred Arts.', copyright: '© 2026 Gamedev AI. Todos los derechos reservados.' },
  fr: { product: 'Produit', resources: 'Ressources', community: 'Communauté', installation: 'Installation', quickStart: 'Démarrage rapide', config: 'Configuration', tools: 'Référence outils', ui: 'Guide UI', git: 'Git & GitHub', support: 'Soutenir le projet', bugs: 'Signaler un bug', contribute: 'Contribuer', license: 'Distribué sous licence MIT. Créé par Fred Arts.', copyright: '© 2026 Gamedev AI. Tous droits réservés.' },
  de: { product: 'Produkt', resources: 'Ressourcen', community: 'Community', installation: 'Installation', quickStart: 'Schnellstart', config: 'Konfiguration', tools: 'Werkzeugreferenz', ui: 'UI-Leitfaden', git: 'Git & GitHub', support: 'Projekt unterstützen', bugs: 'Fehler melden', contribute: 'Beitragen', license: 'Veröffentlicht unter der MIT-Lizenz. Erstellt von Fred Arts.', copyright: '© 2026 Gamedev AI. Alle Rechte vorbehalten.' },
  id: { product: 'Produk', resources: 'Sumber Daya', community: 'Komunitas', installation: 'Instalasi', quickStart: 'Panduan Cepat', config: 'Konfigurasi', tools: 'Referensi Alat', ui: 'Panduan UI', git: 'Git & GitHub', support: 'Dukung Proyek', bugs: 'Laporkan Bug', contribute: 'Kontribusi', license: 'Didistribusikan di bawah Lisensi MIT. Dibuat oleh Fred Arts.', copyright: '© 2026 Gamedev AI. Hak Cipta Dilindungi Undang-Undang.' },
  hi: { product: 'उत्पाद', resources: 'संसाधन', community: 'समुदाय', installation: 'स्थापना', quickStart: 'त्वरित प्रारंभ', config: 'कॉन्फ़िगरेशन', tools: 'उपकरण संदर्भ', ui: 'UI गाइड', git: 'Git और GitHub', support: 'परियोजना का समर्थन करें', bugs: 'बग रिपोर्ट करें', contribute: 'योगदान करें', license: 'MIT लाइसेंस के तहत जारी। फ्रेड आर्ट्स द्वारा बनाया गया।', copyright: '© 2026 Gamedev AI। सर्वाधिकार सुरक्षित।' },
  zh_CN: { product: '产品', resources: '资源', community: '社区', installation: '安装', quickStart: '快速开始', config: '配置', tools: '工具参考', ui: 'UI 指南', git: 'Git 和 GitHub', support: '支持项目', bugs: '报告错误', contribute: '贡献', license: '根据 MIT 许可证分发。由 Fred Arts 创建。', copyright: '© 2026 Gamedev AI。保留所有权利。' },
  ar: { product: 'المنتج', resources: 'الموارد', community: 'المجتمع', installation: 'التثبيت', quickStart: 'البدء السريع', config: 'الإعداد', tools: 'مرجع الأدوات', ui: 'دليل الواجهة', git: 'Git و GitHub', support: 'دعم المشروع', bugs: 'الإبلاغ عن خطأ', contribute: 'المساهمة', license: 'تم إصداره تحت رخصة MIT. أنشأه فريد آرتس.', copyright: '© 2026 Gamedev AI. جميع الحقوق محفوظة.' },
  ru: { product: 'Продукт', resources: 'Ресурсы', community: 'Сообщество', installation: 'Установка', quickStart: 'Быстрый старт', config: 'Настройка', tools: 'Справочник инструментов', ui: 'Руководство по UI', git: 'Git и GitHub', support: 'Поддержать проект', bugs: 'Сообщить об ошибке', contribute: 'Внести вклад', license: 'Распространяется под лицензией MIT. Создано Фредом Артсом.', copyright: '© 2026 Gamedev AI. Все права защищены.' },
  bn: { product: 'পণ্য', resources: 'রিসোর্স', community: 'কমিউনিটি', installation: 'ইনস্টলেশন', quickStart: 'কুইক স্টার্ট', config: 'কনফিগারেশন', tools: 'টুল রেফারেন্স', ui: 'ইউআই গাইড', git: 'গিট ও গিটহাব', support: 'প্রকল্প সমর্থন করুন', bugs: 'বাগ রিপোর্ট করুন', contribute: 'অবদান রাখুন', license: 'MIT লাইসেন্সের অধীনে প্রকাশিত। ফ্রেড আর্টস দ্বারা তৈরি।', copyright: '© 2026 Gamedev AI। সর্বস্বত্ব সংরক্ষিত।' }
}

const t = computed(() => translations[localeIndex.value] || translations.root)

const pathPrefix = computed(() => {
  return localeIndex.value === 'root' ? '' : `/${localeIndex.value}`
})
</script>

<template>
  <footer class="premium-footer">
    <div class="footer-container">
      <div class="footer-grid">
        
        <!-- Brand Section -->
        <div class="footer-section brand">
          <img src="/images/gamedevAi_logo.png" alt="Gamedev AI Logo" class="footer-logo" />
          <p class="tagline">{{ site.description }}</p>
          <div class="social-links">
            <a href="https://github.com/fredarts/gamedev_ai" target="_blank" class="social-icon">
              <svg viewBox="0 0 24 24" class="icon"><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>
            </a>
          </div>
        </div>

        <!-- Links Sections -->
        <div class="footer-section">
          <h3>{{ t.product }}</h3>
          <ul>
            <li><a :href="`${pathPrefix}/getting-started/installation`">{{ t.installation }}</a></li>
            <li><a :href="`${pathPrefix}/getting-started/quick-start`">{{ t.quickStart }}</a></li>
            <li><a :href="`${pathPrefix}/getting-started/configuration`">{{ t.config }}</a></li>
          </ul>
        </div>

        <div class="footer-section">
          <h3>{{ t.resources }}</h3>
          <ul>
            <li><a :href="`${pathPrefix}/advanced/tools-reference`">{{ t.tools }}</a></li>
            <li><a :href="`${pathPrefix}/advanced/ui-guide`">{{ t.ui }}</a></li>
            <li><a :href="`${pathPrefix}/advanced/git-github`">{{ t.git }}</a></li>
          </ul>
        </div>

        <div class="footer-section">
          <h3>{{ t.community }}</h3>
          <ul>
            <li><a :href="`${pathPrefix}/support`">{{ t.support }}</a></li>
            <li><a href="https://github.com/fredarts/gamedev_ai/issues">{{ t.bugs }}</a></li>
            <li><a href="https://github.com/fredarts/gamedev_ai/pulls">{{ t.contribute }}</a></li>
          </ul>
        </div>

      </div>

      <div class="footer-bottom">
        <p>{{ t.license }}</p>
        <p class="copyright">{{ t.copyright }}</p>
      </div>
    </div>
  </footer>
</template>

<style scoped>
.premium-footer {
  background-color: #161618;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  padding: 80px 24px 40px;
  position: relative;
  z-index: 10;
  backdrop-filter: blur(20px);
}

.footer-container {
  max-width: 1152px;
  margin: 0 auto;
}

.footer-grid {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr 1fr;
  gap: 40px;
  margin-bottom: 60px;
}

.footer-section h3 {
  font-size: 1rem;
  font-weight: 700;
  margin-bottom: 24px;
  color: #fff;
  letter-spacing: 0.05em;
}

.footer-section ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.footer-section ul li {
  margin-bottom: 12px;
}

.footer-section ul li a {
  color: var(--vp-c-text-2);
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.3s, transform 0.3s;
  display: inline-block;
}

.footer-section ul li a:hover {
  color: #00bae3;
  transform: translateX(4px);
}

.tagline {
  color: var(--vp-c-text-2);
  font-size: 0.95rem;
  margin-top: 16px;
  max-width: 250px;
  line-height: 1.5;
}

.footer-logo {
  height: 40px;
  filter: drop-shadow(0 0 8px rgba(0, 186, 227, 0.3));
}

.social-links {
  margin-top: 24px;
  display: flex;
  gap: 16px;
}

.social-icon {
  width: 40px;
  height: 40px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 50%;
  display: flex;
  justify-content: center;
  align-items: center;
  transition: all 0.3s;
}

.social-icon:hover {
  background: rgba(0, 186, 227, 0.1);
  border-color: #00bae3;
  box-shadow: 0 0 15px rgba(0, 186, 227, 0.3);
  transform: translateY(-3px);
}

.icon {
  width: 20px;
  height: 20px;
  fill: var(--vp-c-text-2);
  transition: fill 0.3s;
}

.social-icon:hover .icon {
  fill: #00bae3;
}

.footer-bottom {
  padding-top: 40px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #555;
  font-size: 0.85rem;
}

@media (max-width: 960px) {
  .footer-grid {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 640px) {
  .footer-grid {
    grid-template-columns: 1fr;
    text-align: center;
  }
  .tagline { margin: 16px auto; }
  .social-links { justify-content: center; }
  .footer-bottom {
    flex-direction: column;
    gap: 12px;
    text-align: center;
  }
}
</style>
