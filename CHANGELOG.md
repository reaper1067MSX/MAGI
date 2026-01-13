# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-12

### Added

- Initial public release
- Multi-agent support for 10+ AI providers:
  - Cloud CLI: Gemini, Cursor
  - Cloud API: OpenAI, Anthropic, Azure OpenAI
  - Local: Ollama, LM Studio, LocalAI
  - Network: Custom OpenAI-compatible endpoints
  - Manual: VS Code integration
- Deliberate context rotation strategy
- Guardrails system for learning from failures
- Git-based progress persistence
- Configurable via JSON configuration file
- Watch mode for monitoring activity
- Task definition via markdown files with frontmatter

### Credits

- Based on [Geoffrey Huntley's Ralph Wiggum technique](https://ghuntley.com/ralph/)
- Inspired by [Agrim Singh's Cursor implementation](https://github.com/agrimsingh/ralph-wiggum-cursor)
