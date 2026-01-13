# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in Ralph, please report it responsibly:

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Provide detailed information about the vulnerability
4. Allow reasonable time for a fix before public disclosure

## Security Considerations

### API Keys

Ralph handles API keys for various AI providers. Please follow these best practices:

- **Never commit API keys** to version control
- Use environment variables to store keys: `$env:OPENAI_API_KEY = "sk-..."`
- For permanent storage, use Windows Credential Manager or encrypted environment variables
- Review `.gitignore` to ensure sensitive files are excluded

### Local vs Cloud Execution

- **Cloud agents** (OpenAI, Anthropic, Gemini): Your prompts and code context are sent to external APIs
- **Local agents** (Ollama, LM Studio): All processing stays on your machine
- Consider using local agents for sensitive or proprietary code

### File System Access

Ralph and AI agents can read and write files in your project directory. Be aware that:

- Agents may read any file in the project to understand context
- Agents may create or modify files as part of their work
- Use the guardrails system to restrict unwanted file access

### Network Requests

When using network agents, ensure:

- You trust the endpoint you're connecting to
- The connection is encrypted (HTTPS) when possible
- You're not exposing sensitive data to untrusted servers

## Best Practices

1. **Review agent output** before committing to production
2. **Use git** to track all changes and enable rollback
3. **Set `maxIterations`** to prevent runaway loops
4. **Monitor activity logs** in `.ralph/activity.log`
5. **Add guardrails** for sensitive operations
