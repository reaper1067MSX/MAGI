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

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/MAGI.git
cd MAGI

# Install dependencies
npm install

# Create a branch
git checkout -b feature/your-feature-name

# Make changes and build
npm run build

# Test your changes
magi run "test-task"
```

## Coding Style

### TypeScript

- Use explicit types and interfaces
- Use descriptive variable names
- Add comments for complex logic
- Follow [MAGI's established patterns](src/GEMINI.md)

```typescript
// Good
async function runIteration(agent: AgentAdapter, taskName: string): Promise<IterationResult> {
    // Process one autonomous loop
    ...
}
```

### Documentation

- Use clear, concise language in English
- Include code examples
- Keep formatting consistent with existing docs

## Testing

Before submitting a PR, test with at least:

1. **Local tests**: `npm test`
2. **Integration tests**: `src/__tests__/e2e.test.ts`
3. **One CLI agent** (Gemini or Cursor)
4. **One API agent** (OpenAI or Ollama)

```bash
# Run automated tests
npm test

# Manual test
magi run "test-task" --agent gemini
```

## Project Structure

```
MAGI/
├── bin/                # CLI entry point
├── dist/               # Compiled code
├── docs/               # Guides and documentation
├── src/                # Source code (TypeScript)
│   ├── agents/         # AI agent adapters
│   ├── cli/            # CLI UI and setup logic
│   ├── engine/         # Core orchestration engine
│   ├── mcp/            # MCP server implementation
│   └── types/          # Shared type definitions
├── templates/          # Config and task templates
├── README.md           # Main documentation
├── LICENSE             # MIT License
├── CONTRIBUTING.md     # This file
├── CODE_OF_CONDUCT.md
└── CHANGELOG.md        # History of changes
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

