@tool
extends RefCounted
class_name PersonaConfig

enum Role {
	ARCHITECT,
	SCENE_BUILDER,
	CODER,
	QA_TESTER,
	SHADER_ARTIST
}

static func get_persona_name(role: int) -> String:
	match role:
		Role.ARCHITECT: return "Game Architect"
		Role.SCENE_BUILDER: return "Scene & UI Builder"
		Role.CODER: return "GDScript Coder"
		Role.QA_TESTER: return "QA Tester"
		Role.SHADER_ARTIST: return "Shader Synthesizer"
	return "General Assistant"

static func get_persona_icon(role: int) -> String:
	match role:
		Role.ARCHITECT: return "📐"
		Role.SCENE_BUILDER: return "🖼️"
		Role.CODER: return "💻"
		Role.QA_TESTER: return "🧪"
		Role.SHADER_ARTIST: return "🎨"
	return "🤖"

static func get_persona_color(role: int) -> Color:
	match role:
		Role.ARCHITECT: return Color(0.2, 0.6, 1.0) # Blue
		Role.SCENE_BUILDER: return Color(0.2, 0.8, 0.4) # Green
		Role.CODER: return Color(1.0, 0.6, 0.2) # Orange
		Role.QA_TESTER: return Color(0.8, 0.4, 1.0) # Violet / Purple
		Role.SHADER_ARTIST: return Color(0.9, 0.3, 0.6) # Pink / Magenta
	return Color(0.8, 0.8, 0.8)

static func get_allowed_tools(role: int) -> Array[String]:
	match role:
		Role.ARCHITECT:
			return [
				"create_script", "create_resource", "read_file", "list_dir",
				"find_file", "grep_search", "view_file_outline", "get_class_info", "save_memory"
			]
		Role.SCENE_BUILDER:
			return [
				"create_scene", "add_node", "remove_node", "instance_scene",
				"set_property", "set_theme_override", "analyze_node_children",
				"read_file", "list_dir", "get_class_info"
			]
		Role.CODER:
			return [
				"read_file", "patch_script", "edit_script", "create_script",
				"connect_signal", "disconnect_signal", "get_lsp_diagnostics",
				"grep_search", "view_file_outline", "get_class_info"
			]
		Role.QA_TESTER:
			return [
				"create_script", "read_file", "run_tests", "get_lsp_diagnostics",
				"grep_search", "view_file_outline"
			]
		Role.SHADER_ARTIST:
			return [
				"generate_shader", "apply_shader_to_node", "get_shader_presets_list",
				"create_resource", "read_file", "list_dir", "grep_search", "view_file_outline"
			]
	return []
