# Quick Start - Ralph Multi-Agent

Get Ralph running in 5 minutes with any AI agent.

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
.\ralph.bat
```

### Option B: OpenAI

```powershell
# 1. Set API key
$env:OPENAI_API_KEY = "sk-..."

# 2. Run
.\ralph.bat openai
```

### Option C: Ollama (Local)

```powershell
# 1. Install
winget install Ollama.Ollama

# 2. Pull a model
ollama pull codellama:13b

# 3. Run
.\ralph.bat ollama
```

### Option D: Network Model

```powershell
# Point to any OpenAI-compatible API
.\ralph.bat network -Endpoint http://192.168.1.100:8080/v1/chat/completions
```

## Define Your Task

Edit `RALPH_TASK.md`:

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
.\ralph.bat

# Watch progress
.\ralph.bat watch
```

## When Things Go Wrong

```powershell
# Check errors
Get-Content .ralph\errors.log

# Add guardrail to prevent repeat
notepad .ralph\guardrails.md
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
| `ralph.bat` | Run default |
| `ralph.bat openai` | Use OpenAI |
| `ralph.bat ollama -Model codellama:34b` | Use specific model |
| `ralph.bat watch` | Monitor logs |
| `ralph.bat models ollama` | List models |
| `ralph.bat init` | Reset state |
