# Quick Start - MAGI Multi-Agent

Get MAGI-AI running in 5 minutes with any AI agent.

## Choose Your Agent

| If you want... | Use | Setup |
|----------------|-----|-------|
| Free + huge context | `gemini` | `npm install -g @google/gemini-cli` |
| Best code quality | `openai` | Set `OPENAI_API_KEY` |
| Privacy / offline | `ollama` | `winget install Ollama.Ollama` |
| GUI for local | `lmstudio` | Download from lmstudio.ai |
| Enterprise | `azure` | Configure endpoint |

## Quick Setup

### Option A: Gemini (Default, Free)

```powershell
# 1. Install
npm install -g @google/gemini-cli
gemini auth login

# 2. Run
magi-ai run "my-task"
```

### Option B: OpenAI

```powershell
# 1. Set API key
$env:OPENAI_API_KEY = "sk-..."

# 2. Run
magi-ai run "my-task" openai
```

### Option C: Ollama (Local)

```powershell
# 1. Install
winget install Ollama.Ollama

# 2. Pull a model
ollama pull codellama:13b

# 3. Run
magi-ai run "my-task" ollama
```

### Option D: Network Model

```powershell
# Point to any OpenAI-compatible API
magi-ai run "my-task" network -Endpoint http://192.168.1.100:8080/v1/chat/completions
```

## Define Your Task

Edit `MAGI_TASK.md`:

```markdown
---
task: Build REST API
test_command: npm test
---

# Task: REST API

## Success Criteria
1. [ ] GET /health returns 200
2. [ ] POST /users works
3. [ ] Tests pass
```

## Run & Monitor

```powershell
# Run
magi-ai run "my-task"

# Watch progress
magi-ai run "my-task" watch
```

## When Things Go Wrong

```powershell
# Check errors
Get-Content .MAGI\errors.log

# Add guardrail to prevent repeat
notepad .MAGI\guardrails.md
```

Add this format:
```markdown
### Sign: [What went wrong]
- **Trigger**: [When it happens]
- **Instruction**: [What to do instead]
```

## Commands Cheat Sheet

| Command | What |
|---------|------|
| `MAGI.bat` | Run default |
| `MAGI.bat openai` | Use OpenAI |
| `MAGI.bat ollama -Model codellama:34b` | Use specific model |
| `MAGI.bat watch` | Monitor logs |
| `MAGI.bat models ollama` | List models |
| `MAGI.bat init` | Reset state |

