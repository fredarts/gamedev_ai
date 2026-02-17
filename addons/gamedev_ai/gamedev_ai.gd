@tool
extends EditorPlugin

var dock
var gemini_client
var context_manager
var tool_executor
var logger

func _enter_tree():
	# Preload script classes
	var GeminiClient = preload("res://addons/gamedev_ai/gemini_client.gd")
	var ContextManager = preload("res://addons/gamedev_ai/context_manager.gd")
	var ToolExecutor = preload("res://addons/gamedev_ai/tool_executor.gd")
	var LoggerScript = preload("res://addons/gamedev_ai/logger.gd")
	
	# Initialize components
	gemini_client = GeminiClient.new()
	gemini_client.setup(self)  # Pass the plugin node so it can add HTTPRequest as child
	context_manager = ContextManager.new()
	tool_executor = ToolExecutor.new()
	tool_executor.setup(get_undo_redo())
	logger = LoggerScript.new()
	
	# Add Logger
	logger.register_logger()
	
	# Load UI
	var DockScript = load("res://addons/gamedev_ai/dock/dock.gd")
	dock = DockScript.new()
	dock.setup(gemini_client, context_manager, tool_executor)
	
	# Connect Logger
	logger.new_log_entry.connect(dock._on_log_entry)
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	
	print("Gamedev AI initialized.")

func _exit_tree():
	# Clean up
	if dock:
		remove_control_from_docks(dock)
		dock.free()
	
	if logger:
		logger.unregister_logger()
	
	print("Gamedev AI deactivated.")
