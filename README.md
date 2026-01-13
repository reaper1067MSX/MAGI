# Ralph - Multi-Agent Autonomous Development

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/powershell-5.1%2B-blue?style=flat-square" alt="PowerShell">
  <img src="https://img.shields.io/github/stars/craigm26/Ralph?style=flat-square" alt="Stars">
</p>

A Windows implementation of [Geoffrey Huntley's Ralph Wiggum technique](https://ghuntley.com/ralph/) for autonomous AI development with deliberate context management. Supports **10+ AI agents** including cloud APIs, local models, and networked deployments.

> *"Context is memory. malloc() exists. free() doesn't. Ralph is just accepting that reality."*

## The Problem

AI coding agents get stuck when:
- Context windows fill up with failed attempts
- They repeat the same mistakes endlessly
- There's no way to pass learnings between sessions

## The Solution

Ralph implements a **deliberate context rotation strategy**:

1. **Fresh Context Each Iteration** - Agent starts clean, reads state from files
2. **Guardrails (Signs)** - Lessons learned are written to files, not memory
3. **Git as Persistence** - All progress is committed, nothing is lost
4. **Multi-Agent Support** - Switch between cloud and local models seamlessly

## Supported Agents

| Agent | Type | Best For | Context |
|-------|------|----------|---------|
| **Gemini CLI** | Cloud CLI | Large projects, free tier | 1M+ tokens |
| **Cursor** | Cloud CLI | Multi-model, IDE integration | 100K tokens |
| **OpenAI** | Cloud API | GPT-4o, o1 reasoning | 128K tokens |
| **Anthropic** | Cloud API | Claude models | 200K tokens |
| **Ollama** | Local | Privacy, offline work | 32K+ tokens |
| **LM Studio** | Local | GUI, easy model switching | 32K+ tokens |
| **LocalAI** | Local/Network | Self-hosted, OpenAI-compatible | Varies |
| **Network** | Network | Custom deployments | Varies |
| **VS Code** | Manual | IDE integration | 100K tokens |

## Quick Start

### Installation

```powershell
# Clone the repository
git clone https://github.com/craigm26/Ralph.git
cd Ralph

# Or download and extract
Expand-Archive ralph-windows.zip -DestinationPath .
```

### Choose Your Agent

**Option A: Gemini (Default, Free)**
```powershell
npm install -g @google/gemini-cli
gemini auth login
.\ralph.bat
```

**Option B: OpenAI**
```powershell
$env:OPENAI_API_KEY = "sk-..."
.\ralph.bat openai
```

**Option C: Ollama (Local)**
```powershell
winget install Ollama.Ollama
ollama pull codellama:13b
.\ralph.bat ollama
```

### Define Your Task

Create `RALPH_TASK.md`:

```markdown
---
task: Build REST API
test_command: npm test
---

# Task: REST API

## Success Criteria
1. [ ] GET /health returns 200
2. [ ] POST /users creates user
3. [ ] All tests pass
```

### Run

```powershell
.\ralph.bat              # Use default agent
.\ralph.bat openai       # Use OpenAI
.\ralph.bat ollama       # Use local Ollama
.\ralph.bat watch        # Monitor progress
```

## How It Works

```
                          RALPH LOOP
                              │
    ┌─────────────────────────┼─────────────────────────┐
    │                         │                         │
    ▼                         ▼                         ▼
┌─────────┐           ┌─────────────┐           ┌─────────────┐
│  Read   │           │   Execute   │           │   Commit    │
│  State  │    ───►   │    Agent    │    ───►   │  Progress   │
│  Files  │           │    Task     │           │   to Git    │
└─────────┘           └─────────────┘           └─────────────┘
    │                         │                         │
    │    .ralph/              │                         │
    │    ├── progress.md      │                         │
    │    ├── guardrails.md    │         If not done     │
    │    └── errors.log       │              │          │
    │                         │              ▼          │
    └─────────────────────────┴──────── ROTATE ◄───────┘
                                    (Fresh Context)
```

**Key Insight**: Each iteration starts with a fresh context window. Progress and learnings are persisted in files, not in the agent's memory.

## Commands

| Command | Description |
|---------|-------------|
| `ralph.bat` | Run with default agent |
| `ralph.bat <agent>` | Run with specific agent |
| `ralph.bat <agent> -Model <model>` | Use specific model |
| `ralph.bat <agent> -Endpoint <url>` | Custom API endpoint |
| `ralph.bat <agent> -MaxIterations <n>` | Limit iterations |
| `ralph.bat watch` | Monitor activity logs |
| `ralph.bat models <agent>` | List available models |
| `ralph.bat init` | Reset Ralph state |

## Configuration

Edit `.ralph-scripts/ralph-config.json`:

```json
{
    "defaultAgent": "gemini",
    "maxIterations": 20,
    "agents": {
        "ollama": {
            "endpoint": "http://localhost:11434/api/chat",
            "defaultModel": "deepseek-coder:33b"
        }
    }
}
```

## Environment Variables

| Variable | Used By | Description |
|----------|---------|-------------|
| `OPENAI_API_KEY` | openai | OpenAI API key |
| `ANTHROPIC_API_KEY` | anthropic | Anthropic API key |
| `GOOGLE_API_KEY` | gemini (optional) | Gemini API key |
| `RALPH_AGENT` | all | Default agent override |
| `RALPH_MODEL` | all | Default model override |

## Documentation

- [Quick Start Guide](docs/QUICKSTART.md)
- [Local Models Setup](docs/LOCAL_MODELS.md)
- [VS Code Integration](docs/VSCODE_GUIDE.md)
- [Configuration Reference](docs/CONFIGURATION.md)

## Choosing an Agent

| Priority | Recommendation |
|----------|----------------|
| **Maximum Context** | Gemini CLI (1M+ tokens, free) |
| **Best Code Quality** | OpenAI GPT-4o or Anthropic Claude |
| **Privacy/Offline** | Ollama with DeepSeek Coder |
| **Enterprise** | Azure OpenAI |
| **Cost Optimization** | Gemini CLI or local Ollama |

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

## Credits

- **Original technique**: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- **Cursor implementation**: [Agrim Singh](https://github.com/agrimsingh/ralph-wiggum-cursor)
- **Multi-agent Windows port**: This implementation

## License

[MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.
