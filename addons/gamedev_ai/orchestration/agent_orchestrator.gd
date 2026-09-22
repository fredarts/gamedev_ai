@tool
extends RefCounted

const Blackboard = preload("res://addons/gamedev_ai/orchestration/blackboard.gd")
const PersonaConfig = preload("res://addons/gamedev_ai/orchestration/persona_config.gd")

signal stage_started(role: int, role_name: String)
signal stage_completed(role: int, role_name: String, summary: String)
signal pipeline_completed(blackboard: RefCounted)
signal pipeline_failed(error_msg: String)
signal pipeline_paused()
signal pipeline_resumed()
signal status_message(bbcode_text: String)

enum State {
	IDLE,
	STAGE_ARCHITECT,
	STAGE_SCENE_BUILDER,
	STAGE_CODER,
	STAGE_QA_TESTER,
	AUTO_HEALING,
	PAUSED,
	COMPLETED,
	FAILED
}

var current_state: int = State.IDLE
var blackboard: RefCounted
var ai_provider: RefCounted
var tool_executor: RefCounted

var _current_role: int = PersonaConfig.Role.ARCHITECT
var _auto_heal_attempts: int = 0
const MAX_AUTO_HEAL_ATTEMPTS: int = 2
var _last_failed_assert_count: int = 0
var _is_paused: bool = false
var _engine_version: String = "Godot 4.x"

# References to persona modules
var _persona_classes: Dictionary = {}

func _init():
	blackboard = Blackboard.new()
	_load_personas()

func setup(p_ai_provider: RefCounted, p_tool_executor: RefCounted, engine_ver: String = "Godot 4.x"):
	ai_provider = p_ai_provider
	tool_executor = p_tool_executor
	_engine_version = engine_ver

func _load_personas():
	_persona_classes[PersonaConfig.Role.ARCHITECT] = load("res://addons/gamedev_ai/orchestration/personas/architect_persona.gd")
	_persona_classes[PersonaConfig.Role.SCENE_BUILDER] = load("res://addons/gamedev_ai/orchestration/personas/scene_builder_persona.gd")
	_persona_classes[PersonaConfig.Role.CODER] = load("res://addons/gamedev_ai/orchestration/personas/coder_persona.gd")
	_persona_classes[PersonaConfig.Role.QA_TESTER] = load("res://addons/gamedev_ai/orchestration/personas/qa_persona.gd")
	_persona_classes[PersonaConfig.Role.SHADER_ARTIST] = load("res://addons/gamedev_ai/orchestration/personas/shader_persona.gd")

func is_active() -> bool:
	return current_state != State.IDLE and current_state != State.COMPLETED and current_state != State.FAILED

func start_orchestration(task_prompt: String):
	if is_active():
		pipeline_failed.emit("An orchestration pipeline is already in progress.")
		return
		
	blackboard.clear()
	blackboard.task_description = task_prompt
	_auto_heal_attempts = 0
	_is_paused = false
	
	status_message.emit("[color=cyan][b]🚀 Starting Multi-Agent Orchestration Pipeline...[/b][/color]\nTask: " + task_prompt)
	_advance_to_stage(State.STAGE_ARCHITECT)

func pause():
	if is_active() and not _is_paused:
		_is_paused = true
		pipeline_paused.emit()
		status_message.emit("[color=yellow]⏸️ Orchestration pipeline paused by user.[/color]")

func resume():
	if is_active() and _is_paused:
		_is_paused = false
		pipeline_resumed.emit()
		status_message.emit("[color=green]▶️ Orchestration pipeline resumed.[/color]")
		_execute_current_stage()

func abort():
	if is_active():
		current_state = State.IDLE
		_is_paused = false
		if tool_executor and tool_executor.has_method("abort_batch_transaction"):
			tool_executor.abort_batch_transaction()
		status_message.emit("[color=red]🛑 Orchestration pipeline aborted.[/color]")

func _advance_to_stage(new_state: int):
	current_state = new_state
	
	match current_state:
		State.STAGE_ARCHITECT:
			_current_role = PersonaConfig.Role.ARCHITECT
		State.STAGE_SCENE_BUILDER:
			_current_role = PersonaConfig.Role.SCENE_BUILDER
		State.STAGE_CODER:
			_current_role = PersonaConfig.Role.CODER
		State.STAGE_QA_TESTER:
			_current_role = PersonaConfig.Role.QA_TESTER
		State.COMPLETED:
			_on_pipeline_completed()
			return
		State.FAILED:
			return
			
	var role_name = PersonaConfig.get_persona_name(_current_role)
	var icon = PersonaConfig.get_persona_icon(_current_role)
	
	stage_started.emit(_current_role, role_name)
	status_message.emit("\n[color=yellow][b]" + icon + " Step: " + role_name + "[/b][/color]")
	
	# Start atomic transaction for this phase
	if tool_executor and tool_executor.has_method("begin_batch_transaction"):
		tool_executor.begin_batch_transaction("[Orchestrator] " + role_name)
		
	_execute_current_stage()

