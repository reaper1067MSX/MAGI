# MAGI Orchestrator (formerly Ralph)

MAGI is a task-based AI orchestrator, now modernized as a Node.js [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server.

## Features

- **Multi-Agent Support**: Gemini (CLI), OpenAI (API), and Ollama (Local).
- **Task Orchestration**: Manages state, guardrails, and progress in `.ralph` directory.
- **MCP Integration**: Exposes MAGI logic as actionable tools for AI clients.

## Installation

### Via NPM (Official)
```bash
npm install -g magi-orchestrator
```

## Usage

After installation, you can use the `magi` command:

```bash
magi --help
```

### Register as MCP Server

#### Gemini CLI
Add the following to your config:

```json
{
  "mcpServers": {
    "magi": {
      "command": "magi-orchestrator"
    }
  }
}
```

## Tools Provided
- `run_ralph_iteration(taskName, agentName?)`: Runs a single loop iteration for the specified task.
- `get_ralph_status()`: Returns the engine status and state directory.

## Configuration

Create a `ralph-config.json` in your working directory:

```json
{
  "agents": [
    {
      "name": "gemini-cli",
      "type": "gemini"
    }
  ],
  "defaultAgent": "gemini-cli",
  "stateDirectory": ".ralph"
}
```

## Development

- `npm run build`: Compile TypeScript.
- `npm test`: Run unit and E2E tests.
