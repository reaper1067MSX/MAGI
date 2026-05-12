# MAGI for Linux - Setup Guide

Complete guide for running MAGI on Linux systems including Ubuntu, Debian, and Raspberry Pi OS.

## Supported Systems

| Distribution | Version | Tested |
|--------------|---------|--------|
| Ubuntu | 20.04+ | Yes |
| Debian | 11+ | Yes |
| Raspberry Pi OS | Bookworm | Yes |
| Fedora | 38+ | Yes |
| Arch Linux | Rolling | Yes |

## Quick Install

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/craigm26/MAGI/main/install.sh | bash

# Or clone and run
git clone https://github.com/craigm26/MAGI.git
cd MAGI
./install.sh
```

## Manual Setup

### 1. Install Dependencies

**Ubuntu / Debian / Raspberry Pi OS:**
```bash
sudo apt update
sudo apt install -y curl jq git
```

**Fedora:**
```bash
sudo dnf install -y curl jq git
```

**Arch Linux:**
```bash
sudo pacman -Sy curl jq git
```

### 2. Choose Your Agent

#### Option A: Gemini CLI (Recommended - Free)

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# Install Gemini CLI
sudo npm install -g @google/gemini-cli

# Authenticate
gemini auth login
```

#### Option B: Ollama (Local Models)

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull a coding model
ollama pull codellama:13b

# For Raspberry Pi, use smaller models
ollama pull codellama:7b
ollama pull phi:latest
```

#### Option C: OpenAI API

```bash
# Just set your API key
export OPENAI_API_KEY="sk-..."

# Add to .bashrc for persistence
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
```

### 3. Download MAGI

```bash
git clone https://github.com/craigm26/MAGI.git
cd MAGI
chmod +x magi.sh install.sh
```

### 4. Run MAGI

```bash
# With Gemini (default)
magi run "my-task"

# With Ollama
magi run "my-task" --agent ollama

# With OpenAI
magi run "my-task" --agent openai
```

## Raspberry Pi Setup

### Hardware Recommendations

| Model | RAM | Suitable For |
|-------|-----|--------------|
| Pi 5 8GB | 8GB | Ollama with 7B models |
| Pi 5 4GB | 4GB | API agents only |
| Pi 4 8GB | 8GB | Ollama with small models |
| Pi 4 4GB | 4GB | API agents only |

### Ollama on Raspberry Pi

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Use smaller models for Pi
ollama pull phi:latest          # 2.7GB, good for Pi
ollama pull codellama:7b        # 4GB, needs 8GB Pi
ollama pull tinyllama:latest    # 600MB, very fast

# Run MAGI with small model
magi run "my-task" --agent ollama --model phi:latest
```

### Performance Tips for Pi

1. **Use API agents** - Gemini and OpenAI work great on Pi
2. **Swap space** - Add swap for larger local models:
   ```bash
   sudo dphys-swapfile swapoff
   sudo nano /etc/dphys-swapfile  # Set CONF_SWAPSIZE=4096
   sudo dphys-swapfile setup
   sudo dphys-swapfile swapon
   ```
3. **Active cooling** - Required for sustained model inference
4. **SSD storage** - Faster than SD card for model loading

### Running as a Service

```bash
# Create service file
sudo nano /etc/systemd/system/MAGI.service
```

```ini
[Unit]
Description=MAGI Autonomous Agent
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/myproject
ExecStart=/usr/local/bin/magi run "my-task"
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable MAGI
sudo systemctl start MAGI
```

## Ubuntu Server Setup

### Headless Installation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl jq git nodejs npm

# Install Gemini CLI
sudo npm install -g @google/gemini-cli

# Clone MAGI
git clone https://github.com/craigm26/MAGI.git
cd MAGI
chmod +x magi.sh

# Run in background
nohup magi run "my-task" > magi.log 2>&1 &
```

### Using Screen or tmux

```bash
# Install screen
sudo apt install -y screen

# Start MAGI in screen
screen -S MAGI
magi run "my-task"

# Detach: Ctrl+A, D
# Reattach: screen -r MAGI
```

## Docker Setup

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl jq git nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @google/gemini-cli
RUN npm install -g magi-orchestrator

WORKDIR /app
COPY . .

CMD ["magi", "run", "my-task"]
```

```bash
docker build -t MAGI .
docker run -it -v $(pwd):/project MAGI
```

## Environment Variables

| Variable | Description | Required For |
|----------|-------------|--------------|
| `OPENAI_API_KEY` | OpenAI API key | openai agent |
| `ANTHROPIC_API_KEY` | Anthropic API key | anthropic agent |
| `GEMINI_API_KEY` | Gemini API key | gemini (optional) |
| `MAGI_AGENT` | Default agent | All |
| `MAGI_MODEL` | Default model | All |

### Setting Environment Variables

```bash
# Current session
export OPENAI_API_KEY="sk-..."

# Permanent (bash)
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
source ~/.bashrc

# Permanent (zsh)
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.zshrc
source ~/.zshrc
```

## Troubleshooting

### "jq: command not found"

```bash
sudo apt install -y jq
```

### "curl: command not found"

```bash
sudo apt install -y curl
```

### Ollama connection refused

```bash
# Start Ollama service
ollama serve

# Or as systemd service
sudo systemctl start ollama
```

### "Permission denied" on magi.sh

```bash
chmod +x magi.sh
```

### Out of memory on Raspberry Pi

```bash
# Use smaller models
magi run "my-task" --agent ollama --model phi:latest

# Or use API agents
magi run "my-task" --agent gemini
```

### Node.js version too old

```bash
# Install newer Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
```

## Network Setup (Multi-Machine)

Run Ollama on a powerful machine, use MAGI from another:

**Server (GPU machine):**
```bash
# Allow remote connections
OLLAMA_HOST=0.0.0.0 ollama serve

# Or edit systemd service
sudo systemctl edit ollama
# Add: Environment="OLLAMA_HOST=0.0.0.0"
```

**Client (Raspberry Pi or laptop):**
```bash
magi run "my-task" --agent network --endpoint http://192.168.1.100:11434/api/chat --model codellama:34b
```

## Best Practices

1. **Use Git** - MAGI commits progress, so initialize git in your project
2. **Write clear tasks** - Specific success criteria help MAGI succeed
3. **Add guardrails** - When something fails repeatedly, add a sign
4. **Monitor logs** - Use `magi run watch` to see activity (Note: check if watch is a command)
5. **Start small** - Test with 2-3 iterations before long runs

## Next Steps

- [Quick Start Guide](QUICKSTART.md) - 5-minute setup
- [Local Models Guide](LOCAL_MODELS.md) - Detailed Ollama setup
- [Configuration Reference](../templates/MAGI-config.json) - Config options

