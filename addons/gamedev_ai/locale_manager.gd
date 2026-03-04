@tool
extends RefCounted
class_name LocaleManager

var _current_locale: String = "en"

# Display names for the language selector
const LOCALE_DISPLAY_NAMES: Dictionary = {
	"en": "English",
	"pt_BR": "Português (BR)",
	"es": "Español",
	"fr": "Français",
	"de": "Deutsch",
	"hi": "हिन्दी",
	"zh_CN": "简体中文",
	"ar": "العربية",
	"ru": "Русский",
	"bn": "বাংলা",
	"id": "Bahasa Indonesia"
}

# Full language names for AI prompt injection
const LOCALE_AI_NAMES: Dictionary = {
	"en": "English",
	"pt_BR": "Portuguese (Brazilian)",
	"es": "Spanish",
	"fr": "French",
	"de": "German",
	"hi": "Hindi",
	"zh_CN": "Simplified Chinese",
	"ar": "Arabic",
	"ru": "Russian",
	"bn": "Bengali",
	"id": "Indonesian"
}

# All translations keyed by string ID
var _translations: Dictionary = {}

func _init():
	_build_translations()

func set_locale(locale_code: String):
	if LOCALE_DISPLAY_NAMES.has(locale_code):
		_current_locale = locale_code

func get_locale() -> String:
	return _current_locale

func get_available_locales() -> Array:
	var result = []
	for code in LOCALE_DISPLAY_NAMES.keys():
		result.append({"code": code, "name": LOCALE_DISPLAY_NAMES[code]})
	return result

func tr(message: StringName, context: StringName = &"") -> String:
	var key = String(message)
	if _translations.has(key):
		var entry = _translations[key]
		if entry.has(_current_locale):
			return entry[_current_locale]
		if entry.has("en"):
			return entry["en"]
	return key

func get_ai_language_instruction() -> String:
	if _current_locale == "en":
		return ""
	var lang_name = LOCALE_AI_NAMES.get(_current_locale, "English")
	return "You MUST write ALL of your responses in " + lang_name + ". This includes explanations, comments in code, commit messages, error descriptions, and suggestions. Only keep code syntax (GDScript keywords, function names, API names) in English."

