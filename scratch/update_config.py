import os
import json
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")

# 1. Update config.mjs
config_path = os.path.join(DOCS, ".vitepress", "config.mjs")
with open(config_path, "r", encoding="utf-8") as f:
    config_content = f.read()

# Replace descriptions: Godot 4.6 -> Godot 4.7+
config_content = config_content.replace("Godot 4.6", "Godot 4.7+")
config_content = config_content.replace("Godot 4.", "Godot 4.7+.")
config_content = config_content.replace("Godot 4.7+..", "Godot 4.7+.")
config_content = config_content.replace("Godot 4.7+.6", "Godot 4.7+")

# Localized MCP sidebar items and tool labels
mcp_labels = {
    "es": {"mcp": "🔌 Servidor MCP (IDEs Externas)", "tools": "Las 65 Tools de la IA", "orch": "Orquestación, Auto-Healing y Personas"},
    "fr": {"mcp": "🔌 Serveur MCP (IDEs Externes)", "tools": "Les 65 outils de l'IA", "orch": "Orchestration, Auto-Guérison et Personas"},
    "de": {"mcp": "🔌 MCP-Server (Externe IDEs)", "tools": "Alle 65 KI-Tools", "orch": "Orchestrierung, Auto-Healing & Personas"},
    "hi": {"mcp": "🔌 एमसीपी सर्वर (बाहरी IDEs)", "tools": "सभी 65 एआई टूल्स", "orch": "ऑर्केस्ट्रेशन, ऑटो-हीलिंग और पर्सोना"},
    "zh_CN": {"mcp": "🔌 MCP 服务器 (外部 IDE)", "tools": "全部 65 项 AI 工具", "orch": "多代理编排、自愈与人格"},
    "ar": {"mcp": "🔌 خادم MCP (بيئات التطوير الخارجية)", "tools": "جميع أدوات الذكاء الاصطناعي الـ 65", "orch": "التنسيق، العلاج التلقائي والشخصيات"},
    "ru": {"mcp": "🔌 Сервер MCP (Внешние IDE)", "tools": "Все 65 инструментов ИИ", "orch": "Оркестрация, автоисправление и персоны"},
    "bn": {"mcp": "🔌 এমসিপি সার্ভার (বাহ্যিক IDEs)", "tools": "সবগুলো ৬৫টি AI টুলস", "orch": "অর্কেস্ট্রেশন, অটো-হিলিং এবং পারসোনা"},
    "id": {"mcp": "🔌 Server MCP (IDE Eksternal)", "tools": "Semua 65 Alat AI", "orch": "Orkestrasi, Auto-Healing & Persona"}
}

for lang, labels in mcp_labels.items():
    # Insert MCP server before tools-reference if not already there
    mcp_line = f"              {{ text: '{labels['mcp']}', link: '/{lang}/advanced/mcp-server' }},\n"
    tools_pat = rf"(\s*\{{\s*text:\s*['\"][^'\"]*Tools?[^'\"]*['\"],\s*link:\s*['\"]/{lang}/advanced/tools-reference['\"]\s*\}},?)"
    
    match = re.search(tools_pat, config_content)
    if match:
        old_tool_line = match.group(0)
        # check if mcp line already precedes it
        prefix_check = f"/{lang}/advanced/mcp-server"
        if prefix_check not in config_content:
            new_block = mcp_line + f"              {{ text: '{labels['tools']}', link: '/{lang}/advanced/tools-reference' }},"
            config_content = config_content.replace(old_tool_line, new_block)
        else:
            new_tool_line = f"              {{ text: '{labels['tools']}', link: '/{lang}/advanced/tools-reference' }},"
            config_content = config_content.replace(old_tool_line, new_tool_line)

    # Update agent intelligence line
    agent_pat = rf"(\s*\{{\s*text:\s*['\"][^'\"]*['\"],\s*link:\s*['\"]/{lang}/core-features/agent-intelligence['\"]\s*\}})"
    agent_match = re.search(agent_pat, config_content)
    if agent_match:
        old_agent_line = agent_match.group(0)
        new_agent_line = f"              {{ text: '{labels['orch']}', link: '/{lang}/core-features/agent-intelligence' }}"
        config_content = config_content.replace(old_agent_line, new_agent_line)

with open(config_path, "w", encoding="utf-8") as f:
    f.write(config_content)

print("config.mjs updated successfully!")
