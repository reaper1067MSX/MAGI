<div align="center">
  <h1>🧙‍♂️ MAGI Orchestrator</h1>
  <p><strong>A Task-Based AI Orchestrator & MCP Server</strong></p>
  <p>
    <a href="https://www.npmjs.com/package/magi-orchestrator"><img src="https://img.shields.io/npm/v/magi-orchestrator?color=cyan&label=npm" alt="NPM Version" /></a>
    <img src="https://img.shields.io/badge/Model_Context_Protocol-Ready-blue" alt="MCP Ready" />
    <img src="https://img.shields.io/badge/Agents-Gemini_|_Claude_|_OpenAI-purple" alt="Supported Agents" />
  </p>
</div>

MAGI (formerly Ralph) is a sophisticated task-based orchestrator that brings structure to AI agents. It operates as both a global interactive CLI and a background **Model Context Protocol (MCP)** server, allowing you to seamlessly integrate its capabilities into your favorite AI clients (like Gemini CLI or Claude Desktop).

---

## 🌟 Key Features

*   **Hybrid Architecture:** Use it as an interactive CLI (`magi run`) with a beautiful, Claude-like terminal UI, or let your AI client control it silently via MCP (`magi serve`).
*   **Auto-Registration:** Run `magi setup` and MAGI will automatically inject itself into your Gemini CLI or Claude Desktop configurations. No manual JSON editing required.
*   **Real SDK Integration:** Native connections to official SDKs. MAGI reasons securely using your API keys.
*   **Persistent State Orchestration:** MAGI manages progress, activity logs, and strict guardrails natively in a local `.ralph` directory.

---

## 📦 Installation

Install MAGI globally via npm to access the CLI from anywhere:

```bash
npm install -g magi-orchestrator
```

---

## 🚀 Quick Start

### Option 1: The "Annexed" MCP Server (Recommended)

Let your favorite AI client use MAGI as a powerful background tool.

1. **Auto-Register MAGI:**
   ```bash
   magi setup
   ```
   *This command detects Gemini CLI and Claude Desktop and adds MAGI to their MCP servers list.*

2. **Configure your Agents:**
   Create a `ralph-config.json` in your project folder (or define env variables). See the [Configuration](#-configuration) section.

3. **Start chatting:**
   Open your AI client and ask: *"Iterate on the backend task using MAGI"*. The client will automatically trigger the background server.

### Option 2: Interactive CLI Mode

Run tasks directly from your terminal with rich, stylized feedback.

```bash
# Execute a task iteration interactively
magi run "build-api"
```

*Enjoy a clean UI with clear distinctions between your input, the AI's reasoning, and system actions!*

---

## ⚙️ Configuration

MAGI looks for a `ralph-config.json` file in your current working directory to understand which agents are available.

```json
{
  "agents": [
    {
      "name": "gemini-pro",
      "type": "gemini",
      "model": "gemini-2.5-pro"
    },
    {
      "name": "claude-sonnet",
      "type": "claude",
      "model": "claude-3-5-sonnet-20241022"
    },
    {
      "name": "gpt-4-smart",
      "type": "openai",
      "model": "gpt-4o"
    }
  ],
  "defaultAgent": "gemini-pro",
  "stateDirectory": ".ralph"
}
```

### 🔑 Authentication

MAGI requires API keys to communicate with the models. Set these as environment variables (or include them directly in the config, though env vars are safer):

*   **Gemini:** `GEMINI_API_KEY`
*   **Claude:** `ANTHROPIC_API_KEY`
*   **OpenAI:** `OPENAI_API_KEY`

---

## 🛠 MCP Tools Provided

When running as an MCP server, MAGI exposes the following tools to the host AI:

*   `run_ralph_iteration(taskName, agentName?)`: The core engine. Reads guardrails, builds a contextual prompt, invokes the selected agent, and persists the progress.
*   `get_ralph_status()`: Quickly retrieves the engine's active state and directory path.

---

<div align="center">
  <p>Built with 🩵 by <a href="https://github.com/reaper1067MSX">Santiago Arguello</a></p>
</div>
