# Ralph - Multi-Agent Autonomous Development

<p align="center">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Cloud-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="License">
  <img src="https://img.shields.io/github/stars/craigm26/Ralph?style=flat-square" alt="Stars">
  <img src="https://img.shields.io/github/v/release/craigm26/Ralph?style=flat-square" alt="Release">
</p>

A cross-platform implementation of [Geoffrey Huntley's Ralph Wiggum technique](https://ghuntley.com/ralph/) for autonomous AI development with deliberate context management. Supports **10+ AI agents** including cloud APIs, local models, and networked deployments.

> *"Context is memory. malloc() exists. free() doesn't. Ralph is just accepting that reality."*

## Platform Support

| Platform | Script | Status |
|----------|--------|--------|
| Windows | `ralph.bat` / `ralph.ps1` | ✅ Supported |
| macOS (Intel & Apple Silicon) | `ralph.sh` | ✅ Supported |
| Ubuntu / Debian | `ralph.sh` | ✅ Supported |
| Raspberry Pi OS | `ralph.sh` | ✅ Supported |
| Fedora / Arch | `ralph.sh` | ✅ Supported |
| Cloud / VPS | `ralph.sh` | ✅ Supported |

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
| **Claude Code** | Cloud CLI | Anthropic models | 200K tokens |
| **OpenAI** | Cloud API | GPT-4o, o1 reasoning | 128K tokens |
| **Anthropic** | Cloud API | Claude models | 200K tokens |
| **Ollama** | Local | Privacy, offline work | 32K+ tokens |
| **LM Studio** | Local | GUI, easy model switching | 32K+ tokens |
| **LocalAI** | Local/Network | Self-hosted, OpenAI-compatible | Varies |
| **Network** | Network | Custom deployments | Varies |

## Quick Start

### macOS

```bash
# One-line install (works on Intel and Apple Silicon)
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash

# Or manual setup
git clone https://github.com/craigm26/Ralph.git
cd Ralph
chmod +x ralph.sh install.sh

# Run with Gemini (default, free)
npm install -g @google/gemini-cli && gemini auth login
./ralph.sh

# Or with Ollama (local - runs on GPU with Apple Silicon)
brew install ollama
ollama serve &
ollama pull codellama:13b
./ralph.sh ollama
```

### Linux / Raspberry Pi

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash

# Or manual setup
git clone https://github.com/craigm26/Ralph.git
cd Ralph
chmod +x ralph.sh install.sh

# Install dependencies
sudo apt install -y curl jq git

# Run with Gemini (default, free)
npm install -g @google/gemini-cli && gemini auth login
./ralph.sh

# Or with Ollama (local)
curl -fsSL https://ollama.com/install.sh | sh
ollama pull codellama:13b
./ralph.sh ollama

# Or with OpenAI
export OPENAI_API_KEY="sk-..."
./ralph.sh openai
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/craigm26/Ralph.git
cd Ralph

# Run with Gemini (default, free)
npm install -g @google/gemini-cli
gemini auth login
.\ralph.bat

# Or with Ollama (local)
winget install Ollama.Ollama
ollama pull codellama:13b
.\ralph.bat ollama

# Or with OpenAI
$env:OPENAI_API_KEY = "sk-..."
.\ralph.bat openai
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

```bash
# Linux
./ralph.sh              # Use default agent
./ralph.sh openai       # Use OpenAI
./ralph.sh ollama       # Use local Ollama
./ralph.sh watch        # Monitor progress
```

```powershell
# Windows
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

### Linux

| Command | Description |
|---------|-------------|
| `./ralph.sh` | Run with default agent |
| `./ralph.sh <agent>` | Run with specific agent |
| `./ralph.sh <agent> --model <model>` | Use specific model |
| `./ralph.sh <agent> --endpoint <url>` | Custom API endpoint |
| `./ralph.sh <agent> --max-iterations <n>` | Limit iterations |
| `./ralph.sh watch` | Monitor activity logs |
| `./ralph.sh <agent> --list-models` | List available models |

### Windows

| Command | Description |
|---------|-------------|
| `ralph.bat` | Run with default agent |
| `ralph.bat <agent>` | Run with specific agent |
| `ralph.bat <agent> -Model <model>` | Use specific model |
| `ralph.bat <agent> -Endpoint <url>` | Custom API endpoint |
| `ralph.bat <agent> -MaxIterations <n>` | Limit iterations |
| `ralph.bat watch` | Monitor activity logs |
| `ralph.bat models <agent>` | List available models |

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
- [macOS Setup Guide](docs/MACOS_SETUP.md) - Intel and Apple Silicon
- [Linux Setup Guide](docs/LINUX_SETUP.md) - Ubuntu, Debian, Raspberry Pi
- [Server/Cloud Setup](docs/SERVER_SETUP.md) - AWS, GCP, DigitalOcean, CI/CD
- [Local Models Setup](docs/LOCAL_MODELS.md)
- [VS Code Integration](docs/VSCODE_GUIDE.md)

## Choosing an Agent

| Priority | Recommendation |
|----------|----------------|
| **Maximum Context** | Gemini CLI (1M+ tokens, free) |
| **Best Code Quality** | OpenAI GPT-4o or Anthropic Claude |
| **Privacy/Offline** | Ollama with DeepSeek Coder |
| **Raspberry Pi** | Ollama with phi or codellama:7b |
| **Cost Optimization** | Gemini CLI or local Ollama |

## Raspberry Pi Tips

```bash
# Use smaller models on Pi
ollama pull phi:latest          # 2.7GB, works on 4GB Pi
ollama pull codellama:7b        # 4GB, needs 8GB Pi

# Run with small model
./ralph.sh ollama --model phi:latest

# Or use cloud APIs (no GPU needed)
./ralph.sh gemini
```

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md).

## Credits

- **Original technique**: [Geoffrey Huntley](https://ghuntley.com/ralph/)
- **Cursor implementation**: [Agrim Singh](https://github.com/agrimsingh/ralph-wiggum-cursor)
- **Cross-platform port**: This implementation

## License

[MIT License](LICENSE) - see the [LICENSE](LICENSE) file for details.
