# Local Models Setup Guide

Run AI agents entirely on your own hardware - no cloud, no API costs, complete privacy.

## Why Local Models?

- **Privacy**: Code never leaves your machine
- **Offline**: Work without internet
- **Cost**: No API fees after hardware investment
- **Speed**: No network latency (if you have good GPU)
- **Control**: Choose exactly which model to run

## Hardware Requirements

### Minimum (7B models)
- **GPU**: 8GB VRAM (RTX 3070, RTX 4060)
- **RAM**: 16GB
- **Storage**: 50GB free

### Recommended (13-14B models)
- **GPU**: 16GB VRAM (RTX 4080, RTX 3090)
- **RAM**: 32GB
- **Storage**: 100GB free

### Optimal (33-34B models)
- **GPU**: 24-48GB VRAM (RTX 4090, A100)
- **RAM**: 64GB
- **Storage**: 200GB free

### CPU-Only (Slower)
- Works but much slower
- Need lots of RAM (model size × 1.5)
- Acceptable for small models (7B)

## Option 1: Ollama (Recommended)

The easiest way to run local models on Windows.

### Installation

```powershell
# Using winget
winget install Ollama.Ollama

# Or download from https://ollama.ai
```

### Setup

```powershell
# Start the Ollama service
ollama serve

# In another terminal, pull models
ollama pull codellama:13b
ollama pull deepseek-coder:6.7b
```

### Best Models for Coding

| Model | Pull Command | VRAM | Notes |
|-------|--------------|------|-------|
| CodeLlama 7B | `ollama pull codellama:7b` | 8GB | Good starter |
| CodeLlama 13B | `ollama pull codellama:13b` | 16GB | Better quality |
| CodeLlama 34B | `ollama pull codellama:34b` | 40GB | Best CodeLlama |
| DeepSeek Coder 6.7B | `ollama pull deepseek-coder:6.7b` | 8GB | Excellent for size |
| DeepSeek Coder 33B | `ollama pull deepseek-coder:33b` | 40GB | Top tier |
| Qwen2.5 Coder 7B | `ollama pull qwen2.5-coder:7b` | 8GB | Very good |
| Qwen2.5 Coder 14B | `ollama pull qwen2.5-coder:14b` | 16GB | Excellent |
| StarCoder2 7B | `ollama pull starcoder2:7b` | 8GB | Code-focused |

### Using with Ralph

```powershell
# Make sure Ollama is running
ollama serve

# Run Ralph with Ollama
.\ralph.bat ollama

# Specify model
.\ralph.bat ollama -Model deepseek-coder:33b

# List available models
.\ralph.bat models ollama
```

### Ollama Tips

```powershell
# See what models you have
ollama list

# Remove a model
ollama rm codellama:7b

# See model info
ollama show codellama:13b

# Run model interactively (test it)
ollama run codellama:13b
```

## Option 2: LM Studio

GUI application for running local models - great for beginners.

### Installation

1. Download from https://lmstudio.ai
2. Install and launch
3. Go to "Discover" tab and download models

### Recommended Models

Search for and download:
- `deepseek-coder-33b-instruct`
- `codellama-34b-instruct`
- `qwen2.5-coder-14b-instruct`

Look for GGUF format with quantization matching your VRAM:
- Q4_K_M: ~60% of full size, good quality
- Q5_K_M: ~70% of full size, better quality
- Q8_0: ~100% of full size, best quality

### Setup for Ralph

1. Load a model in LM Studio
2. Go to "Local Server" tab
3. Click "Start Server" (default: localhost:1234)
4. Run Ralph:

```powershell
.\ralph.bat lmstudio
```

### LM Studio Tips

- Use "GPU Offload" slider to control VRAM usage
- "Context Length" affects memory - start with 4096
- Enable "Continuous Batching" for better throughput

## Option 3: LocalAI

Self-hosted, production-ready, OpenAI-compatible API.

### Installation

```powershell
# Using Docker (recommended)
docker run -p 8080:8080 --gpus all localai/localai:latest-gpu-nvidia-cuda-12

# Or download binary from https://localai.io
```

### Setup

```powershell
# Download a model
curl -O https://huggingface.co/TheBloke/CodeLlama-13B-Instruct-GGUF/resolve/main/codellama-13b-instruct.Q4_K_M.gguf

# Place in models directory
mkdir models
move codellama-13b-instruct.Q4_K_M.gguf models/

# Create model config
echo '{"name": "codellama", "backend": "llama"}' > models/codellama.yaml
```