func _execute_current_stage():
	if _is_paused:
		return
		
	var persona_cls = _persona_classes.get(_current_role)
	if not persona_cls:
		_fail_pipeline("Persona class not found for role " + str(_current_role))
		return
		
	var system_prompt = persona_cls.get_system_prompt(_engine_version)
	var condensed_bb = blackboard.to_condensed_prompt()
	
	# Isolate context: Inject system prompt and blackboard snapshot
	var full_stage_prompt = system_prompt + "\n\n" + condensed_bb
	full_stage_prompt += "\n\n### Current Sub-Task Instructions:\n"
	
	match _current_role:
		PersonaConfig.Role.ARCHITECT:
			full_stage_prompt += "Design and create the data models, resource scripts (.gd) and schema files for: " + blackboard.task_description
		PersonaConfig.Role.SCENE_BUILDER:
			full_stage_prompt += "Construct the scene trees and UI components (.tscn) based on the resources in the Blackboard."
		PersonaConfig.Role.CODER:
			if _auto_heal_attempts > 0:
				full_stage_prompt += "Fix failing tests reported in the Blackboard. Apply patches to production scripts to make all assertions pass."
			else:
				full_stage_prompt += "Implement the GDScript logic, wire signals, and validate with LSP diagnostics."
		PersonaConfig.Role.QA_TESTER:
			full_stage_prompt += "Create GUT test suites under res://test/unit/ to thoroughly validate the functionality, then execute run_tests."

	# Configure AI provider sub-session prompt
	if ai_provider:
		ai_provider.custom_instructions = full_stage_prompt
		# We trigger the generation with the current role
		ai_provider.send_message("Proceed with your specialized phase.")

func on_stage_tool_output(tool_name: String, args: Dictionary, result: String):
	# Register created artifacts into Blackboard
	match tool_name:
		"create_script":
			var path = args.get("path", "")
			if path.ends_with(".gd"):
				if _current_role == PersonaConfig.Role.ARCHITECT:
					blackboard.register_resource(path, "", "Resource data class")
				elif _current_role == PersonaConfig.Role.CODER:
					blackboard.register_script(path)
		"create_scene":
			var path = args.get("path", "")
			var root_type = args.get("root_type", "")
			blackboard.register_scene(path, root_type)
		"connect_signal":
			blackboard.register_signal(args.get("source_path", ""), args.get("signal_name", ""), args.get("target_path", ""), args.get("method_name", ""))
		"run_tests":
			# Test Runner completed, results handled in stage completion
			pass

func on_stage_completed_by_ai(summary: String):
	var role_name = PersonaConfig.get_persona_name(_current_role)
	
	# Parse structured ARTIFACT_REPORT if present in the persona output
	var report = _extract_artifact_report(summary)
	if not report.is_empty():
		_integrate_artifact_report(report)
	
	# Commit atomic transaction for this stage
	if tool_executor and tool_executor.has_method("commit_batch_transaction"):
		tool_executor.commit_batch_transaction()
		
	# Handoff Gatekeeper: Validate required artifacts
	var gate_ok = _validate_stage_handoff(_current_role)
	if not gate_ok:
		return
		
	stage_completed.emit(_current_role, role_name, summary)
	
	# Advance state machine
	match current_state:
		State.STAGE_ARCHITECT:
			_advance_to_stage(State.STAGE_SCENE_BUILDER)
		State.STAGE_SCENE_BUILDER:
			_advance_to_stage(State.STAGE_CODER)
		State.STAGE_CODER:
			_advance_to_stage(State.STAGE_QA_TESTER)
		State.STAGE_QA_TESTER:
			_handle_qa_evaluation()

