# Ralph for Servers & Cloud

Deploy Ralph on cloud VMs, VPS, and headless servers for CI/CD pipelines and autonomous development.

## Supported Platforms

| Platform | Tested | Notes |
|----------|--------|-------|
| AWS EC2 | ✓ | Ubuntu, Amazon Linux |
| Google Cloud | ✓ | Compute Engine |
| Azure | ✓ | Virtual Machines |
| DigitalOcean | ✓ | Droplets |
| Linode | ✓ | Compute Instances |
| Vultr | ✓ | Cloud Compute |
| Hetzner | ✓ | Cloud Servers |
| Oracle Cloud | ✓ | Free tier available |
| Raspberry Pi | ✓ | See [LINUX_SETUP.md](LINUX_SETUP.md) |

## Quick Start

### One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash -s -- --agent gemini
```

### SSH Installation

```bash
# Connect to your server
ssh user@your-server

# Install Ralph with Gemini
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash -s -- --agent gemini

# Or clone and install manually
git clone https://github.com/craigm26/Ralph.git
cd Ralph
./install.sh --all
```

## Server Configurations

### Minimal Server (1GB RAM)

Best for: CI/CD pipelines, small tasks

```bash
# Install with Gemini only (cloud-based, no local models)
./install.sh --agent gemini

# Configuration
export GEMINI_API_KEY="your-key"
```

Recommended instances:
- AWS: t3.micro
- DigitalOcean: Basic $6/month
- Linode: Nanode 1GB

### Standard Server (4-8GB RAM)

Best for: Regular development, small local models

```bash
# Install with Ollama
./install.sh --agent ollama

# Pull efficient models
ollama pull phi:latest
ollama pull codellama:7b
```

Recommended instances:
- AWS: t3.medium
- DigitalOcean: Basic $24/month
- Linode: Linode 4GB

### GPU Server (For Local Models)

Best for: Large local models, fast inference

```bash
# Install NVIDIA drivers (Ubuntu)
sudo apt install nvidia-driver-535
sudo reboot

# Install Ollama
./install.sh --agent ollama

# Pull larger models
ollama pull codellama:34b
ollama pull qwen2.5-coder:14b
```

Recommended instances:
- AWS: g4dn.xlarge (T4 GPU)
- GCP: n1-standard-4 + T4
- Lambda Labs: GPU Cloud

## Headless Operation

### Running in Background

```bash
# Using nohup
nohup ./ralph.sh > ralph.log 2>&1 &

# Using screen
screen -S ralph
./ralph.sh
# Ctrl+A, D to detach

# Using tmux
tmux new -s ralph
./ralph.sh
# Ctrl+B, D to detach
```

### Systemd Service

Create `/etc/systemd/system/ralph.service`:

```ini
[Unit]
Description=Ralph Autonomous Development
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/my-project
ExecStart=/home/ubuntu/Ralph/ralph.sh
Restart=on-failure
RestartSec=10
Environment=GEMINI_API_KEY=your-key-here

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ralph
sudo systemctl start ralph
sudo journalctl -u ralph -f  # View logs
```

### Cron Jobs

Run Ralph on schedule:

```bash
# Edit crontab
crontab -e

# Run daily at 2 AM
0 2 * * * cd /home/ubuntu/my-project && /home/ubuntu/Ralph/ralph.sh >> /var/log/ralph.log 2>&1

# Run every 4 hours
0 */4 * * * cd /home/ubuntu/my-project && /home/ubuntu/Ralph/ralph.sh >> /var/log/ralph.log 2>&1
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Ralph Development
on:
  workflow_dispatch:
    inputs:
      task:
        description: 'Task description'
        required: true

jobs:
  ralph:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Ralph
        run: |
          curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash -s -- --agent gemini

      - name: Create Task
        run: |
          cat > RALPH_TASK.md << 'EOF'
          ---
          task: ${{ github.event.inputs.task }}
          test_command: npm test
          ---

          # Task

          ${{ github.event.inputs.task }}
          EOF

      - name: Run Ralph
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: ./ralph.sh

      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Ralph: ${{ github.event.inputs.task }}"
          branch: ralph-${{ github.run_id }}
```

### GitLab CI

```yaml
ralph:
  image: ubuntu:22.04
  script:
    - apt-get update && apt-get install -y curl git
    - curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash -s -- --agent gemini
    - ./ralph.sh
  artifacts:
    paths:
      - "*.md"
  when: manual
