#Requires -Version 5.1
<#
.SYNOPSIS
    Install MAGI for Windows - Multi-Agent Edition

.DESCRIPTION
    Sets up MAGI with support for multiple AI agents:
    - Cloud: Gemini, OpenAI, Anthropic, Azure, Cursor
    - Local: Ollama, LM Studio, LocalAI
    - Network: Custom endpoints

.PARAMETER TargetPath
    Project directory (default: current directory)

.PARAMETER Force
    Overwrite existing installation

.PARAMETER DefaultAgent
    Set default agent (gemini, openai, ollama, etc.)

.EXAMPLE
    .\install.ps1
    .\install.ps1 -TargetPath "C:\Projects\my-app" -DefaultAgent ollama
#>

[CmdletBinding()]
param(
    [string]$TargetPath = ".",
    [switch]$Force,
    [string]$DefaultAgent = "gemini",
    [switch]$SkipTaskFile
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Banner
# ============================================================================

Write-Host @"

  ╔═══════════════════════════════════════════════════════════════════╗
  ║                                                                   ║
  ║   MAGI FOR WINDOWS - Multi-Agent Edition                          ║
  ║   Autonomous AI Development with Context Management               ║
  ║                                                                   ║
  ║   Cloud:   Gemini │ OpenAI │ Anthropic │ Azure │ Cursor           ║
  ║   Local:   Ollama │ LM Studio │ LocalAI │ vLLM                    ║
  ║   Network: Custom endpoints                                       ║
  ║                                                                   ║
  ╚═══════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan

# ============================================================================
# Resolve Paths
# ============================================================================

$TargetPath = Resolve-Path $TargetPath -ErrorAction SilentlyContinue
if (-not $TargetPath) { $TargetPath = $PWD.Path }

Write-Host "📁 Installing to: $TargetPath" -ForegroundColor White
Write-Host ""

if (-not (Test-Path $TargetPath)) {
    Write-Host "❌ Target path does not exist: $TargetPath" -ForegroundColor Red
    exit 1
}

# Check for git
$gitStatus = git -C $TargetPath status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Warning: Not a git repository" -ForegroundColor Yellow
    Write-Host "   MAGI works best with git. Run 'git init' to initialize.`n" -ForegroundColor Gray
}

# ============================================================================
# Create Directory Structure
# ============================================================================

$scriptsDir = Join-Path $TargetPath ".magi-scripts"
$magiDir = Join-Path $TargetPath ".magi"
$docsDir = Join-Path $TargetPath ".magi-scripts\docs"

