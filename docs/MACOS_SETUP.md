# MAGI for macOS

Complete guide for running MAGI on macOS (Intel and Apple Silicon).

## Requirements

- macOS 12 (Monterey) or later
- Terminal access
- Homebrew (installed automatically if needed)

## Quick Start

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/reaper1067MSX/MAGI/main/install.sh | bash
```

### Manual Installation

```bash
# Clone repository
git clone https://github.com/reaper1067MSX/MAGI.git
cd MAGI

# Run installer
chmod +x install.sh
./install.sh
```

## Agent Options

### 1. Gemini CLI (Recommended - Free)

Google's Gemini CLI is the easiest to set up:

```bash
# Install via MAGI installer
./install.sh --agent gemini

# Or manually
npm install -g @google/gemini-cli
gemini auth login
```

### 2. Ollama (Local Models)

Run AI models locally on your Mac:

```bash
# Install via MAGI installer
./install.sh --agent ollama

# Or manually via Homebrew
brew install ollama

# Start Ollama
ollama serve

# Pull a coding model
ollama pull codellama:13b
```

#### Recommended Models by Mac

| Mac Type | RAM | Recommended Model |
|----------|-----|-------------------|
| Apple Silicon | 8GB | `codellama:7b`, `phi:latest` |
| Apple Silicon | 16GB+ | `codellama:13b`, `deepseek-coder:6.7b` |
| Apple Silicon | 32GB+ | `qwen2.5-coder:14b`, `codellama:34b` |
| Intel | 16GB+ | `codellama:7b` |

Apple Silicon Macs run models on GPU (Metal) for excellent performance.

### 3. Claude Code CLI

```bash
# Install via MAGI installer
./install.sh --agent claude

# Or manually
npm install -g @anthropic-ai/claude-code

# Set API key
export ANTHROPIC_API_KEY="your-key-here"
```

## Running MAGI

### Basic Usage

```bash
# Navigate to your project
cd ~/Projects/my-app

# Create task file
cat > MAGI_TASK.md << 'EOF'
---
task: Add user authentication
test_command: npm test
---

# Task: User Authentication

Implement user login and registration.

## Success Criteria

1. [ ] POST /auth/login endpoint works
2. [ ] POST /auth/register creates new users
3. [ ] JWT tokens are generated
4. [ ] All tests pass
EOF

# Run MAGI
magi run "my-task"
```

### With Specific Agent

```bash
# Use Gemini
magi run "my-task" --agent gemini

# Use Ollama with specific model
magi run "my-task" --agent ollama --model codellama:13b

# Use Claude
magi run "my-task" --agent claude
```

## Configuration

Create `magi-config.json`:

```json
{
    "defaultAgent": "gemini",
    "agents": [
        {
            "name": "ollama",
            "type": "ollama",
            "endpoint": "http://localhost:11434/api/chat",
            "model": "codellama:13b"
        }
    ],
    "stateDirectory": ".magi"
}
```

## Apple Silicon Notes

### GPU Acceleration

Models automatically use Metal on Apple Silicon:
- Faster inference than CPU
- Lower power consumption
- Excellent for local development

### Memory Management

Ollama manages memory automatically:
- Models load/unload as needed
- Activity Monitor shows GPU usage
- Close other apps for larger models

### Performance Tips

1. **Use quantized models**: `codellama:13b-instruct-q4_K_M`
2. **Close Chrome/Electron apps**: Free up memory
3. **Run Ollama in background**: `ollama serve &`

## Intel Mac Notes

- CPU-only inference (slower than Apple Silicon)
- Limit to 7B parameter models
- Consider cloud-based agents (Gemini, Claude)

## Homebrew Setup

MAGI uses Homebrew for package management:

```bash
# Check if installed
brew --version

# Install if needed (MAGI installer does this automatically)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Apple Silicon: Add to path
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Troubleshooting

### "command not found: brew"

Apple Silicon Macs need Homebrew in PATH:

```bash
# Add to shell config
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Ollama Not Responding

```bash
# Check if running
pgrep ollama

# Start if needed
ollama serve

# Or restart
pkill ollama && ollama serve
```

### Node.js Version Issues

```bash
# Use Homebrew Node
brew install node

# Check version
node --version  # Should be 18+
```

### Permission Denied on magi.sh

```bash
chmod +x magi.sh
magi run "my-task"
```

### Model Too Slow

1. Use smaller model: `ollama pull phi:latest`
2. Close memory-intensive apps
3. Try cloud agent (Gemini is free)

## Terminal Apps

Works with any terminal:
- **Terminal.app** (built-in)
- **iTerm2** (recommended)
- **Warp**
- **Alacritty**
- **VS Code integrated terminal**

## IDE Integration

### VS Code

```bash
# Open terminal in VS Code
# Run MAGI from integrated terminal
magi run "my-task"
```

### Cursor

```bash
# Same as VS Code
magi run "my-task"
```

## Launchd Service (Optional)

Run Ollama automatically at startup:

```bash
# Create LaunchAgent
cat > ~/Library/LaunchAgents/com.ollama.server.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

# Load it
launchctl load ~/Library/LaunchAgents/com.ollama.server.plist
```

## Next Steps

1. Read [QUICKSTART.md](QUICKSTART.md) for task examples
2. Check [LOCAL_MODELS.md](LOCAL_MODELS.md) for model comparisons
3. Join our community on GitHub Discussions

