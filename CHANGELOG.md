# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-12

### Added

- **macOS Support** - Full support for Intel and Apple Silicon Macs
  - Homebrew integration for package management
  - Apple Silicon GPU acceleration with Ollama
  - Automatic detection of Mac architecture
  - `docs/MACOS_SETUP.md` - Comprehensive macOS setup guide
- **Server/Cloud Support** - Deploy Ralph on any server or cloud platform
  - AWS EC2, Google Cloud, Azure, DigitalOcean, Linode, Vultr, Hetzner
  - CI/CD integration (GitHub Actions, GitLab CI, Jenkins)
  - Docker and Docker Compose configurations
  - Systemd service setup for headless operation
  - `docs/SERVER_SETUP.md` - Complete server deployment guide
- Interactive installer now supports macOS
- Homebrew-based installation for Node.js, Ollama, and dependencies on macOS

### Changed

- `install.sh` now detects macOS and uses Homebrew automatically
- `ralph.sh` header updated to reflect cross-platform support
- README platform badge updated to include macOS and Cloud
- Documentation section expanded with new guides

## [1.1.0] - 2026-01-12

### Added

- **Linux Support** - Full cross-platform compatibility
  - `ralph.sh` - Bash script for Linux systems
  - `install.sh` - Interactive installer for Linux
  - Support for Ubuntu, Debian, Fedora, Arch Linux
  - **Raspberry Pi OS support** with optimized recommendations
- New documentation:
  - `docs/LINUX_SETUP.md` - Comprehensive Linux setup guide
  - Raspberry Pi-specific tips and hardware recommendations
  - Docker setup instructions
  - Network/multi-machine configuration
- Claude Code CLI agent support for Linux
- Anthropic API agent support

### Changed

- README updated with cross-platform Quick Start
- Platform support table in documentation
- Unified command reference for Linux and Windows

### Fixed

- Date typo in v1.0.0 changelog (was 2025, now 2026)

## [1.0.0] - 2026-01-12

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
