# Contributing to Ralph

Thank you for your interest in contributing to Ralph! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

1. **Environment details**: Windows version, PowerShell version, agent type
2. **Steps to reproduce**: Clear, numbered steps
3. **Expected behavior**: What you expected to happen
4. **Actual behavior**: What actually happened
5. **Logs**: Contents of `.ralph/errors.log` and `.ralph/activity.log`
6. **Configuration**: Your `ralph-config.json` (with sensitive data removed)

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
git clone https://github.com/YOUR_USERNAME/Ralph.git
cd Ralph

# Create a branch
git checkout -b feature/your-feature-name

# Make changes and test
.\ralph.bat <agent> -MaxIterations 3
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
.\ralph.bat gemini -MaxIterations 2 -Force

# Test with different agent
.\ralph.bat ollama -Model codellama:7b -MaxIterations 2 -Force
```

## Adding a New Agent

To add support for a new AI agent:

1. **Add configuration** in `ralph.ps1`:
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
Ralph/
├── ralph.ps1           # Main script
├── ralph.bat           # Windows launcher
├── docs/
│   ├── QUICKSTART.md
│   ├── LOCAL_MODELS.md
│   └── VSCODE_GUIDE.md
├── templates/
│   ├── RALPH_TASK_example.md
│   └── ralph-config.json
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
└── CHANGELOG.md
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
