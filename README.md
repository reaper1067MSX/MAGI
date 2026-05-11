# Ralph MCP Server

Ralph is a task-based AI orchestrator, now modernized as a Node.js [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server.

## Features

- **Multi-Agent Support**: Gemini (CLI), OpenAI (API), and Ollama (Local).
- **Task Orchestration**: Manages state, guardrails, and progress in `.ralph` directory.
- **MCP Integration**: Exposes Ralph logic as actionable tools for AI clients.

## Installation

### From Source
```bash
git clone https://github.com/craigm26/Ralph.git
cd Ralph
npm install
npm run build
npm link # To install 'ralph-mcp' globally
```

## Usage as MCP Server

### Register in Gemini CLI
Add the following to your config:

```json
{
  "mcpServers": {
    "ralph": {
      "command": "node",
      "args": ["C:/absolute/path/to/Ralph/dist/index.js"]
    }
  }
}
```

### Tools Provided
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
    },
    {
      "name": "my-gpt4",
      "type": "openai",
      "model": "gpt-4"
    }
  ],
  "defaultAgent": "gemini-cli",
  "stateDirectory": ".ralph"
}
```

## Development

- `npm run build`: Compile TypeScript.
- `npm test`: Run unit and E2E tests.
