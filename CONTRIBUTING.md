# Contributing to MAGI

Thank you for your interest in contributing to MAGI! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

1. **Environment details**: Windows version, PowerShell version, agent type
2. **Steps to reproduce**: Clear, numbered steps
3. **Expected behavior**: What you expected to happen
4. **Actual behavior**: What actually happened
5. **Logs**: Contents of `.MAGI/errors.log` and `.MAGI/activity.log`
6. **Configuration**: Your `MAGI-config.json` (with sensitive data removed)

### Suggesting Features

Feature suggestions are welcome! Please include:

1. **Problem description**: What problem does this solve?
2. **Proposed solution**: How would this work?
3. **Alternatives considered**: Other approaches you've thought of
4. **Use cases**: Who would benefit and how?

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the coding style** (see below)
3. **Test your changes** with multiple agents
4. **Update documentation** if needed
5. **Write a clear PR description**

## Development Setup

```powershell
# Clone your fork
git clone https://github.com/YOUR_USERNAME/MAGI.git
cd MAGI

# Create a branch
git checkout -b feature/your-feature-name

# Make changes and test
.\MAGI.bat <agent> -MaxIterations 3
```

## Coding Style

### PowerShell

- Use PascalCase for function names: `Get-TaskInfo`, `Invoke-Agent`
- Use descriptive variable names
- Add comments for complex logic
- Follow [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/strongly-encouraged-development-guidelines)

```powershell
# Good
function Get-TaskInfo {
    param([string]$TaskFilePath)
    # Parse task file and return structured info
    ...
}

# Avoid
function gti {
    param($p)
    ...
}
```

### Documentation

- Use clear, concise language
- Include code examples
- Keep formatting consistent with existing docs

## Testing

Before submitting a PR, test with at least:

1. **One CLI agent** (Gemini or Cursor)
2. **One API agent** (OpenAI or Ollama)
3. **Edge cases**: Empty task file, missing config, etc.

```powershell
# Basic test
.\MAGI.bat gemini -MaxIterations 2 -Force

# Test with different agent
.\MAGI.bat ollama -Model codellama:7b -MaxIterations 2 -Force
```

## Adding a New Agent

To add support for a new AI agent:

1. **Add configuration** in `MAGI.ps1`:
```powershell
$script:DefaultConfig.agents["newagent"] = @{
    type = "api"  # or "cli"
    endpoint = "https://api.example.com/v1/chat"
    defaultModel = "model-name"
    contextLimit = 100000
    apiKeyEnvVar = "NEWAGENT_API_KEY"
}
```

2. **Implement the client** if needed (for non-OpenAI-compatible APIs)

3. **Update documentation**:
   - Add to README.md agents table
   - Add setup instructions to docs/

4. **Test thoroughly** with real API calls

## Project Structure

```
MAGI/
â”œâ”€â”€ MAGI.ps1           # Main script
â”œâ”€â”€ MAGI.bat           # Windows launcher
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ QUICKSTART.md
â”‚   â”œâ”€â”€ LOCAL_MODELS.md
â”‚   â””â”€â”€ VSCODE_GUIDE.md
â”œâ”€â”€ templates/
â”‚   â”œâ”€â”€ MAGI_TASK_example.md
â”‚   â””â”€â”€ MAGI-config.json
â”œâ”€â”€ README.md
â”œâ”€â”€ LICENSE
â”œâ”€â”€ CONTRIBUTING.md
â”œâ”€â”€ CODE_OF_CONDUCT.md
â””â”€â”€ CHANGELOG.md
```

## Commit Messages

Use clear, descriptive commit messages:

```
feat: Add support for Azure OpenAI agent
fix: Handle empty API response gracefully
docs: Update Ollama setup instructions
refactor: Simplify prompt building logic
```

Prefix types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code change that doesn't fix a bug or add a feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

## Questions?

Feel free to:
- Open an issue for questions
- Start a discussion in GitHub Discussions
- Reach out to maintainers

Thank you for contributing!