```

### Jenkins Pipeline

```groovy
pipeline {
    agent any

    environment {
        GEMINI_API_KEY = credentials('gemini-api-key')
    }

    stages {
        stage('Install Ralph') {
            steps {
                sh 'curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash -s -- --agent gemini'
            }
        }

        stage('Run Ralph') {
            steps {
                sh './ralph.sh'
            }
        }
    }
}
```

## Docker Deployment

### Dockerfile

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Install Ralph
RUN git clone https://github.com/craigm26/Ralph.git /opt/ralph
WORKDIR /opt/ralph

# Set entrypoint
ENTRYPOINT ["./ralph.sh"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  ralph:
    build: .
    volumes:
      - ./project:/workspace
      - ./RALPH_TASK.md:/workspace/RALPH_TASK.md
    environment:
      - GEMINI_API_KEY=${GEMINI_API_KEY}
    working_dir: /workspace

  ollama:
    image: ollama/ollama
    volumes:
      - ollama_data:/root/.ollama
    ports:
      - "11434:11434"

volumes:
  ollama_data:
```

### Run with Docker

```bash
# Build
docker build -t ralph .

# Run with Gemini
docker run -v $(pwd):/workspace -e GEMINI_API_KEY=your-key ralph

# Run with Ollama (separate container)
docker-compose up -d ollama
docker run --network host -v $(pwd):/workspace ralph --agent ollama
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Google AI API key | For Gemini |
| `ANTHROPIC_API_KEY` | Anthropic API key | For Claude |
| `OPENAI_API_KEY` | OpenAI API key | For OpenAI |
| `OLLAMA_HOST` | Ollama endpoint | Default: localhost:11434 |
| `RALPH_MAX_ITERATIONS` | Max iterations | Default: 20 |
| `RALPH_GIT_AUTOCOMMIT` | Auto-commit changes | Default: true |

## Security Considerations

### API Key Management

```bash
# Use environment variables
export GEMINI_API_KEY="your-key"

# Or use secret managers
# AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id ralph/gemini-key

# HashiCorp Vault
vault kv get -field=api_key secret/ralph/gemini
```

### Network Security

```bash
# If running Ollama, restrict to localhost
# In /etc/systemd/system/ollama.service
Environment="OLLAMA_HOST=127.0.0.1:11434"

# Firewall rules (if needed externally)
sudo ufw allow from 10.0.0.0/8 to any port 11434
```

### File Permissions

```bash
# Secure configuration files
chmod 600 ~/.ralph/config.json
chmod 700 ~/.ralph

# Git credentials
chmod 600 ~/.gitconfig
```

## Monitoring

### Log Aggregation

```bash
# Send logs to file
./ralph.sh 2>&1 | tee -a /var/log/ralph/$(date +%Y%m%d).log

# With timestamps
./ralph.sh 2>&1 | while read line; do echo "$(date '+%Y-%m-%d %H:%M:%S') $line"; done | tee -a ralph.log
```

### Health Checks

```bash
#!/bin/bash
# health-check.sh

# Check Ollama
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "Ollama: OK"
else
    echo "Ollama: FAILED"
    exit 1
fi

# Check Gemini
if gemini --version > /dev/null 2>&1; then
    echo "Gemini CLI: OK"
else
    echo "Gemini CLI: FAILED"
fi
```

## Performance Tuning

### Swap Space

For memory-constrained servers:

```bash
# Create 4GB swap
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Ollama Configuration

```bash
# Limit memory usage
OLLAMA_MAX_LOADED_MODELS=1 ollama serve

# Use smaller context
OLLAMA_NUM_CTX=2048 ollama serve
```

## Troubleshooting

### SSH Connection Drops

```bash
# Keep SSH alive
ssh -o ServerAliveInterval=60 user@server

# Or in ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### Out of Memory

```bash
# Check memory
free -h

# Kill Ollama if needed
pkill ollama

# Use cloud-based agent
./ralph.sh --agent gemini
```

### Disk Space

```bash
# Check space
df -h

# Clean Ollama models
ollama rm codellama:34b

# Clean old logs
find /var/log/ralph -mtime +7 -delete
```

## Cloud-Specific Guides

### AWS EC2

```bash
# Install on Amazon Linux 2
sudo yum update -y
sudo yum install -y git
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash

# IAM role for Secrets Manager (optional)
aws sts get-caller-identity
```

### Google Cloud

```bash
# Install on Compute Engine
sudo apt update
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash

# Use Workload Identity for Gemini (optional)
gcloud auth application-default login
```

### DigitalOcean

```bash
# Install on Droplet
apt update
curl -fsSL https://raw.githubusercontent.com/craigm26/Ralph/main/install.sh | bash

# Configure firewall
ufw allow ssh
ufw enable
```

## Next Steps

1. Read [QUICKSTART.md](QUICKSTART.md) for task examples
2. Check [LOCAL_MODELS.md](LOCAL_MODELS.md) for model comparisons
3. Set up monitoring and alerting
4. Consider GPU instances for large local models
