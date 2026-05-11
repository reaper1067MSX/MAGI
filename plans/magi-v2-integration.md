# Design Document: MAGI Integrated CLI & Real SDKs

## Goal
Transform MAGI into a production-ready MCP server and CLI tool that seamlessly integrates with AI clients (Gemini CLI, Claude Desktop) and uses official AI SDKs for real task execution.

## Proposed Architecture

### 1. CLI Entry Point (`src/index.ts`)
The `magi` command will now support subcommands:
- `magi serve` (default): Starts the MCP server via stdio.
- `magi setup`: Automatically detects installed AI clients and registers the MAGI MCP server in their configuration files.
- `magi run <task>`: Executes a task iteration directly from the terminal without needing an external AI client.

### 2. Auto-Registration System (`src/cli/setup.ts`)
Logic to find and update:
- **Gemini CLI**: `~/.gemini/config.json`.
- **Claude Desktop**: `%APPDATA%\Claude\claude_desktop_config.json`.
- **VS Code**: Detect if MCP extensions are installed and suggest configuration.

### 3. Real Agent Adapters (`src/agents/`)
Replace placeholders with official SDKs:
- **Gemini**: `@google/generative-ai`.
- **Claude**: `@anthropic-ai/sdk`.
- **OpenAI**: `openai`.
- **Ollama**: Keep using `fetch` to the local API.

### 4. Interactive Console UI (Claude Code Style)
- Provide rich, filtered feedback directly in the terminal, distinguishing between:
  - **User Input**: Clear prompts and commands.
  - **Agent Reasoning**: Stylized, dim, or italic text showing the AI's "thought process".
  - **System Actions**: Spinners and status updates for tool executions, file edits, and MCP communication.
- Use `chalk`, `ora`, and potentially `boxen` or `cli-table3` to create a polished, "annexed" feel similar to Claude Code's terminal UX.

## Dependencies to Add
- `@google/generative-ai`
- `@anthropic-ai/sdk`
- `openai`
- `commander`
- `chalk`
- `ora`
- `boxen`

## Implementation Plan

### Phase 1: Dependencies & Core Refactor
- Update `package.json`.
- Refactor `src/index.ts` to use `commander`.
- Move MCP server logic to `src/mcp/server.ts`.

### Phase 2: Real SDK Integration
- Implement `src/agents/GeminiAgent.ts` with official SDK.
- Implement `src/agents/ClaudeAgent.ts` (new).
- Implement `src/agents/OpenAIAgent.ts` with official SDK.

### Phase 3: Claude-style CLI Interface & Auto-Registration
- Implement `src/cli/ui.ts` for standardized console logging (Reasoning, Actions, User).
- Implement `src/cli/setup.ts` to register in Gemini CLI and Claude Desktop.
- Implement interactive `magi run` loop.

### Phase 4: Verification & Documentation
- Run tests.
- Verify registration in a local `gemini-config.json`.
- Completely overhaul `README.md` to reflect the new hybrid CLI/Server architecture, real SDKs, and the Claude-style interactive UI. Provide clear, beautiful documentation.
