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

The easiest way to run local models.

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

### Using with MAGI

```powershell
# Make sure Ollama is running
ollama serve

# Run MAGI with Ollama
magi run "local-dev" --agent ollama

# Specify model
magi run "local-dev" --agent ollama --model deepseek-coder:33b
```

## Option 2: LM Studio

GUI application for running local models - great for beginners.

### Installation

1. Download from https://lmstudio.ai
2. Install and launch
3. Go to "Discover" tab and download models

### Setup for MAGI

1. Load a model in LM Studio
2. Go to "Local Server" tab
3. Click "Start Server" (default: localhost:1234)
4. Run MAGI:

```powershell
magi run "local-task" --agent lmstudio
```

## Network Setup

Run models on a more powerful machine and access from your dev machine.

### Server Machine (with GPU)

```powershell
# Using Ollama
ollama serve --host 0.0.0.0
```

### Client Machine (your dev machine)

```powershell
# Use with MAGI
magi run "remote-task" --agent network --endpoint http://192.168.1.100:11434/api/chat --model codellama:13b
```

### Network Config Example

Edit `magi-config.json`:

```json
{
    "agents": [
        {
            "name": "gpu-server",
            "type": "ollama",
            "endpoint": "http://192.168.1.100:11434/api/chat",
            "model": "deepseek-coder:33b"
        }
    ]
}
```

## Troubleshooting

### "CUDA out of memory"

- Use smaller model (7B)
- Close other GPU apps
- Check GPU usage: `nvidia-smi`

### "Model too slow"

- Use GPU acceleration
- Use quantized models (Q4_K_M)
- Reduce context length in `magi-config.json`

## Hybrid Approach

Use local models for iteration, cloud for complex tasks:

```powershell
# Quick iterations with local model
magi run "fix-css" --agent ollama

# Stuck? Switch to cloud for help
magi run "fix-css" --agent openai --model gpt-4o
```
