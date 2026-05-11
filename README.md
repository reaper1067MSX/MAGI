<div align="center">
  <h1>🧙‍♂️ MAGI Orchestrator (magi-ai)</h1>
  <p><strong>The Task-Based AI Orchestrator & MCP Server</strong></p>
  <p>
    <a href="https://www.npmjs.com/package/magi-orchestrator"><img src="https://img.shields.io/npm/v/magi-orchestrator?color=cyan&label=npm" alt="NPM Version" /></a>
    <img src="https://img.shields.io/badge/Model_Context_Protocol-Ready-blue" alt="MCP Ready" />
    <img src="https://img.shields.io/badge/Agents-Gemini_|_Claude_|_OpenAI-purple" alt="Supported Agents" />
    <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
  </p>
</div>

---

**MAGI-AI** is a high-performance, task-based AI orchestrator designed to bring structure, persistence, and specialized intelligence to autonomous development. It operates as a bridge between your preferred AI models and your local environment, functioning simultaneously as a **powerful interactive CLI** and a background **Model Context Protocol (MCP) server**.

## 🌟 Why MAGI-AI? (Key Benefits)

*   **Professional Interactive UI**: Inspired by Claude Code, featuring dimmed reasoning for better focus, real-time action spinners, and clean result boxes.
*   **Hybrid Power**: Use it directly in your terminal for dedicated focus, or annex it to your favorite AI client (Gemini CLI, Claude Desktop) via MCP.
*   **Persistent Orchestration**: Unlike standard chat interfaces, MAGI manages its own state in a local `.magi` directory, including progress logs, activity history, and strict **Guardrails** (Signs) to prevent AI loops.
*   **Native SDK Integration**: Fast and secure connections to official Google Gemini, Anthropic Claude, and OpenAI SDKs. No middleman proxies.
*   **Zero-Touch Automation**: Registration and skill installation happen automatically. Just install and start orquestrating.

---

## 📦 Installation

Install **MAGI Orchestrator** globally via npm to get the `magi-ai` command:

```bash
# Official installation
npm install -g magi-orchestrator
```

*Note: The automatic registration script (`postinstall`) will detect your Gemini CLI and Claude Desktop configurations and inject the MAGI server/skill automatically.*

---

## 🚀 How it Operates (Quick Start)

### Option 1: Interactive CLI Mode (Recommended for Focus)
Run tasks directly from your terminal with rich, stylized feedback.

```bash
# Execute a task iteration interactively
magi-ai run "build-auth-layer"
```

### Option 2: The "Annexed" Mode (Skill Injection)
Open your **Gemini CLI** and use the native skill:
> `/magi-ai run "fix-login-bug"`
> *MAGI will work in the background and report progress directly to your chat session.*

---

## ⚙️ Configuration

MAGI looks for a `magi-config.json` file in your project directory. If not found, it uses sensible defaults.

```json
{
  "agents": [
    {
      "name": "gemini-flash",
      "type": "gemini",
      "model": "gemini-2.0-flash"
    },
    {
      "name": "claude-sonnet",
      "type": "claude",
      "model": "claude-3-5-sonnet-20241022"
    }
  ],
  "defaultAgent": "gemini-flash",
  "stateDirectory": ".magi"
}
```

### 🔑 Authentication
Set your API keys as environment variables:
*   `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`.

---

## 🛠 Operation Mechanics: The .magi Directory

MAGI keeps your project context clean by orchestrating everything inside the `.magi` folder:
*   **`progress.md`**: Tracking success criteria and current status.
*   **`guardrails.md`**: Active "Signs" learned from previous failures to guide the AI.
*   **`activity.log`**: Detailed history of every decision and action.

---

## 🛠 Available CLI Commands

| Command | Description |
|---------|-------------|
| `magi-ai run <task>` | Start/Continue a task iteration interactively. |
| `magi-ai setup` | Manually trigger auto-registration in AI clients. |
| `magi-ai serve` | Start the MCP server (STDIO). |
| `magi-ai --version` | Report the current version (v1.2.0). |

---

<div align="center">
  <p>Built with 🩵 by <a href="https://github.com/reaper1067MSX">Santiago Arguello</a></p>
  <p><em>"Bringing divine structure to chaotic agents."</em></p>
</div>
