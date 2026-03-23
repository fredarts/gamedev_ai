@tool
extends EditorPlugin

var dock
var ai_provider
var context_manager
var tool_executor
var memory_manager
var logger

func _enter_tree():
	# Preload script classes
	var ContextManager = preload("res://addons/gamedev_ai/context_manager.gd")
	var ToolExecutor = preload("res://addons/gamedev_ai/tool_executor.gd")
	var LoggerScript = preload("res://addons/gamedev_ai/logger.gd")
	var MemoryMgr = preload("res://addons/gamedev_ai/memory_manager.gd")
	
	# Initialize components
	context_manager = ContextManager.new()
	tool_executor = ToolExecutor.new()
	tool_executor.setup(get_undo_redo())
	memory_manager = MemoryMgr.new()
	tool_executor.memory_manager = memory_manager
	logger = LoggerScript.new()
	
	# Load UI
	var DockScene = preload("res://addons/gamedev_ai/dock/dock.tscn")
	dock = DockScene.instantiate()
	
	# Load Provider
	var settings = EditorInterface.get_editor_settings()
	var active_preset_name = ""
	if settings.has_setting("gamedev_ai/active_preset"):
		active_preset_name = settings.get_setting("gamedev_ai/active_preset")
	
	var presets = {}
	if settings.has_setting("gamedev_ai/presets"):
		presets = settings.get_setting("gamedev_ai/presets")
	
	var config = {}
	if presets.has(active_preset_name):
		config = presets[active_preset_name]
	elif not presets.is_empty():
		config = presets.values()[0]
	else:
		# Fallback if no presets exist yet (dock will create default)
		config = {"provider": 0, "api_key": "", "base_url": "", "model_name": ""}
	
	_set_provider(config)
	
	# Setup Dock
	dock.setup(ai_provider, context_manager, tool_executor)
	dock._memory_manager = memory_manager
	dock.preset_changed.connect(_on_preset_changed)
	dock.settings_updated.connect(_on_provider_settings_updated)
	
	# Add Logger
	logger.register_logger()
	logger.new_log_entry.connect(dock._on_log_entry)
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	_print_welcome_banner()

func _print_welcome_banner():
	var banner = """
[color=cyan][b]========================================================================[/b][/color]
[color=white][b]🤖 Gamedev AI Plugin Inicializado com Sucesso![/b][/color]

Um assistente inteligente com [b]conhecimento profundo[/b] integrado ao coração do Godot 4!
Especialista em GDScript, a IA possui o poder de criar jogos inteiros de forma autônoma:
gera do zero qualquer tipo de Node, edita scripts complexos, configura propriedades 
diretamente na Scene Tree e altera até as configurações globais do Project Settings.

[color=yellow][b]🛠️ WORKFLOW COMPLETO:[/b][/color]
 1. [b]Conversa & Anexos:[/b] Peça à IA no Chat para criar ou refatorar mecânicas. Você 
    pode [b]anexar arquivos[/b] ou arrastar Nodes da Scene Tree direto para o chat!
 2. [b]Revisão de Código (Diff):[/b] A IA escreve código, mas você está no controle. O plugin
    gera uma tela de Diff (Antes/Depois) para você revisar e aprovar (Apply Changes).
 3. [b]Watch Mode:[/b] Ative essa opção para automatizar a depuração. A IA vai escutar o
    Output quando você jogar (Play) e sugerir o conserto imadiato de erros vermelhos.
 4. [b]Indexação:[/b] Use "Index Codebase" nas Configurações. Isso faz a IA entender toda
    a teia de scripts do seu jogo através de busca semântica em questão de segundos.
 5. [b]Histórico:[/b] Use o botão "History" para carregar conversas do passado, perfeito
    para retomar o raciocínio de mecânicas complexas iniciadas no dia anterior.

[color=yellow][b]🚀 PODERES E FUNCIONALIDADES AVANÇADAS:[/b][/color]
 • [b]25 Skills Embutidas:[/b] O plugin foi intensamente treinado com 25 módulos de expertise
   em Godot 4 (Inventários Avançados, Multiplayer API, Shaders, Geração Procedural, Física,
   UI/UX, etc.) para programar sempre aplicando a arquitetura mais limpa da indústria.
 • [b]Custom System Prompt:[/b] Molde a IA ditando regras fixas (Exemplo: "Sempre use
   tipagem estática rigorosa no GDScript e comente as funções").
 • [b]GitHub Integrado:[/b] Puxe, crie Branches (linhas do tempo) e force Commits com 
   mensagens profissionais sendo escritas e resumidas 100% pela IA no painel Git.
 • [b]Memória Persistente:[/b] Assim como um CTO humano, a IA registra documentações
   invisíveis e decisões arquiteturais pra si mesma dentro da pasta do PC.

[color=yellow][b]📚 DÚVIDAS E ATUALIZAÇÕES:[/b][/color]
 • [url=https://github.com/fredericoBSS/Gamedev-Ai]Documentação Oficial e Repositório GitHub[/url]
[color=cyan][b]========================================================================[/b][/color]
"""
	print_rich(banner)

func _set_provider(config: Dictionary):
	var index = config.get("provider", 0)
	
	if index == 0:
		var GeminiProvider = load("res://addons/gamedev_ai/gemini_provider.gd")
		ai_provider = GeminiProvider.new()
	else:
		var OpenAIProvider = load("res://addons/gamedev_ai/openai_provider.gd")
		ai_provider = OpenAIProvider.new()
	
	ai_provider.setup(self)
	_apply_config_to_provider(ai_provider, config)
	
	# Update dock if it exists
	if dock:
		dock._set_client(ai_provider)

func _on_preset_changed(config: Dictionary):
	_set_provider(config)

func _on_provider_settings_updated():
	var settings = EditorInterface.get_editor_settings()
	var active_preset_name = settings.get_setting("gamedev_ai/active_preset")
	var presets = settings.get_setting("gamedev_ai/presets")
	if presets.has(active_preset_name):
		_apply_config_to_provider(ai_provider, presets[active_preset_name])

func _apply_config_to_provider(provider, config: Dictionary):
	provider.set_api_key(config.get("api_key", ""))
	
	if "model_name" in provider:
		var model = config.get("model_name", "")
		if model != "":
			provider.model_name = model
	
	if provider.get_script().get_path().ends_with("openai_provider.gd"):
		provider.base_url = config.get("base_url", "https://api.openai.com/v1")
		if provider.base_url == "":
			provider.base_url = "https://api.openai.com/v1"
		
		# Set OpenRouter headers
		provider.custom_headers = {
			"HTTP-Referer": "https://godot.editor",
			"X-Title": "Gamedev AI Godot Plugin"
		}

func _exit_tree():

	# Clean up
	if dock:
		remove_control_from_docks(dock)
		dock.free()
	
	if logger:
		logger.unregister_logger()
	
	print("Gamedev AI deactivated.")
