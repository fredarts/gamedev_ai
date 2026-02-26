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
	
	print("Gamedev AI initialized.")

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