### Using with Ralph

```powershell
.\ralph.bat local -Endpoint http://localhost:8080/v1/chat/completions
```

## Option 4: Text Generation WebUI (oobabooga)

Feature-rich UI with many backends.

### Installation

```powershell
# Clone repo
git clone https://github.com/oobabooga/text-generation-webui
cd text-generation-webui

# Run installer
start_windows.bat
```

### Setup

1. Download models from HuggingFace tab
2. Load model in Model tab
3. Enable API in Session tab (port 5000)

### Using with Ralph

```powershell
.\ralph.bat local -Endpoint http://localhost:5000/v1/chat/completions
```

## Option 5: vLLM (Advanced)

High-performance inference server - best for serious local deployments.

### Installation

```powershell
# Requires WSL2 or Linux
pip install vllm
```

### Setup

```powershell
# Start server
python -m vllm.entrypoints.openai.api_server \
    --model deepseek-ai/deepseek-coder-33b-instruct \
    --port 8000
```

### Using with Ralph

```powershell
.\ralph.bat local -Endpoint http://localhost:8000/v1/chat/completions
```

## Network Setup

Run models on a more powerful machine and access from your dev machine.

### Server Machine (with GPU)

```powershell
# Using Ollama
ollama serve --host 0.0.0.0

# Using LM Studio
# Start server and check "Allow remote connections"

# Using LocalAI
docker run -p 8080:8080 --gpus all localai/localai:latest-gpu-nvidia-cuda-12
```

### Client Machine (your dev machine)

```powershell
# Find server IP
# On server: ipconfig | findstr IPv4

# Use with Ralph
.\ralph.bat network -Endpoint http://192.168.1.100:11434/api/chat -Model codellama:13b

# Or configure in ralph-config.json
```

### Network Config Example

Edit `.ralph-scripts/ralph-config.json`:

```json
{
    "agents": {
        "network": {
            "endpoint": "http://192.168.1.100:11434/api/chat",
            "defaultModel": "deepseek-coder:33b",
            "apiFormat": "ollama"
        }
    }
}
```

## Model Recommendations by Task

### General Coding (TypeScript, Python, etc.)
1. **Best**: DeepSeek Coder 33B
2. **Good**: Qwen2.5 Coder 14B
3. **Budget**: CodeLlama 13B

### Systems Programming (Rust, C++)
1. **Best**: DeepSeek Coder 33B
2. **Good**: CodeLlama 34B
3. **Budget**: CodeLlama 13B

### Web Development
1. **Best**: Qwen2.5 Coder 14B
2. **Good**: DeepSeek Coder 6.7B
3. **Budget**: CodeLlama 7B

### Data Science / ML
1. **Best**: DeepSeek Coder 33B
2. **Good**: CodeLlama 34B (Python)
3. **Budget**: Qwen2.5 Coder 7B

## Troubleshooting

### "CUDA out of memory"

```powershell
# Use smaller model
ollama pull codellama:7b

# Or use quantized version
ollama pull codellama:13b-q4_0

# Close other GPU apps
# Check GPU usage: nvidia-smi
```

### "Model too slow"

- Use GPU acceleration (check it's enabled)
- Use smaller/quantized model
- Reduce context length
- Close background apps

### "Connection refused"

```powershell
# Check server is running
curl http://localhost:11434/api/tags

# Check firewall
netsh advfirewall firewall add rule name="Ollama" dir=in action=allow protocol=TCP localport=11434
```

### "Poor code quality"

- Try a larger model if hardware allows
- Use instruction-tuned variants (look for "instruct" in name)
- Add more context in guardrails
- Use cloud fallback for complex tasks

## Performance Benchmarks

Approximate tokens/second on RTX 4090:

| Model | Size | Tokens/sec |
|-------|------|------------|
| CodeLlama 7B | Q4 | 80-100 |
| CodeLlama 13B | Q4 | 50-70 |
| CodeLlama 34B | Q4 | 20-30 |
| DeepSeek 6.7B | Q4 | 70-90 |
| DeepSeek 33B | Q4 | 15-25 |

## Hybrid Approach

Use local models for iteration, cloud for complex tasks:

```powershell
# Quick iterations with local model
.\ralph.bat ollama -Model codellama:13b

# Stuck? Switch to cloud for help
.\ralph.bat openai -Model gpt-4o
```

Or configure automatic fallback in `ralph-config.json`:

```json
{
    "fallbackAgent": "openai",
    "fallbackOnError": true
}
```