func _build_translations():
	# ─── Chat Tab ───
	_t("new_chat", "New Chat", "Novo Chat", "Nuevo Chat", "Nouveau Chat", "Neuer Chat", "नई चैट", "新聊天", "محادثة جديدة", "Новый чат", "নতুন চ্যাট", "Chat Baru")
	_t("history", "History", "Histórico", "Historial", "Historique", "Verlauf", "इतिहास", "历史记录", "السجل", "История", "ইতিহাস", "Riwayat")
	_t("send", "Send", "Enviar", "Enviar", "Envoyer", "Senden", "भेजें", "发送", "إرسال", "Отправить", "পাঠান", "Kirim")
	_t("stop", "⏹ Stop", "⏹ Parar", "⏹ Detener", "⏹ Arrêter", "⏹ Stopp", "⏹ रुकें", "⏹ 停止", "⏹ إيقاف", "⏹ Стоп", "⏹ থামুন", "⏹ Berhenti")
	_t("no_selection", "No selection", "Sem seleção", "Sin selección", "Aucune sélection", "Keine Auswahl", "कोई चयन नहीं", "无选择", "لا يوجد تحديد", "Нет выделения", "কোনো নির্বাচন নেই", "Tidak ada pilihan")
	_t("selection_prefix", "Selection: ", "Seleção: ", "Selección: ", "Sélection : ", "Auswahl: ", "चयन: ", "选择: ", "التحديد: ", "Выделение: ", "নির্বাচন: ", "Pilihan: ")
	_t("input_placeholder", "Ask Gamedev AI... (Shift+Enter to send)", "Pergunte ao Gamedev AI... (Shift+Enter para enviar)", "Pregunta a Gamedev AI... (Shift+Enter para enviar)", "Demandez à Gamedev AI... (Shift+Entrée pour envoyer)", "Frage Gamedev AI... (Shift+Enter zum Senden)", "Gamedev AI से पूछें... (भेजने के लिए Shift+Enter)", "询问 Gamedev AI...(Shift+Enter 发送)", "اسأل Gamedev AI... (Shift+Enter للإرسال)", "Спросите Gamedev AI... (Shift+Enter для отправки)", "Gamedev AI কে জিজ্ঞাসা করুন... (পাঠাতে Shift+Enter)", "Tanya Gamedev AI... (Shift+Enter untuk kirim)")
	_t("thinking", "Thinking...", "Pensando...", "Pensando...", "Réflexion...", "Nachdenken...", "सोच रहा है...", "思考中...", "جارٍ التفكير...", "Думаю...", "ভাবছি...", "Berpikir...")
	_t("response_label", "Response:", "Resposta:", "Respuesta:", "Réponse :", "Antwort:", "प्रतिक्रिया:", "回复:", "الرد:", "Ответ:", "প্রতিক্রিয়া:", "Respons:")
	_t("you_label", "You:", "Você:", "Tú:", "Vous :", "Du:", "आप:", "你:", "أنت:", "Вы:", "আপনি:", "Anda:")
	_t("sending_attachments", "Sending attachments...", "Enviando anexos...", "Enviando archivos...", "Envoi des pièces jointes...", "Anhänge werden gesendet...", "अटैचमेंट भेजे जा रहे हैं...", "正在发送附件...", "جارٍ إرسال المرفقات...", "Отправка вложений...", "সংযুক্তি পাঠানো হচ্ছে...", "Mengirim lampiran...")
	_t("capturing_screenshot", "Capturing screenshot...", "Capturando screenshot...", "Capturando pantalla...", "Capture d'écran...", "Screenshot wird aufgenommen...", "स्क्रीनशॉट ले रहे हैं...", "正在截图...", "جارٍ التقاط لقطة...", "Снимок экрана...", "স্ক্রিনশট নেওয়া হচ্ছে...", "Mengambil tangkapan layar...")
	_t("image_pasted", "Image pasted from clipboard.", "Imagem colada da área de transferência.", "Imagen pegada del portapapeles.", "Image collée depuis le presse-papiers.", "Bild aus Zwischenablage eingefügt.", "क्लिपबोर्ड से छवि चिपकाई गई।", "已从剪贴板粘贴图片。", "تم لصق الصورة من الحافظة.", "Изображение вставлено из буфера.", "ক্লিপবোর্ড থেকে ছবি পেস্ট করা হয়েছে।", "Gambar ditempel dari clipboard.")
	_t("image_attached", "Image attached from file: ", "Imagem anexada do arquivo: ", "Imagen adjunta del archivo: ", "Image jointe depuis : ", "Bild angehängt: ", "फ़ाइल से छवि संलग्न: ", "已从文件附加图片: ", "تم إرفاق الصورة من الملف: ", "Изображение прикреплено: ", "ফাইল থেকে ছবি সংযুক্ত: ", "Gambar dilampirkan dari file: ")
	_t("text_file_attached", "Text file attached: ", "Arquivo de texto anexado: ", "Archivo de texto adjunto: ", "Fichier texte joint : ", "Textdatei angehängt: ", "टेक्स्ट फ़ाइल संलग्न: ", "已附加文本文件: ", "تم إرفاق ملف نصي: ", "Текстовый файл прикреплён: ", "টেক্সট ফাইল সংযুক্ত: ", "File teks dilampirkan: ")
	_t("file_attached", "File attached: ", "Arquivo anexado: ", "Archivo adjunto: ", "Fichier joint : ", "Datei angehängt: ", "फ़ाइल संलग्न: ", "已附加文件: ", "تم إرفاق ملف: ", "Файл прикреплён: ", "ফাইল সংযুক্ত: ", "File dilampirkan: ")
	_t("failed_load_image", "Failed to load image at: ", "Falha ao carregar imagem em: ", "Error al cargar imagen en: ", "Impossible de charger l'image : ", "Bild konnte nicht geladen werden: ", "छवि लोड करने में विफल: ", "加载图片失败: ", "فشل تحميل الصورة: ", "Не удалось загрузить: ", "ছবি লোড করতে ব্যর্থ: ", "Gagal memuat gambar: ")
	_t("attachment_removed", "Attachment removed.", "Anexo removido.", "Adjunto eliminado.", "Pièce jointe supprimée.", "Anhang entfernt.", "अटैचमेंट हटाया गया।", "附件已移除。", "تمت إزالة المرفق.", "Вложение удалено.", "সংযুক্তি সরানো হয়েছে।", "Lampiran dihapus.")
	_t("new_chat_started", "--- New Chat Started ---", "--- Novo Chat Iniciado ---", "--- Nuevo Chat Iniciado ---", "--- Nouveau Chat ---", "--- Neuer Chat ---", "--- नई चैट शुरू ---", "--- 新聊天已开始 ---", "--- محادثة جديدة ---", "--- Новый чат ---", "--- নতুন চ্যাট শুরু ---", "--- Chat Baru Dimulai ---")
	_t("chat_loaded", "--- Chat Loaded: ", "--- Chat Carregado: ", "--- Chat Cargado: ", "--- Chat Chargé : ", "--- Chat Geladen: ", "--- चैट लोड: ", "--- 聊天已加载: ", "--- تم تحميل المحادثة: ", "--- Чат загружен: ", "--- চ্যাট লোড হয়েছে: ", "--- Chat Dimuat: ")
	_t("ai_stopped", "⏹ AI stopped by user.", "⏹ IA parada pelo usuário.", "⏹ IA detenida por el usuario.", "⏹ IA arrêtée par l'utilisateur.", "⏹ KI vom Benutzer gestoppt.", "⏹ AI उपयोगकर्ता द्वारा रोका गया।", "⏹ AI 已被用户停止。", "⏹ أوقف المستخدم الذكاء الاصطناعي.", "⏹ ИИ остановлен.", "⏹ ব্যবহারকারী AI বন্ধ করেছে।", "⏹ AI dihentikan oleh pengguna.")
	_t("undoing_last", "Undoing last action...", "Desfazendo última ação...", "Deshaciendo última acción...", "Annulation...", "Letzte Aktion rückgängig...", "अंतिम क्रिया पूर्ववत...", "正在撤销上一步操作...", "جارٍ التراجع...", "Отмена последнего...", "শেষ কাজ পূর্বাবস্থায় ফিরছে...", "Membatalkan tindakan terakhir...")
	_t("no_errors_found", "No recent errors found in the console logs.", "Nenhum erro recente encontrado nos logs do console.", "No se encontraron errores recientes en la consola.", "Aucune erreur récente dans les logs.", "Keine aktuellen Fehler in den Logs.", "कंसोल लॉग में कोई हालिया त्रुटि नहीं।", "控制台日志中未发现错误。", "لم يتم العثور على أخطاء حديثة.", "Ошибок не найдено.", "কনসোল লগে কোনো সাম্প্রতিক ত্রুটি নেই।", "Tidak ada error terbaru di konsol.")
	_t("sending_batch_results", "Sending batch results back to AI...", "Enviando resultados de lote para a IA...", "Enviando resultados al AI...", "Envoi des résultats à l'IA...", "Batch-Ergebnisse an KI senden...", "AI को बैच परिणाम भेजे जा रहे हैं...", "正在将批量结果发回 AI...", "جارٍ إرسال النتائج...", "Отправка результатов ИИ...", "AI-তে ব্যাচ ফলাফল পাঠানো হচ্ছে...", "Mengirim hasil batch ke AI...")
	_t("executing_plan", "Executing Plan...", "Executando Plano...", "Ejecutando Plan...", "Exécution du Plan...", "Plan wird ausgeführt...", "योजना निष्पादित हो रही है...", "正在执行计划...", "جارٍ تنفيذ الخطة...", "Выполнение плана...", "পরিকল্পনা কার্যকর হচ্ছে...", "Menjalankan Rencana...")
	_t("game_running_warning", "Game is running! Close the game before sending commands to the AI, as files may be locked for editing.", "O jogo está rodando! Feche o jogo antes de enviar comandos para a IA.", "¡El juego está ejecutándose! Cierra el juego antes de enviar comandos.", "Le jeu est en cours ! Fermez-le avant d'envoyer des commandes.", "Spiel läuft! Schließe das Spiel bevor du Befehle sendest.", "गेम चल रहा है! AI को कमांड भेजने से पहले गेम बंद करें।", "游戏正在运行！发送命令前请关闭游戏。", "اللعبة قيد التشغيل! أغلقها قبل إرسال الأوامر.", "Игра запущена! Закройте игру перед отправкой.", "গেম চলছে! AI তে কমান্ড পাঠানোর আগে গেম বন্ধ করুন।", "Game sedang berjalan! Tutup game sebelum mengirim perintah.")
	_t("files_attached_label", "Files attached:", "Arquivos anexados:", "Archivos adjuntos:", "Fichiers joints :", "Angehängte Dateien:", "संलग्न फ़ाइलें:", "已附加文件:", "الملفات المرفقة:", "Прикреплённые файлы:", "সংযুক্ত ফাইল:", "File terlampir:")

	# ─── Action Buttons ───
	_t("refactor", "Refactor", "Refatorar", "Refactorizar", "Refactoriser", "Refaktorieren", "रिफैक्टर", "重构", "إعادة هيكلة", "Рефакторинг", "রিফ্যাক্টর", "Refaktor")
	_t("fix", "Fix", "Corrigir", "Corregir", "Corriger", "Beheben", "ठीक करें", "修复", "إصلاح", "Исправить", "ঠিক করুন", "Perbaiki")
	_t("explain", "Explain", "Explicar", "Explicar", "Expliquer", "Erklären", "समझाएँ", "解释", "شرح", "Объяснить", "ব্যাখ্যা", "Jelaskan")
	_t("undo_last", "Undo Last", "Desfazer", "Deshacer", "Annuler", "Rückgängig", "पूर्ववत", "撤销", "تراجع", "Отменить", "পূর্বাবস্থা", "Batalkan")
	_t("fix_console", "Fix Console", "Corrigir Console", "Corregir Consola", "Corriger Console", "Konsole beheben", "कंसोल ठीक करें", "修复控制台", "إصلاح وحدة التحكم", "Консоль", "কনসোল ঠিক", "Perbaiki Konsol")
	_t("run_plan", "Run Plan", "Executar Plano", "Ejecutar Plan", "Exécuter Plan", "Plan ausführen", "योजना चलाएँ", "执行计划", "تنفيذ الخطة", "Запустить план", "পরিকল্পনা চালান", "Jalankan Rencana")

	# ─── Toggles ───
	_t("context", "Context", "Contexto", "Contexto", "Contexte", "Kontext", "संदर्भ", "上下文", "السياق", "Контекст", "প্রসঙ্গ", "Konteks")
	_t("screenshot", "Screenshot", "Captura de Tela", "Captura", "Capture", "Screenshot", "स्क्रीनशॉट", "截图", "لقطة شاشة", "Снимок", "স্ক্রিনশট", "Tangkapan Layar")
	_t("plan_first", "Plan First", "Planejar Antes", "Planificar", "Planifier", "Plan Zuerst", "पहले योजना", "先计划", "خطط أولاً", "Сначала план", "আগে পরিকল্পনা", "Rencana Dulu")
	_t("watch_mode", "Watch Mode", "Modo Vigiar", "Modo Vigilar", "Mode Surveillance", "Überwachung", "वॉच मोड", "监视模式", "وضع المراقبة", "Наблюдение", "পর্যবেক্ষণ", "Mode Pantau")

	# ─── TTS ───
	_t("tts_read_aloud", "▶ Read Aloud", "▶ Ler em Voz Alta", "▶ Leer en Voz Alta", "▶ Lire à Voix Haute", "▶ Vorlesen", "▶ ज़ोर से पढ़ें", "▶ 朗读", "▶ قراءة بصوت عالٍ", "▶ Озвучить", "▶ জোরে পড়ুন", "▶ Baca Keras")
	_t("tts_pause", "⏸ Pause", "⏸ Pausar", "⏸ Pausar", "⏸ Pause", "⏸ Pause", "⏸ रुकें", "⏸ 暂停", "⏸ إيقاف مؤقت", "⏸ Пауза", "⏸ বিরতি", "⏸ Jeda")
	_t("tts_play", "▶ Play", "▶ Tocar", "▶ Reproducir", "▶ Lecture", "▶ Abspielen", "▶ चलाएँ", "▶ 播放", "▶ تشغيل", "▶ Воспр.", "▶ চালান", "▶ Putar")
	_t("tts_loading", "⏳ Loading...", "⏳ Carregando...", "⏳ Cargando...", "⏳ Chargement...", "⏳ Laden...", "⏳ लोड हो रहा है...", "⏳ 加载中...", "⏳ جارٍ التحميل...", "⏳ Загрузка...", "⏳ লোড হচ্ছে...", "⏳ Memuat...")

	# ─── Settings Tab ───
	_t("preset_label", "Preset:", "Predefinição:", "Preajuste:", "Préréglage :", "Voreinstellung:", "प्रीसेट:", "预设:", "الإعداد المسبق:", "Пресет:", "প্রিসেট:", "Preset:")
	_t("add", "Add", "Adicionar", "Añadir", "Ajouter", "Hinzufügen", "जोड़ें", "添加", "إضافة", "Добавить", "যোগ করুন", "Tambah")
	_t("edit", "Edit", "Editar", "Editar", "Modifier", "Bearbeiten", "संपादित", "编辑", "تعديل", "Редакт.", "সম্পাদনা", "Edit")
	_t("delete", "Del", "Excluir", "Eliminar", "Supprimer", "Löschen", "हटाएँ", "删除", "حذف", "Удалить", "মুছুন", "Hapus")
	_t("done_editing", "Done Editing", "Concluir Edição", "Listo", "Terminé", "Fertig", "संपादन पूर्ण", "编辑完成", "تم التعديل", "Готово", "সম্পাদনা শেষ", "Selesai Edit")
	_t("preset_name_label", "Preset Name:", "Nome do Preset:", "Nombre del Preset:", "Nom du Préréglage :", "Preset-Name:", "प्रीसेट नाम:", "预设名称:", "اسم الإعداد:", "Имя пресета:", "প্রিসেট নাম:", "Nama Preset:")
	_t("provider_label", "Provider:", "Provedor:", "Proveedor:", "Fournisseur :", "Anbieter:", "प्रदाता:", "提供者:", "المزود:", "Провайдер:", "প্রদানকারী:", "Penyedia:")
	_t("api_key_label", "API Key:", "Chave da API:", "Clave API:", "Clé API :", "API-Schlüssel:", "API कुंजी:", "API 密钥:", "مفتاح API:", "API-ключ:", "API কী:", "Kunci API:")
	_t("model_name_label", "Model Name:", "Nome do Modelo:", "Nombre del Modelo:", "Nom du Modèle :", "Modellname:", "मॉडल नाम:", "模型名称:", "اسم النموذج:", "Имя модели:", "মডেল নাম:", "Nama Model:")
	_t("base_url_label", "Base URL:", "URL Base:", "URL Base:", "URL de Base :", "Basis-URL:", "बेस URL:", "基础 URL:", "عنوان URL الأساسي:", "Базовый URL:", "বেস URL:", "URL Dasar:")
	_t("custom_instructions_label", "Custom Instructions (appended to system prompt):", "Instruções Personalizadas (adicionadas ao prompt):", "Instrucciones Personalizadas (añadidas al prompt):", "Instructions Personnalisées (ajoutées au prompt) :", "Benutzerdefinierte Anweisungen (zum Prompt hinzugefügt):", "कस्टम निर्देश (सिस्टम प्रॉम्प्ट में जोड़े गए):", "自定义指令（附加到系统提示）:", "تعليمات مخصصة (تُلحق بالموجه):", "Пользовательские инструкции (к системному промпту):", "কাস্টম নির্দেশাবলী (সিস্টেম প্রম্পটে যোগ):", "Instruksi Kustom (ditambahkan ke system prompt):")
	_t("custom_instructions_placeholder", "e.g. Focus on 2D platformer patterns...", "ex. Foque em padrões de plataforma 2D...", "ej. Enfocarse en patrones de plataformas 2D...", "ex. Concentrez-vous sur les motifs de plateformes 2D...", "z.B. Fokus auf 2D-Plattformer-Muster...", "उदा. 2D प्लेटफ़ॉर्मर पैटर्न पर ध्यान दें...", "例如：专注于2D平台游戏模式...", "مثال: التركيز على أنماط ألعاب المنصات...", "напр. Фокус на 2D-платформер...", "যেমন: 2D প্ল্যাটফর্মার প্যাটার্নে ফোকাস...", "mis. Fokus pada pola platformer 2D...")
	_t("language_label", "Language:", "Idioma:", "Idioma:", "Langue :", "Sprache:", "भाषा:", "语言:", "اللغة:", "Язык:", "ভাষা:", "Bahasa:")

	# ─── Git Tab ───
	_t("initialize_repo", "Initialize Repository", "Inicializar Repositório", "Inicializar Repositorio", "Initialiser le Dépôt", "Repository Initialisieren", "रिपॉज़िटरी आरंभ करें", "初始化仓库", "تهيئة المستودع", "Инициализировать репозиторий", "রিপোজিটরি শুরু করুন", "Inisialisasi Repositori")
	_t("github_url_label", "GitHub URL:", "URL do GitHub:", "URL de GitHub:", "URL GitHub :", "GitHub-URL:", "GitHub URL:", "GitHub URL:", "عنوان GitHub:", "URL GitHub:", "GitHub URL:", "URL GitHub:")
	_t("save", "Save", "Salvar", "Guardar", "Enregistrer", "Speichern", "सहेजें", "保存", "حفظ", "Сохранить", "সংরক্ষণ", "Simpan")
	_t("checking_git_status", "Checking Git status...", "Verificando status do Git...", "Verificando estado de Git...", "Vérification du statut Git...", "Git-Status wird geprüft...", "Git स्थिति जाँच रहे हैं...", "正在检查 Git 状态...", "جارٍ التحقق من حالة Git...", "Проверка статуса Git...", "Git অবস্থা পরীক্ষা হচ্ছে...", "Memeriksa status Git...")
	_t("pull", "Pull", "Puxar (Pull)", "Pull", "Pull", "Pull", "Pull", "Pull", "Pull", "Pull", "Pull", "Pull")
	_t("refresh_status", "Refresh Status", "Atualizar Status", "Actualizar Estado", "Actualiser", "Status Aktualisieren", "स्थिति ताज़ा करें", "刷新状态", "تحديث الحالة", "Обновить статус", "স্ট্যাটাস রিফ্রেশ", "Segarkan Status")
	_t("auto_generate_commit", "✨ Auto-Generate Commit Message", "✨ Gerar Mensagem de Commit", "✨ Generar Mensaje de Commit", "✨ Générer Message de Commit", "✨ Commit-Nachricht Generieren", "✨ कमिट संदेश स्वत: बनाएँ", "✨ 自动生成提交信息", "✨ إنشاء رسالة الإيداع تلقائياً", "✨ Сгенерировать сообщение", "✨ কমিট মেসেজ স্বয়ংক্রিয়", "✨ Buat Pesan Commit Otomatis")
	_t("commit_msg_placeholder", "Enter commit message here...", "Digite a mensagem de commit aqui...", "Ingrese el mensaje de commit aquí...", "Entrez le message de commit ici...", "Commit-Nachricht hier eingeben...", "कमिट संदेश यहाँ दर्ज करें...", "在此输入提交信息...", "أدخل رسالة الإيداع هنا...", "Введите сообщение коммита...", "কমিট মেসেজ এখানে লিখুন...", "Masukkan pesan commit di sini...")
	_t("commit_sync", "Commit & Sync (Push)", "Commit e Sincronizar (Push)", "Commit & Sincronizar (Push)", "Commit & Sync (Push)", "Commit & Sync (Push)", "Commit & Sync (Push)", "提交并同步 (Push)", "إيداع ومزامنة (Push)", "Commit & Sync (Push)", "Commit & Sync (Push)", "Commit & Sync (Push)")
	_t("current_branch", "Current Branch: ", "Branch Atual: ", "Rama Actual: ", "Branche Actuelle : ", "Aktueller Branch: ", "वर्तमान ब्रांच: ", "当前分支: ", "الفرع الحالي: ", "Текущая ветка: ", "বর্তমান ব্রাঞ্চ: ", "Cabang Saat Ini: ")
	_t("create_switch", "Create/Switch", "Criar/Trocar", "Crear/Cambiar", "Créer/Changer", "Erstellen/Wechseln", "बनाएँ/बदलें", "创建/切换", "إنشاء/تبديل", "Создать/Переключить", "তৈরি/পরিবর্তন", "Buat/Ganti")
	_t("undo_uncommitted", "Undo Uncommitted Changes", "Desfazer Alterações Não Commitadas", "Deshacer Cambios No Confirmados", "Annuler Changements Non Validés", "Nicht Committete Änderungen Rückgängig", "असहेजे बदलाव पूर्ववत करें", "撤销未提交的更改", "التراجع عن التغييرات غير المحفوظة", "Отменить незакоммиченные", "অসংরক্ষিত পরিবর্তন পূর্বাবস্থা", "Batalkan Perubahan Belum Commit")
	_t("force_pull", "Force Pull Overwrite", "Forçar Pull (Sobrescrever)", "Force Pull (Sobrescribir)", "Force Pull (Écraser)", "Force Pull Überschreiben", "फ़ोर्स पुल ओवरराइट", "强制拉取覆盖", "سحب قسري مع الكتابة", "Принудительный Pull", "ফোর্স পুল ওভাররাইট", "Paksa Pull Timpa")
	_t("force_push", "Force Push", "Forçar Push", "Force Push", "Force Push", "Force Push", "फ़ोर्स पुश", "强制推送", "دفع قسري", "Принудительный Push", "ফোর্স পুশ", "Paksa Push")

	# ─── Git Status Messages ───
	_t("no_git_repo", "No Git repository found in project root.", "Nenhum repositório Git encontrado na raiz do projeto.", "No se encontró repositorio Git en la raíz del proyecto.", "Aucun dépôt Git trouvé dans le dossier racine.", "Kein Git-Repository im Projektstamm gefunden.", "प्रोजेक्ट रूट में कोई Git रिपॉज़िटरी नहीं मिली।", "未在项目根目录中找到 Git 仓库。", "لم يتم العثور على مستودع Git في جذر المشروع.", "Git-репозиторий не найден.", "প্রজেক্ট রুটে কোনো Git রিপোজিটরি পাওয়া যায়নি।", "Tidak ada repositori Git ditemukan di root proyek.")
	_t("working_tree_clean", "Working tree clean.", "Árvore de trabalho limpa.", "Árbol de trabajo limpio.", "Arborescence propre.", "Arbeitsverzeichnis sauber.", "वर्किंग ट्री क्लीन।", "工作区干净。", "شجرة العمل نظيفة.", "Рабочее дерево чисто.", "ওয়ার্কিং ট্রি পরিষ্কার।", "Working tree bersih.")
	_t("pending_changes", "Pending changes:", "Alterações pendentes:", "Cambios pendientes:", "Modifications en attente :", "Ausstehende Änderungen:", "लंबित परिवर्तन:", "待处理的更改:", "تغييرات معلقة:", "Ожидающие изменения:", "মুলতুবি পরিবর্তন:", "Perubahan tertunda:")
	_t("working_please_wait", "⏳ Working... please wait.", "⏳ Trabalhando... aguarde.", "⏳ Trabajando... espere.", "⏳ En cours... patientez.", "⏳ Arbeite... bitte warten.", "⏳ काम चल रहा है... कृपया प्रतीक्षा करें।", "⏳ 处理中... 请稍候。", "⏳ جارٍ العمل... يرجى الانتظار.", "⏳ Работаю... подождите.", "⏳ কাজ চলছে... অপেক্ষা করুন।", "⏳ Memproses... harap tunggu.")
	_t("pulling_from_github", "⏳ Pulling from GitHub...", "⏳ Puxando do GitHub...", "⏳ Descargando de GitHub...", "⏳ Pull depuis GitHub...", "⏳ Pull von GitHub...", "⏳ GitHub से Pull हो रहा है...", "⏳ 正在从 GitHub 拉取...", "⏳ جارٍ السحب من GitHub...", "⏳ Pull из GitHub...", "⏳ GitHub থেকে Pull হচ্ছে...", "⏳ Menarik dari GitHub...")
	_t("pull_result", "Pull result:", "Resultado do Pull:", "Resultado del Pull:", "Résultat du Pull :", "Pull-Ergebnis:", "Pull परिणाम:", "Pull 结果:", "نتيجة السحب:", "Результат Pull:", "Pull ফলাফল:", "Hasil Pull:")
	_t("switching_branch", "⏳ Switching branch...", "⏳ Trocando branch...", "⏳ Cambiando rama...", "⏳ Changement de branche...", "⏳ Branch wechseln...", "⏳ ब्रांच बदल रहे हैं...", "⏳ 正在切换分支...", "⏳ جارٍ تبديل الفرع...", "⏳ Переключение ветки...", "⏳ ব্রাঞ্চ পরিবর্তন হচ্ছে...", "⏳ Mengganti cabang...")
	_t("undoing_uncommitted", "⏳ Undoing uncommitted changes...", "⏳ Desfazendo alterações não commitadas...", "⏳ Deshaciendo cambios...", "⏳ Annulation des modifications...", "⏳ Änderungen rückgängig...", "⏳ परिवर्तन पूर्ववत हो रहे हैं...", "⏳ 正在撤销未提交的更改...", "⏳ جارٍ التراجع...", "⏳ Отмена изменений...", "⏳ পরিবর্তন পূর্বাবস্থায় ফিরছে...", "⏳ Membatalkan perubahan...")
	_t("modifications_discarded", "Modifications discarded.", "Modificações descartadas.", "Modificaciones descartadas.", "Modifications annulées.", "Änderungen verworfen.", "परिवर्तन रद्द किए गए।", "修改已丢弃。", "تم تجاهل التعديلات.", "Изменения отменены.", "পরিবর্তন বাতিল হয়েছে।", "Perubahan dibuang.")
	_t("force_pulling", "⏳ Force pulling from GitHub...", "⏳ Force pull do GitHub...", "⏳ Force pull de GitHub...", "⏳ Force pull depuis GitHub...", "⏳ Force Pull von GitHub...", "⏳ GitHub से फ़ोर्स पुल...", "⏳ 正在强制拉取...", "⏳ جارٍ السحب القسري من GitHub...", "⏳ Принудительный Pull...", "⏳ GitHub থেকে ফোর্স পুল...", "⏳ Memaksa Pull dari GitHub...")
	_t("force_pull_complete", "Force Pull complete.", "Force Pull concluído.", "Force Pull completado.", "Force Pull terminé.", "Force Pull abgeschlossen.", "फ़ोर्स पुल पूर्ण।", "强制拉取完成。", "اكتمل السحب القسري.", "Принудительный Pull завершён.", "ফোর্স পুল সম্পূর্ণ।", "Paksa Pull selesai.")
	_t("force_pushing", "⏳ Force pushing to GitHub...", "⏳ Force push para o GitHub...", "⏳ Force push a GitHub...", "⏳ Force push vers GitHub...", "⏳ Force Push zu GitHub...", "⏳ GitHub पर फ़ोर्स पुश...", "⏳ 正在强制推送...", "⏳ جارٍ الدفع القسري إلى GitHub...", "⏳ Принудительный Push...", "⏳ GitHub-এ ফোর্স পুশ হচ্ছে...", "⏳ Memaksa Push ke GitHub...")
	_t("force_push_complete", "Force Push complete.", "Force Push concluído.", "Force Push completado.", "Force Push terminé.", "Force Push abgeschlossen.", "फ़ोर्स पुश पूर्ण।", "强制推送完成。", "اكتمل الدفع القسري.", "Принудительный Push завершён.", "ফোর্স পুশ সম্পূর্ণ।", "Paksa Push selesai.")
	_t("committing_pushing", "⏳ Committing and pushing...", "⏳ Commitando e enviando...", "⏳ Confirmando y enviando...", "⏳ Commit et push...", "⏳ Commit und Push...", "⏳ कमिट और पुश हो रहा है...", "⏳ 正在提交并推送...", "⏳ جارٍ الإيداع والدفع...", "⏳ Коммит и Push...", "⏳ কমিট এবং পুশ হচ্ছে...", "⏳ Commit dan Push...")
	_t("push_result", "Push result:", "Resultado do Push:", "Resultado del Push:", "Résultat du Push :", "Push-Ergebnis:", "Push परिणाम:", "Push 结果:", "نتيجة الدفع:", "Результат Push:", "Push ফলাফল:", "Hasil Push:")
	_t("no_changes_to_commit", "No changes to commit.", "Nenhuma alteração para commitar.", "Sin cambios para confirmar.", "Aucune modification à valider.", "Keine Änderungen zum Committen.", "कोई परिवर्तन नहीं।", "没有可提交的更改。", "لا توجد تغييرات للإيداع.", "Нет изменений для коммита.", "কমিট করার কোনো পরিবর্তন নেই।", "Tidak ada perubahan untuk commit.")
	_t("ai_not_configured", "AI Provider not configured.", "Provedor de IA não configurado.", "Proveedor de IA no configurado.", "Fournisseur IA non configuré.", "KI-Anbieter nicht konfiguriert.", "AI प्रदाता कॉन्फ़िगर नहीं है।", "AI 提供者未配置。", "لم يتم تكوين مزود الذكاء الاصطناعي.", "Провайдер ИИ не настроен.", "AI প্রদানকারী কনফিগার করা হয়নি।", "Penyedia AI belum dikonfigurasi.")
	_t("generating", "Generating...", "Gerando...", "Generando...", "Génération...", "Generiere...", "जनरेट हो रहा है...", "生成中...", "جارٍ الإنشاء...", "Генерация...", "তৈরি হচ্ছে...", "Membuat...")
	_t("error_generating_commit", "Error generating commit message.", "Erro ao gerar mensagem de commit.", "Error al generar mensaje de commit.", "Erreur de génération du message.", "Fehler bei Commit-Nachricht.", "कमिट संदेश बनाने में त्रुटि।", "生成提交信息时出错。", "خطأ في إنشاء رسالة الإيداع.", "Ошибка генерации сообщения.", "কমিট মেসেজ তৈরিতে ত্রুটি।", "Gagal membuat pesan commit.")

	# ─── Confirmation Dialogs ───
	_t("undo_confirm_title", "Undo Uncommitted Changes", "Desfazer Alterações Não Commitadas", "Deshacer Cambios No Confirmados", "Annuler les Modifications", "Änderungen Rückgängig Machen", "परिवर्तन पूर्ववत करें", "撤销未提交的更改", "التراجع عن التغييرات", "Отменить изменения", "পরিবর্তন পূর্বাবস্থা", "Batalkan Perubahan")
	_t("undo_confirm_text", "Are you sure? This will permanently delete all current edits that have not been saved/committed to Git.", "Tem certeza? Isso excluirá permanentemente todas as edições não salvas/commitadas.", "¿Estás seguro? Esto eliminará permanentemente todos los cambios no guardados.", "Êtes-vous sûr ? Cela supprimera définitivement toutes les modifications non sauvegardées.", "Sind Sie sicher? Alle nicht gespeicherten Änderungen werden gelöscht.", "क्या आप सुनिश्चित हैं? सभी असहेजे बदलाव स्थायी रूप से हटा दिए जाएँगे।", "确定吗？所有未保存的编辑将被永久删除。", "هل أنت متأكد؟ سيتم حذف جميع التعديلات غير المحفوظة نهائياً.", "Вы уверены? Все несохранённые изменения будут удалены.", "আপনি কি নিশ্চিত? সমস্ত অসংরক্ষিত পরিবর্তন স্থায়ীভাবে মুছে যাবে।", "Anda yakin? Semua perubahan yang belum disimpan akan dihapus secara permanen.")
	_t("force_pull_confirm_title", "Force Pull Overwrite", "Force Pull (Sobrescrever)", "Force Pull (Sobrescribir)", "Force Pull (Écraser)", "Force Pull Überschreiben", "फ़ोर्स पुल ओवरराइट", "强制拉取覆盖", "سحب قسري مع الكتابة", "Принудительный Pull", "ফোর্স পুল ওভাররাইট", "Paksa Pull Timpa")
	_t("force_pull_confirm_text", "WARNING: Are you sure? This will ignore your local edits and force the project to exactly match what is on GitHub today. You will lose any unpushed work!", "AVISO: Tem certeza? Isso ignorará suas edições locais e forçará o projeto a corresponder exatamente ao GitHub. Você perderá qualquer trabalho não enviado!", "ADVERTENCIA: ¿Estás seguro? Esto ignorará tus ediciones locales y forzará el proyecto a coincidir con GitHub. ¡Perderás el trabajo no enviado!", "ATTENTION : Êtes-vous sûr ? Cela ignorera vos modifications locales et forcera le projet à correspondre à GitHub. Vous perdrez tout travail non poussé !", "WARNUNG: Sind Sie sicher? Ihre lokalen Änderungen werden ignoriert. Sie verlieren nicht gepushte Arbeit!", "चेतावनी: क्या आप सुनिश्चित हैं? यह आपके स्थानीय संपादन अनदेखा कर देगा। अपुश किया गया कार्य खो जाएगा!", "警告：确定吗？这将忽略您的本地编辑并强制项目与 GitHub 完全匹配。未推送的工作将丢失！", "تحذير: هل أنت متأكد؟ سيتم تجاهل تعديلاتك المحلية. ستفقد أي عمل لم يتم رفعه!", "ВНИМАНИЕ: Вы уверены? Локальные изменения будут потеряны!", "সতর্কতা: আপনি কি নিশ্চিত? স্থানীয় পরিবর্তন উপেক্ষা করা হবে। অপুশ করা কাজ হারিয়ে যাবে!", "PERINGATAN: Anda yakin? Ini akan mengabaikan perubahan lokal Anda. Pekerjaan yang belum di-push akan hilang!")
	_t("force_push_confirm_title", "Force Push to GitHub", "Force Push para o GitHub", "Force Push a GitHub", "Force Push vers GitHub", "Force Push zu GitHub", "GitHub पर फ़ोर्स पुश", "强制推送到 GitHub", "الدفع القسري إلى GitHub", "Принудительный Push в GitHub", "GitHub-এ ফোর্স পুশ", "Paksa Push ke GitHub")
	_t("force_push_confirm_text", "WARNING: This will overwrite the version on GitHub with your current local project. Any commits on GitHub that you don't have locally will be permanently lost. Continue?", "AVISO: Isso sobrescreverá a versão no GitHub com seu projeto local. Qualquer commit no GitHub que você não tem localmente será perdido. Continuar?", "ADVERTENCIA: Esto sobrescribirá la versión en GitHub con tu proyecto local. Los commits en GitHub que no tienes localmente se perderán. ¿Continuar?", "ATTENTION : Cela écrasera la version GitHub avec votre projet local. Les commits non présents localement seront perdus. Continuer ?", "WARNUNG: Dies überschreibt die GitHub-Version. Commits auf GitHub, die Sie lokal nicht haben, gehen verloren. Fortfahren?", "चेतावनी: यह GitHub संस्करण को आपके स्थानीय प्रोजेक्ट से ओवरराइट करेगा। जारी रखें?", "警告：这将用当前本地项目覆盖 GitHub 上的版本。继续吗？", "تحذير: سيتم الكتابة فوق النسخة على GitHub. المتابعة؟", "ВНИМАНИЕ: Это перезапишет версию на GitHub. Продолжить?", "সতর্কতা: এটি GitHub-এর সংস্করণ ওভাররাইট করবে। চালিয়ে যেতে চান?", "PERINGATAN: Ini akan menimpa versi di GitHub. Lanjutkan?")
	_t("confirm_destructive_title", "Confirm Destructive Action", "Confirmar Ação Destrutiva", "Confirmar Acción Destructiva", "Confirmer l'Action Destructive", "Destruktive Aktion Bestätigen", "विनाशकारी कार्रवाई पुष्टि", "确认破坏性操作", "تأكيد الإجراء المدمر", "Подтвердите действие", "ধ্বংসাত্মক কাজ নিশ্চিত করুন", "Konfirmasi Tindakan Destruktif")
	_t("cannot_be_undone", "This action cannot be undone.", "Esta ação não pode ser desfeita.", "Esta acción no se puede deshacer.", "Cette action ne peut pas être annulée.", "Diese Aktion kann nicht rückgängig gemacht werden.", "इस क्रिया को पूर्ववत नहीं किया जा सकता।", "此操作无法撤销。", "لا يمكن التراجع عن هذا الإجراء.", "Это действие нельзя отменить.", "এই কাজ পূর্বাবস্থায় ফেরানো যাবে না।", "Tindakan ini tidak dapat dibatalkan.")

	# ─── Watch Mode ───
	_t("watch_max_limit", "Watch Mode: Reached max auto-fix limit ({max}). Pausing auto-fix to avoid loops. Send a manual message to reset.", "Modo Vigiar: Limite máximo de correção atingido ({max}). Pausando para evitar loops. Envie uma mensagem manual para resetar.", "Modo Vigilar: Límite de corrección alcanzado ({max}). Pausado. Envíe un mensaje manual.", "Mode Surveillance : Limite atteinte ({max}). Pause. Envoyez un message manuel.", "Überwachung: Max-Limit erreicht ({max}). Pausiert. Senden Sie eine manuelle Nachricht.", "वॉच मोड: अधिकतम सीमा ({max}) तक पहुँच गई। लूप से बचने के लिए रुका हुआ।", "监视模式：已达到最大自动修复限制 ({max})。已暂停。", "وضع المراقبة: تم الوصول للحد الأقصى ({max}). متوقف مؤقتاً.", "Наблюдение: Достигнут лимит ({max}). Приостановлено.", "পর্যবেক্ষণ: সর্বোচ্চ সীমা ({max}) পৌঁছেছে। থামানো হয়েছে।", "Mode Pantau: Batas maksimum ({max}) tercapai. Dijeda.")
	_t("watch_error_detected", "Watch Mode: New error detected! Auto-fixing ({current}/{max})...", "Modo Vigiar: Novo erro detectado! Corrigindo ({current}/{max})...", "Modo Vigilar: ¡Nuevo error! Corrigiendo ({current}/{max})...", "Surveillance : Erreur détectée ! Correction ({current}/{max})...", "Überwachung: Neuer Fehler! Auto-Fix ({current}/{max})...", "वॉच मोड: नई त्रुटि! स्वत: ठीक ({current}/{max})...", "监视模式：检测到新错误！自动修复 ({current}/{max})...", "المراقبة: خطأ جديد! إصلاح تلقائي ({current}/{max})...", "Наблюдение: Новая ошибка! Авто-исправление ({current}/{max})...", "পর্যবেক্ষণ: নতুন ত্রুটি! স্বয়ংক্রিয় সংশোধন ({current}/{max})...", "Pantau: Error baru terdeteksi! Memperbaiki ({current}/{max})...")

	# ─── Tooltips (Chat & Actions) ───
	_t("tt_refactor", "Refactor the currently selected code in the editor", "Refatorar o código selecionado no editor", "Refactorizar código", "Refactoriser le code", "Code refaktorieren", "कोड रिफैक्टर करें", "重构代码", "إعادة هيكلة", "Рефакторинг", "রিফ্যাক্টর", "Refaktor")
	_t("tt_fix", "Propose a fix for errors in the currently selected code", "Propor correção para erros no código", "Proponer corrección", "Proposer une correction", "Fix vorschlagen", "सुधार का प्रस्ताव दें", "提出修复建议", "اقتراح إصلاح", "Предложить исправление", "সংশোধন প্রস্তাব", "Usulkan perbaikan")
	_t("tt_explain", "Explain how the currently selected code works", "Explicar funcionamento do código", "Explicar código", "Expliquer le code", "Code erklären", "कोड समझाएं", "解释代码", "شرح الكود", "Объяснить код", "কোড ব্যাখ্যা", "Jelaskan kode")
	_t("tt_undo", "Undo the last AI action batch", "Desfazer última ação da IA", "Deshacer acción de IA", "Annuler l'action", "KI-Aktion rückgängig", "AI कार्रवाई पूर्ववत करें", "撤销 AI 操作", "تراجع عن الذكاء الاصطناعي", "Отменить действие ИИ", "AI কাজ পূর্বাবস্থায় ফেরান", "Batalkan aksi AI")
	_t("tt_fix_console", "Analyze latest console errors and propose fixes", "Analisar erros do console e propor correção", "Analizar consola", "Analyser la console", "Konsole analysieren", "कंसोल विश्लेषित करें", "分析控制台", "تحليل وحدة التحكم", "Анализ консоли", "কনসোল বিশ্লেষণ", "Analisis konsol")
	_t("tt_context", "Include the text of the currently open script in the AI prompt", "Incluir texto do script atual no prompt da IA", "Incluir script en prompt", "Inclure le script", "Skript einbeziehen", "स्क्रिप्ट शामिल करें", "包括脚本", "تضمين السكربت", "Включить скрипт", "স্ক্রিপ্ট অন্তর্ভুক্ত করুন", "Sertakan skrip")
	_t("tt_screenshot", "Take a screenshot of the editor and send it to the AI", "Tirar screenshot do editor para a IA", "Captura para IA", "Capture pour l'IA", "Screenshot für KI", "AI के लिए स्क्रीनशॉट", "截图给 AI", "لقطة للذكاء الاصطناعي", "Снимок для ИИ", "AI এর জন্য স্ক্রিনশট", "Tangkapan untuk AI")
	_t("tt_plan_first", "Ask the AI to generate a step-by-step plan before executing.", "Pedir para a IA gerar um plano antes de agir", "Pedir plan a IA", "Demander un plan", "Plan anfordern", "योजना मांगें", "请求计划", "طلب خطة", "Запросить план", "পরিকল্পনা চান", "Minta rencana")
	_t("tt_watch_mode", "Monitor console for new errors and auto-prompt fix.", "Monitorar console em busca de novos erros", "Monitorizar consola", "Surveiller la console", "Konsole überwachen", "कंसोल की निगरानी", "监视控制台", "مراقبة وحدة التحكم", "Мониторинг консоли", "কনসোল পর্যবেক্ষণ", "Pantau konsol")

	# ─── Tooltips (Git) ───
	_t("tt_init_repo", "Initialize a new local Git repository in your project folder", "Inicializar um novo repositório Git local", "Inicializar Git", "Initialiser Git", "Git initialisieren", "Git प्रारंभ करें", "初始化 Git", "تهيئة Git", "Инициализировать Git", "Git শুরু করুন", "Inisialisasi Git")
	_t("tt_set_remote", "Set Remote Origin URL", "Definir URL do Remote Origin", "Configurar origen", "Définir l'origine", "Origin festlegen", "ओरिजिन सेट करें", "设置源", "تعيين المصدر", "Установить Origin URL", "অরিজিন সেট করুন", "Atur asal")
	_t("tt_pull", "Download and merge the latest changes from GitHub", "Baixar e mesclar alterações do GitHub", "Descargar de GitHub", "Télécharger depuis GitHub", "Von GitHub herunterladen", "GitHub से डाउनलोड", "从 GitHub 下载", "تنزيل من GitHub", "Скачать с GitHub", "GitHub থেকে ডাউনলোড", "Unduh dari GitHub")
	_t("tt_refresh_git", "Refresh the list of changed files below", "Atualizar a lista de arquivos alterados", "Actualizar lista", "Actualiser la liste", "Liste aktualisieren", "सूची ताज़ा करें", "刷新列表", "تحديث القائمة", "Обновить список", "তালিকা রিফ্রেশ", "Segarkan daftar")
	_t("tt_auto_generate_commit", "Use AI to analyze your changes and write a commit message automatically", "Usar IA para gerar mensagem de commit", "Generar commit con IA", "Commit via l'IA", "Commit mit KI", "AI से कमिट", "AI 生成提交", "إيداع بالذكاء الاصطناعي", "Коммит через ИИ", "AI দিয়ে কমিট", "Commit dengan AI")
	_t("tt_commit_sync", "Save your changes locally (Commit) and upload them to GitHub (Push)", "Salvar alterações e enviar para o GitHub", "Guardar y enviar", "Enregistrer et pousser", "Speichern und pushen", "सहेजें और पुश करें", "保存并推送", "حفظ ودفع", "Сохранить и Push", "সংরক্ষণ এবং পুশ", "Simpan dan push")
	_t("tt_checkout_branch", "Creates a parallel 'timeline' (branch).", "Criar nova branch para testar alterações.", "Crear rama", "Créer une branche", "Branch erstellen", "ब्रांच बनाएं", "创建分支", "إنشاء فرع", "Создать ветку", "ব্রাঞ্চ তৈরি করুন", "Buat cabang")
	_t("tt_undo_changes", "Discards all local edits that haven't been committed", "Descartar todas as edições locais não confirmadas", "Descartar ediciones", "Annuler modifications", "Änderungen verwerfen", "बदलाव छोड़ें", "放弃更改", "تجاهل التعديلات", "Отменить изменения", "পরিবর্তন বাতিল", "Buang perubahan")
	_t("tt_force_pull", "Completely replaces your project with the latest version saved on GitHub", "Substituir projeto pela versão do GitHub", "Reemplazar con GitHub", "Remplacer par GitHub", "Mit GitHub ersetzen", "GitHub से बदलें", "用 GitHub 替换", "استبدال من GitHub", "Заменить из GitHub", "GitHub দিয়ে প্রতিস্থাপন", "Ganti dengan GitHub")
	_t("tt_force_push", "Force upload your local project to GitHub, overwriting whatever is there.", "Forçar envio local para o GitHub, sobrescrevendo", "Forzar subida", "Forcer l'envoi", "Upload erzwingen", "फ़ोर्स अपलोड", "强制上传", "رفع قسري", "Принудительный Push", "ফোর্স আপলোড", "Paksa unggah")

	# ─── Diff Preview ───
	_t("diff_preview_label", "Script Diff Preview:", "Pré-visualização de Diff:", "Vista Previa del Diff:", "Aperçu du Diff :", "Diff-Vorschau:", "डिफ पूर्वावलोकन:", "脚本差异预览:", "معاينة الفرق:", "Предпросмотр Diff:", "ডিফ প্রিভিউ:", "Pratinjau Diff Skrip:")
	_t("apply_changes", "Apply Changes", "Aplicar Alterações", "Aplicar Cambios", "Appliquer", "Übernehmen", "बदलाव लागू करें", "应用更改", "تطبيق التغييرات", "Применить", "পরিবর্তন প্রয়োগ", "Terapkan Perubahan")
	_t("skip", "Skip", "Pular", "Omitir", "Ignorer", "Überspringen", "छोड़ें", "跳过", "تخطي", "Пропустить", "এড়িয়ে যান", "Lewati")
	_t("new_content_preview", "New content preview:", "Pré-visualização do novo conteúdo:", "Vista previa del contenido:", "Aperçu du nouveau contenu :", "Neue Inhaltsvorschau:", "नई सामग्री पूर्वावलोकन:", "新内容预览:", "معاينة المحتوى الجديد:", "Предпросмотр нового содержимого:", "নতুন বিষয়বস্তু প্রিভিউ:", "Pratinjau konten baru:")
	_t("modifying_label", "Modifying: ", "Modificando: ", "Modificando: ", "Modification : ", "Ändern: ", "संशोधित: ", "正在修改: ", "جارٍ التعديل: ", "Изменение: ", "পরিবর্তন হচ্ছে: ", "Mengubah: ")

# Helper to add translation entries
func _t(key: String, en: String, pt_BR: String, es: String, fr: String, de: String, hi: String, zh_CN: String, ar: String, ru: String, bn: String, id: String):
	_translations[key] = {
		"en": en,
		"pt_BR": pt_BR,
		"es": es,
		"fr": fr,
		"de": de,
		"hi": hi,
		"zh_CN": zh_CN,
		"ar": ar,
		"ru": ru,
		"bn": bn,
		"id": id
	}