# Check existing
if ((Test-Path $scriptsDir) -and -not $Force) {
    Write-Host "⚠️  MAGI is already installed." -ForegroundColor Yellow
    $confirm = Read-Host "   Reinstall? (y/n)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "   Aborted.`n" -ForegroundColor Gray
        exit 0
    }
}

Write-Host "📂 Creating directories..." -ForegroundColor Gray
New-Item -ItemType Directory -Path $scriptsDir -Force | Out-Null
New-Item -ItemType Directory -Path $magiDir -Force | Out-Null
New-Item -ItemType Directory -Path $docsDir -Force | Out-Null

# ============================================================================
# Create Main Script
# ============================================================================

Write-Host "`n📝 Creating scripts..." -ForegroundColor Gray

$magiScriptContent = Get-Content "$PSScriptRoot\scripts\magi.ps1" -Raw -ErrorAction SilentlyContinue

if (-not $magiScriptContent) {
    $magiScriptContent = @'
#Requires -Version 5.1
# MAGI for Windows - Multi-Agent Edition
# Full documentation: README.md

[CmdletBinding()]
param(
    [ValidateSet("gemini", "cursor", "openai", "codex", "ollama", "lmstudio", "local", "network", "vscode", "anthropic")]
    [string]$Agent = "gemini",
    [string]$Model = "",
    [string]$Endpoint = "",
    [int]$MaxIterations = 20,
    [string]$TaskFile = "MAGI_TASK.md",
    [switch]$WatchOnly,
    [switch]$Force,
    [switch]$ListModels
)

Write-Host "`n=== MAGI FOR WINDOWS ===" -ForegroundColor Cyan
Write-Host "Agent: $Agent"
Write-Host "Model: $(if ($Model) { $Model } else { 'default' })"
Write-Host ""
'@
}

Set-Content -Path (Join-Path $scriptsDir "magi.ps1") -Value $magiScriptContent -Encoding UTF8
Write-Host "   ✅ magi.ps1" -ForegroundColor Green

# ============================================================================
# Create Init Script
# ============================================================================

$initScript = @'
#Requires -Version 5.1
param([switch]$Force, [switch]$ResetIteration, [switch]$KeepGuardrails)

$magiDir = ".magi"
Write-Host "`n🔧 MAGI Initialization" -ForegroundColor Cyan

if (-not $Force -and (Test-Path $magiDir)) {
    if ((Read-Host "Reset MAGI state? (y/n)") -ne "y") { exit 0 }
}

$guardrailsBackup = $null
if ($KeepGuardrails -and (Test-Path "$magiDir\guardrails.md")) {
    $guardrailsBackup = Get-Content "$magiDir\guardrails.md" -Raw
}

if (-not (Test-Path $magiDir)) { New-Item -ItemType Directory -Path $magiDir -Force | Out-Null }

$files = @{
    "progress.md" = "# Progress Log`n`n## Completed`n(None)`n`n## Status`nReady.`n"
    "guardrails.md" = "# Guardrails`n`nRead FIRST before work.`n`n## Active`n(None yet)`n"
    "activity.log" = "# Activity Log`n[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] INIT`n"
    "errors.log" = "# Errors`n"
    ".iteration" = "1"
}

foreach ($f in $files.Keys) {
    $path = "$magiDir\$f"
    if ($f -eq "guardrails.md" -and $guardrailsBackup) {
        Set-Content $path $guardrailsBackup -Encoding UTF8
    } else {
        Set-Content $path $files[$f] -Encoding UTF8
    }
}

Write-Host "✅ MAGI initialized`n" -ForegroundColor Green
'@

Set-Content -Path (Join-Path $scriptsDir "init-magi.ps1") -Value $initScript -Encoding UTF8
Write-Host "   ✅ init-magi.ps1" -ForegroundColor Green

# ============================================================================
# Create Batch Wrapper
# ============================================================================

$batchWrapper = @'
@echo off
setlocal enabledelayedexpansion
set "SCRIPT=%~dp0.magi-scripts\magi.ps1"
if not exist "%SCRIPT%" set "SCRIPT=%~dp0magi.ps1"

if /i "%1"=="help" goto :help
if /i "%1"=="-h" goto :help
if /i "%1"=="watch" ( powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -WatchOnly & exit /b )
if /i "%1"=="init" ( powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0.magi-scripts\init-magi.ps1" %2 %3 & exit /b )
if /i "%1"=="models" ( powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -Agent %2 -ListModels & exit /b )

set "AGENT_ARG="
for %%A in (gemini cursor openai codex ollama lmstudio local network vscode anthropic azure) do (
    if /i "%1"=="%%A" ( set "AGENT_ARG=-Agent %1" & shift )
)
if "%AGENT_ARG%"=="" set "AGENT_ARG=-Agent gemini"

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %AGENT_ARG% %1 %2 %3 %4 %5 %6 %7 %8 %9
exit /b

:help
echo.
echo MAGI FOR WINDOWS - Multi-Agent Edition
echo.
echo Usage: magi.bat [agent] [options]
echo.
echo Agents: gemini, cursor, openai, codex, ollama, lmstudio, local, network, vscode
echo.
echo Examples:
echo   magi.bat                     Run with Gemini (default)
echo   magi.bat openai              Run with OpenAI
echo   magi.bat ollama -Model codellama:13b
echo   magi.bat watch               Monitor logs
echo.
exit /b
'@

Set-Content -Path (Join-Path $TargetPath "magi.bat") -Value $batchWrapper -Encoding ASCII
Write-Host "   ✅ magi.bat" -ForegroundColor Green

# ============================================================================
# Create Configuration
# ============================================================================

$configContent = @"
{
    "defaultAgent": "$DefaultAgent",
    "maxIterations": 20,
    "warnThresholdPercent": 70,
    "rotateThresholdPercent": 80,
    
    "agents": {
        "gemini": {
            "type": "cli",
            "defaultModel": "gemini-2.0-flash",
            "contextLimit": 1000000
        },
        "openai": {
            "type": "api",
            "endpoint": "https://api.openai.com/v1/chat/completions",
            "defaultModel": "gpt-4o",
            "apiKeyEnvVar": "OPENAI_API_KEY"
        },
        "ollama": {
            "type": "api",
            "endpoint": "http://localhost:11434/api/chat",
            "defaultModel": "codellama:13b",
            "apiFormat": "ollama"
        },
        "lmstudio": {
            "type": "api",
            "endpoint": "http://localhost:1234/v1/chat/completions",
            "defaultModel": "loaded-model",
            "apiFormat": "openai"
        },
        "local": {
            "type": "api",
            "endpoint": "http://localhost:8080/v1/chat/completions",
            "defaultModel": "default",
            "apiFormat": "openai"
        },
        "network": {
            "type": "api",
            "endpoint": "",
            "defaultModel": "default",
            "apiFormat": "openai"
        }
    }
}
"@

Set-Content -Path (Join-Path $scriptsDir "magi-config.json") -Value $configContent -Encoding UTF8
Write-Host "   ✅ magi-config.json" -ForegroundColor Green

# ============================================================================
# Create Task File Template
# ============================================================================

if (-not $SkipTaskFile) {
    $taskFilePath = Join-Path $TargetPath "MAGI_TASK.md"
    
    if (-not (Test-Path $taskFilePath)) {
        $taskTemplate = @'
---
task: [Your task name]
test_command: npm test
---

# Task: [Your Task Name]

[Brief description]

## Success Criteria

1. [ ] First criterion - specific and testable
2. [ ] Second criterion
3. [ ] All tests pass

## Context

- **Stack**: [e.g., Node.js, TypeScript]
- **Notes**: [constraints, requirements]
'@
        Set-Content -Path $taskFilePath -Value $taskTemplate -Encoding UTF8
        Write-Host "   ✅ MAGI_TASK.md (template)" -ForegroundColor Green
    }
}

# ============================================================================
# Initialize State Files
# ============================================================================

Write-Host "`n📊 Initializing state..." -ForegroundColor Gray

$stateFiles = @{
    "progress.md" = "# Progress Log`n`n## Completed`n(None)`n`n## Status`nReady.`n"
    "guardrails.md" = "# Guardrails`n`nRead FIRST.`n`n## Active`n(None yet)`n"
    "activity.log" = "# Activity Log`n[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] INIT Installed`n"
    "errors.log" = "# Errors`n"
    ".iteration" = "1"
}

foreach ($file in $stateFiles.Keys) {
    $path = Join-Path $magiDir $file
    if (-not (Test-Path $path)) {
        Set-Content -Path $path -Value $stateFiles[$file] -Encoding UTF8
    }
}
Write-Host "   ✅ State files initialized" -ForegroundColor Green

# ============================================================================
# Check Prerequisites
# ============================================================================

Write-Host "`n🔍 Checking agents..." -ForegroundColor Gray

$agents = @(
    @{ Name = "Gemini CLI"; Cmd = "gemini"; Install = "npm install -g @google/gemini-cli" },
    @{ Name = "Cursor CLI"; Cmd = "cursor-agent"; Install = "https://cursor.com/download" },
    @{ Name = "Ollama"; Cmd = "ollama"; Install = "winget install Ollama.Ollama" }
)

foreach ($agent in $agents) {
    if (Get-Command $agent.Cmd -ErrorAction SilentlyContinue) {
        Write-Host "   ✅ $($agent.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "   ⚪ $($agent.Name) - Install: $($agent.Install)" -ForegroundColor Gray
    }
}

# Check API keys
$apiKeys = @(
    @{ Name = "OpenAI"; Var = "OPENAI_API_KEY" },
    @{ Name = "Anthropic"; Var = "ANTHROPIC_API_KEY" }
)

foreach ($key in $apiKeys) {
    if ([Environment]::GetEnvironmentVariable($key.Var)) {
        Write-Host "   ✅ $($key.Name) API key" -ForegroundColor Green
    }
    else {
        Write-Host "   ⚪ $($key.Name) API key not set ($($key.Var))" -ForegroundColor Gray
    }
}

# ============================================================================
# Done
# ============================================================================

Write-Host @"

╔═══════════════════════════════════════════════════════════════════╗
║  ✅ MAGI INSTALLED SUCCESSFULLY                                   ║
╚═══════════════════════════════════════════════════════════════════╝

Quick Start:

  1. Edit MAGI_TASK.md with your task

  2. Run MAGI:
     magi-ai run "test"          # Run locally
     .\magi.bat                  # Gemini (legacy script)
     .\magi.bat openai           # OpenAI GPT-4o
     .\magi.bat ollama           # Local Ollama
     .\magi.bat ollama -Model deepseek-coder:33b

  3. Monitor: .\magi.bat watch

Agent Setup:
  - Gemini:  npm install -g @google/gemini-cli && gemini auth login
  - OpenAI:  `$env:OPENAI_API_KEY = "sk-..."
  - Ollama:  winget install Ollama.Ollama && ollama pull codellama:13b

Docs: README.md | .magi-scripts\docs\LOCAL_MODELS.md

"@ -ForegroundColor Cyan