func _extract_artifact_report(text: String) -> Dictionary:
	if text.strip_edges().is_empty():
		return {}

	# Strategy 1: HTML Comment format <!-- ARTIFACT_REPORT { ... } -->
	var start_tag = "<!-- ARTIFACT_REPORT"
	var end_tag = "-->"
	var start_idx = text.find(start_tag)
	if start_idx != -1:
		var content_start = start_idx + start_tag.length()
		var end_idx = text.find(end_tag, content_start)
		if end_idx != -1:
			var json_str = text.substr(content_start, end_idx - content_start).strip_edges()
			var parsed = JSON.parse_string(json_str)
			if parsed is Dictionary and _is_valid_artifact_report(parsed):
				return parsed

	# Strategy 2: Markdown fenced code blocks (```json ... ``` or ``` ... ```)
	var regex = RegEx.new()
	regex.compile("```(?:json)?\\s*([\\s\\S]*?)```")
	var matches = regex.search_all(text)
	for m in matches:
		var block_content = m.get_string(1).strip_edges()
		if block_content.begins_with("{") and block_content.ends_with("}"):
			var parsed = JSON.parse_string(block_content)
			if parsed is Dictionary and _is_valid_artifact_report(parsed):
				return parsed

	# Strategy 3: Scan for outer JSON object with report signature keys
	var first_brace = text.find("{")
	var last_brace = text.rfind("}")
	if first_brace != -1 and last_brace > first_brace:
		var raw_candidate = text.substr(first_brace, (last_brace - first_brace) + 1).strip_edges()
		var parsed = JSON.parse_string(raw_candidate)
		if parsed is Dictionary and _is_valid_artifact_report(parsed):
			return parsed

	return {}

func _is_valid_artifact_report(data: Dictionary) -> bool:
	var report_keys = ["resources", "scenes", "scripts", "signals_connected", "test_suites"]
	for k in report_keys:
		if data.has(k) and data[k] is Array:
			return true
	return false

func _integrate_artifact_report(report: Dictionary):
	# Register resources
	for res in report.get("resources", []):
		if res is Dictionary:
			blackboard.register_resource(res.get("path", ""), res.get("class_name", ""), str(res.get("properties", [])))
	
	# Register scenes
	for sc in report.get("scenes", []):
		if sc is Dictionary:
			var node_paths = []
			for kn in sc.get("key_nodes", []):
				if kn is Dictionary:
					node_paths.append(kn.get("path", ""))
			blackboard.register_scene(sc.get("path", ""), sc.get("root_type", ""), node_paths)
			
	# Register scripts
	for scr in report.get("scripts", []):
		if scr is Dictionary:
			blackboard.register_script(scr.get("path", ""), scr.get("public_methods", []), scr.get("signals", []))
			
	# Register connected signals
	for sig in report.get("signals_connected", []):
		if sig is Dictionary:
			blackboard.register_signal(sig.get("source", ""), sig.get("signal", ""), sig.get("target", ""), sig.get("method", ""))
			
	# Register test suites
	for t in report.get("test_suites", []):
		if t is Dictionary:
			blackboard.register_test_result(t.get("path", ""), t.get("tests_passed", 0), t.get("tests_failed", 0), t.get("failures", []))

func _validate_stage_handoff(role: int) -> bool:
	match role:
		PersonaConfig.Role.ARCHITECT:
			# Verify that declared resource scripts exist
			for res in blackboard.resources:
				var path = res.get("path", "")
				if path != "" and not FileAccess.file_exists(path):
					status_message.emit("[color=orange]⚠️ Gatekeeper Warning: Resource file " + path + " was not created physically. Retrying phase...[/color]")
					_execute_current_stage()
					return false
		PersonaConfig.Role.SCENE_BUILDER:
			# Verify scenes exist
			for sc in blackboard.scenes:
				var path = sc.get("path", "")
				if path != "" and not FileAccess.file_exists(path):
					status_message.emit("[color=orange]⚠️ Gatekeeper Warning: Scene file " + path + " was not created physically. Retrying phase...[/color]")
					_execute_current_stage()
					return false
	return true

func _handle_qa_evaluation():
	# Check if any tests failed in blackboard
	var total_failed = 0
	for t in blackboard.test_suites:
		total_failed += t.get("failed", 0)
		
	if total_failed > 0:
		if _auto_heal_attempts < MAX_AUTO_HEAL_ATTEMPTS:
			_auto_heal_attempts += 1
			status_message.emit("[color=orange]🔄 QA detected " + str(total_failed) + " failure(s). Entering Auto-Healing Loop (Attempt " + str(_auto_heal_attempts) + "/" + str(MAX_AUTO_HEAL_ATTEMPTS) + ")...[/color]")
			_advance_to_stage(State.STAGE_CODER)
			return
		else:
			status_message.emit("[color=red]⚠️ Max auto-heal attempts reached. " + str(total_failed) + " test(s) still failing. Handing over to user.[/color]")
			
	_advance_to_stage(State.COMPLETED)

func _on_pipeline_completed():
	status_message.emit("\n[color=green][b]🎉 Multi-Agent Orchestration Completed Successfully![/b][/color]")
	status_message.emit(blackboard.to_condensed_prompt())
	pipeline_completed.emit(blackboard)

func _fail_pipeline(msg: String):
	current_state = State.FAILED
	status_message.emit("[color=red]❌ Orchestration Error: " + msg + "[/color]")
	pipeline_failed.emit(msg)
