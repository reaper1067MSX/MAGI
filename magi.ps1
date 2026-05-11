#Requires -Version 5.1
<#
.SYNOPSIS
    MAGI for Windows - Autonomous AI development with deliberate context management

.DESCRIPTION
    Implements Geoffrey Huntley's MAGI Wiggum technique for multiple AI agents:
    - Gemini CLI (Google)
    - Cursor CLI
    - OpenAI API (GPT-4, Codex)
    - Local models (Ollama, LM Studio, LocalAI)
    - Networked models (OpenAI-compatible APIs)
    - VS Code (manual mode)

.PARAMETER Agent
    The AI agent to use: gemini, cursor, openai, codex, ollama, lmstudio, local, network, vscode

.PARAMETER Model
    Specific model to use (optional, uses agent default)

.PARAMETER Endpoint
    API endpoint for local/network models (e.g., http://localhost:11434)

.PARAMETER MaxIterations
    Maximum number of iterations before stopping

.PARAMETER TaskFile
    Path to the task definition file (default: MAGI_TASK.md)

.PARAMETER ConfigFile
    Path to configuration file (default: .magi-scripts/magi-config.json)

.PARAMETER WatchOnly
    Monitor logs without running the loop

.PARAMETER Force
    Skip confirmation prompts

.PARAMETER Verbose
    Enable verbose output

.EXAMPLE
    .\magi.ps1
    .\magi.ps1 -Agent openai -Model "gpt-4o"
    .\magi.ps1 -Agent ollama -Model "codellama:34b"
    .\magi.ps1 -Agent local -Endpoint "http://192.168.1.100:8080" -Model "deepseek-coder"
#>

[CmdletBinding()]
param(
    [ValidateSet("gemini", "cursor", "openai", "codex", "ollama", "lmstudio", "local", "network", "vscode")]
    [string]$Agent = "",
    
    [string]$Model = "",
    
    [string]$Endpoint = "",
    
    [int]$MaxIterations = 0,
    
    [string]$TaskFile = "MAGI_TASK.md",
    
    [string]$ConfigFile = ".magi-scripts\magi-config.json",
    
    [switch]$WatchOnly,
    
    [switch]$Force,
    
    [switch]$ListModels
)

# ============================================================================
# Configuration
# ============================================================================

$script:DefaultConfig = @{
    maxIterations = 20
    warnThresholdPercent = 70
    rotateThresholdPercent = 80
    defaultAgent = "gemini"
    
    agents = @{
        gemini = @{
            type = "cli"
            command = "gemini"
            defaultModel = "gemini-2.0-flash"
            contextLimit = 1000000
            args = @("-p", "--yolo")
        }
        cursor = @{
            type = "cli"
            command = "cursor-agent"
            defaultModel = "claude-sonnet-4-20250514"
            contextLimit = 100000
            args = @("-p", "--force", "--output-format", "stream-json")
        }
        openai = @{
            type = "api"
            endpoint = "https://api.openai.com/v1/chat/completions"
            defaultModel = "gpt-4o"
            contextLimit = 128000
            apiKeyEnvVar = "OPENAI_API_KEY"
        }
        codex = @{
            type = "api"
            endpoint = "https://api.openai.com/v1/chat/completions"
            defaultModel = "gpt-4o"
            contextLimit = 128000
            apiKeyEnvVar = "OPENAI_API_KEY"
        }
        ollama = @{
            type = "api"
            endpoint = "http://localhost:11434/api/chat"
            defaultModel = "codellama:13b"
            contextLimit = 32000
            apiFormat = "ollama"
        }
        lmstudio = @{
            type = "api"
            endpoint = "http://localhost:1234/v1/chat/completions"
            defaultModel = "local-model"
            contextLimit = 32000
            apiFormat = "openai"
        }
        local = @{
            type = "api"
            endpoint = "http://localhost:8080/v1/chat/completions"
            defaultModel = "default"
            contextLimit = 32000
            apiFormat = "openai"
        }
        network = @{
            type = "api"
            endpoint = ""
            defaultModel = "default"
            contextLimit = 32000
            apiFormat = "openai"
        }
        vscode = @{
            type = "manual"
            defaultModel = "gemini-code-assist"
            contextLimit = 100000
        }
    }
    
    paths = @{
        taskFile = "MAGI_TASK.md"
        magiDir = ".magi"
        scriptsDir = ".magi-scripts"
    }
    
    git = @{
        autoCommit = $true
        commitPrefix = "magi:"
        autoPush = $false
    }
}

$script:Config = $null

function Load-Configuration {
    param([string]$ConfigPath)
    
    $script:Config = $script:DefaultConfig.Clone()
    
    if (Test-Path $ConfigPath) {
        try {
            $fileConfig = Get-Content $ConfigPath -Raw | ConvertFrom-Json -AsHashtable
            
            foreach ($key in $fileConfig.Keys) {
                if ($fileConfig[$key] -is [hashtable] -and $script:Config[$key] -is [hashtable]) {
                    foreach ($subKey in $fileConfig[$key].Keys) {
                        $script:Config[$key][$subKey] = $fileConfig[$key][$subKey]
                    }
                }
                else {
                    $script:Config[$key] = $fileConfig[$key]
                }
            }
            
            Write-Verbose "Loaded configuration from $ConfigPath"
        }
        catch {
            Write-Warning "Failed to load config file: $_"
        }
    }
    
    if ($Agent) { $script:Config.defaultAgent = $Agent }
    if ($MaxIterations -gt 0) { $script:Config.maxIterations = $MaxIterations }
}

# ============================================================================
# Initialization
# ============================================================================

function Initialize-MAGI {
    $magiDir = $script:Config.paths.magiDir
    
    if (-not (Test-Path $magiDir)) {
        New-Item -ItemType Directory -Path $magiDir -Force | Out-Null
    }
    
    $files = @{
        "progress.md" = @"
# Progress Log

## Completed Criteria
(None yet)

## Current Status
Starting fresh iteration.

## Notes
- Initialized: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
        "guardrails.md" = @"
# Guardrails (Signs)

These are lessons learned from previous iterations. Read these FIRST before starting work.

## Active Guardrails

(None yet - guardrails will be added as we learn from failures)

---

## How to Add a Guardrail

When something fails, add a sign:

### Sign: [Short description]
- **Trigger**: [When this applies]
- **Instruction**: [What to do instead]
- **Added after**: [Iteration N - what happened]
"@
        "activity.log" = "# Activity Log`n[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] INIT Started`n"
        "errors.log" = "# Error Log`n"
        ".iteration" = "1"
    }
    
    foreach ($file in $files.Keys) {
        $path = Join-Path $magiDir $file
        if (-not (Test-Path $path)) {
            Set-Content -Path $path -Value $files[$file] -Encoding UTF8
        }
    }
    
    if (-not (Test-Path $TaskFile)) {
        Write-Host "`n❌ Task file not found: $TaskFile" -ForegroundColor Red
        Write-Host "Create a MAGI_TASK.md file with your task definition.`n" -ForegroundColor Yellow
        
        $template = @"
---
task: [Your task name]
test_command: [Command to run tests, e.g., npm test]
---

# Task: [Your Task Name]

[Brief description of what you're building]

## Success Criteria

1. [ ] First criterion
2. [ ] Second criterion
3. [ ] Third criterion
4. [ ] All tests pass

## Context

- [Technology stack]
- [Important constraints]
"@
        Set-Content -Path $TaskFile -Value $template -Encoding UTF8
        Write-Host "Created template at $TaskFile - please edit and run again.`n" -ForegroundColor Cyan
        exit 1
    }
}

# ============================================================================
# Agent Detection & Validation
# ============================================================================

function Test-AgentAvailable {
    param([string]$AgentName)
    
    $agentConfig = $script:Config.agents[$AgentName]
    if (-not $agentConfig) {
        Write-Host "❌ Unknown agent: $AgentName" -ForegroundColor Red
        return $false
    }
    
    switch ($agentConfig.type) {
        "cli" {
            $cmd = Get-Command $agentConfig.command -ErrorAction SilentlyContinue
            if (-not $cmd) {
                $found = $false
                switch ($AgentName) {
                    "gemini" {
                        Write-Host "❌ Gemini CLI not found" -ForegroundColor Red
                        Write-Host "   Install: npm install -g @google/gemini-cli" -ForegroundColor Yellow
                    }
                    "cursor" {
                        $paths = @(
                            "$env:LOCALAPPDATA\Programs\cursor\resources\app\bin\cursor-agent.exe"
                        )
                        foreach ($p in $paths) {
                            if (Test-Path $p) {
                                $env:PATH += ";$(Split-Path $p)"
                                $found = $true
                                break
                            }
                        }
                        if (-not $found) {
                            Write-Host "❌ Cursor CLI not found" -ForegroundColor Red
                            Write-Host "   Install from: https://cursor.com/download" -ForegroundColor Yellow
                        }
                    }
                }
                return $found
            }
            return $true
        }
        
        "api" {
            if ($agentConfig.apiKeyEnvVar) {
                $apiKey = [Environment]::GetEnvironmentVariable($agentConfig.apiKeyEnvVar)
                if (-not $apiKey) {
                    Write-Host "❌ API key not found" -ForegroundColor Red
                    Write-Host "   Set environment variable: $($agentConfig.apiKeyEnvVar)" -ForegroundColor Yellow
                    return $false
                }
            }
            
            if ($AgentName -eq "network" -and -not $Endpoint -and -not $agentConfig.endpoint) {
                Write-Host "❌ Endpoint required for network agent" -ForegroundColor Red
                Write-Host "   Use: -Endpoint 'http://your-server:port/v1/chat/completions'" -ForegroundColor Yellow
                return $false
            }
            
            return $true
        }
        
        "manual" {
            return $true
        }
    }
    
    return $false
}

function Get-AvailableModels {
    param([string]$AgentName)
    
    $agentConfig = $script:Config.agents[$AgentName]
    
    switch ($AgentName) {
        "ollama" {
            try {
                $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get
                return $response.models | ForEach-Object { $_.name }
            }
            catch {
                return @("codellama:13b", "codellama:34b", "deepseek-coder:33b", "llama3:8b")
            }
        }
        "lmstudio" {
            try {
                $endpoint = if ($Endpoint) { $Endpoint } else { $agentConfig.endpoint }
                $modelsUrl = $endpoint -replace '/chat/completions', '/models'
                $response = Invoke-RestMethod -Uri $modelsUrl -Method Get
                return $response.data | ForEach-Object { $_.id }
            }
            catch {
                return @("Check LM Studio for loaded model")
            }
        }
        "openai" {
            return @("gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo", "o1", "o1-mini")
        }
        "gemini" {
            return @("gemini-2.0-flash")
        }
        default {
            return @($agentConfig.defaultModel)
        }
    }
}

# ============================================================================
# Task Parsing
# ============================================================================

function Get-TaskInfo {
    param([string]$TaskFilePath)
    
    $content = Get-Content $TaskFilePath -Raw
    
    $taskName = ""
    $testCommand = ""
    
    if ($content -match '(?s)^---\s*\n(.*?)\n---') {
        $frontmatter = $Matches[1]
        if ($frontmatter -match 'task:\s*(.+)') {
            $taskName = $Matches[1].Trim()
        }
        if ($frontmatter -match 'test_command:\s*"?([^"\n]+)"?') {
            $testCommand = $Matches[1].Trim()
        }
    }
    
    $unchecked = ([regex]::Matches($content, '\[ \]')).Count
    $checked = ([regex]::Matches($content, '\[x\]|\[X\]')).Count
    $total = $unchecked + $checked
    
    return @{
        Name = $taskName
        TestCommand = $testCommand
        TotalCriteria = $total
        CompletedCriteria = $checked
        RemainingCriteria = $unchecked
        Content = $content
    }
}

# ============================================================================
# Prompt Building
# ============================================================================

function Build-AgentPrompt {
    param(
        [hashtable]$TaskInfo,
        [int]$Iteration,
        [string]$AgentName
    )
    
    $magiDir = $script:Config.paths.magiDir
    
    $guardrails = ""
    $progress = ""
    $errors = ""
    
    if (Test-Path "$magiDir\guardrails.md") {
        $guardrails = Get-Content "$magiDir\guardrails.md" -Raw
    }
    if (Test-Path "$magiDir\progress.md") {
        $progress = Get-Content "$magiDir\progress.md" -Raw
    }
    if (Test-Path "$magiDir\errors.log") {
        $recentErrors = Get-Content "$magiDir\errors.log" -Tail 30 -ErrorAction SilentlyContinue
        if ($recentErrors) {
            $errors = $recentErrors -join "`n"
        }
    }
    
    $fileList = Get-ChildItem -Path . -Recurse -File -Depth 3 | 
        Where-Object { $_.FullName -notmatch '(node_modules|\.git|\.magi|__pycache__|\.venv|dist|build)' } |
        Select-Object -First 50 |
        ForEach-Object { $_.FullName.Replace($PWD.Path + "\", "") }
    $fileListStr = $fileList -join "`n"
    
    $prompt = @"
# MAGI AUTONOMOUS AGENT - ITERATION $Iteration

You are an autonomous coding agent working on a task. Your context is fresh each iteration.
Progress persists in FILES and GIT, not in conversation history.

## CRITICAL INSTRUCTIONS

1. **READ GUARDRAILS FIRST** - These are lessons from previous failures. Follow them.
2. **CHECK PROGRESS** - See what's already been done. Don't redo completed work.
3. **WORK ON UNCHECKED CRITERIA** - Focus on [ ] items, not [x] items.
4. **COMMIT FREQUENTLY** - Use git to save progress after each criterion.
5. **UPDATE STATE FILES** - Write to .magi/progress.md after completing work.
6. **ADD GUARDRAILS** - If something fails repeatedly, add a Sign to .magi/guardrails.md

## GUARDRAILS (READ FIRST!)

$guardrails

## CURRENT PROGRESS

$progress

## RECENT ERRORS (if any)

$errors

## PROJECT FILES

$fileListStr

## TASK DEFINITION

$($TaskInfo.Content)

## YOUR MISSION THIS ITERATION

1. Read and follow all guardrails above
2. Check what criteria are already completed [x]
3. Work on the next unchecked criterion [ ]
4. Run tests after changes: $($TaskInfo.TestCommand)
5. Commit with: git add -A && git commit -m "magi: [description]"
6. Update .magi/progress.md with completed work
7. If something fails repeatedly, add a guardrail

## AVAILABLE TOOLS

You can:
- Read and write files
- Execute shell commands (PowerShell on Windows)
- Run tests and builds
- Use git for version control

## STATE FILE FORMATS

When updating .magi/progress.md:
```markdown
## Completed Criteria
- [x] Criterion 1 - completed in iteration N
- [x] Criterion 2 - completed in iteration N

## Current Status
Working on: [current criterion]

## Notes
[Any relevant notes]
```

When adding a guardrail to .magi/guardrails.md:
```markdown
### Sign: [Short description]
- **Trigger**: [When this applies]
- **Instruction**: [What to do instead]
- **Added after**: Iteration $Iteration - [what happened]
```

---

BEGIN WORK. Focus on unchecked criteria. Commit progress. Update state files.
"@
    
    return $prompt
}

# ============================================================================
# API Clients
# ============================================================================

function Invoke-OpenAICompatibleAPI {
    param(
        [string]$Endpoint,
        [string]$Prompt,
        [string]$ModelName,
        [string]$ApiKey = "",
        [int]$MaxTokens = 4096,
        [double]$Temperature = 0.7
    )
    
    $headers = @{ "Content-Type" = "application/json" }
    if ($ApiKey) { $headers["Authorization"] = "Bearer $ApiKey" }
    
    $body = @{
        model = $ModelName
        messages = @(
            @{ role = "system"; content = "You are an expert coding assistant. Execute tasks precisely and update progress files." },
            @{ role = "user"; content = $Prompt }
        )
        max_tokens = $MaxTokens
        temperature = $Temperature
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Headers $headers -Body $body -TimeoutSec 300
        return @{ Success = $true; Content = $response.choices[0].message.content }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Invoke-OllamaAPI {
    param(
        [string]$Endpoint,
        [string]$Prompt,
        [string]$ModelName
    )
    
    $body = @{
        model = $ModelName
        messages = @(
            @{ role = "system"; content = "You are an expert coding assistant. Execute tasks precisely." },
            @{ role = "user"; content = $Prompt }
        )
        stream = $false
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Body $body -ContentType "application/json" -TimeoutSec 600
        return @{ Success = $true; Content = $response.message.content }
    }
    catch {
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# ============================================================================
# Agent Execution
# ============================================================================

function Invoke-Agent {
    param(
        [string]$AgentName,
        [string]$Prompt,
        [string]$ModelName,
        [int]$Iteration
    )
    
    $magiDir = $script:Config.paths.magiDir
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $agentConfig = $script:Config.agents[$AgentName]
    
    Add-Content "$magiDir\activity.log" "[$timestamp] === ITERATION $Iteration - $AgentName ===" -Encoding UTF8
    
    switch ($agentConfig.type) {
        "cli" { return Invoke-CLIAgent -AgentName $AgentName -Prompt $Prompt -ModelName $ModelName -Iteration $Iteration }
        "api" { return Invoke-APIAgent -AgentName $AgentName -Prompt $Prompt -ModelName $ModelName -Iteration $Iteration }
        "manual" { return Invoke-ManualAgent -Prompt $Prompt -Iteration $Iteration }
    }
}

function Invoke-CLIAgent {
    param(
        [string]$AgentName,
        [string]$Prompt,
        [string]$ModelName,
        [int]$Iteration
    )
    
    $magiDir = $script:Config.paths.magiDir
    $agentConfig = $script:Config.agents[$AgentName]
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    Write-Host "`n🚀 Starting $AgentName CLI (Iteration $Iteration)..." -ForegroundColor Cyan
    
    switch ($AgentName) {
        "gemini" {
            $args = @("-p", $Prompt, "--yolo")
            if ($ModelName) { $args += @("--model", $ModelName) }
            
            try {
                $output = & gemini @args 2>&1
                Add-Content "$magiDir\activity.log" "[$timestamp] Gemini completed" -Encoding UTF8
                return @{ Success = $true; Output = $output }
            }
            catch {
                Add-Content "$magiDir\errors.log" "[$timestamp] Gemini error: $_" -Encoding UTF8
                return @{ Success = $false; Output = $_.Exception.Message }
            }
        }
        
        "cursor" {
            $promptFile = [System.IO.Path]::GetTempFileName()
            Set-Content -Path $promptFile -Value $Prompt -Encoding UTF8
            
            try {
                $args = @("-p", "--force")
                if ($ModelName) { $args += @("--model", $ModelName) }
                
                $output = Get-Content $promptFile | & cursor-agent @args 2>&1
                Remove-Item $promptFile -Force -ErrorAction SilentlyContinue
                
                Add-Content "$magiDir\activity.log" "[$timestamp] Cursor completed" -Encoding UTF8
                return @{ Success = $true; Output = $output }
            }
            catch {
                Remove-Item $promptFile -Force -ErrorAction SilentlyContinue
                Add-Content "$magiDir\errors.log" "[$timestamp] Cursor error: $_" -Encoding UTF8
                return @{ Success = $false; Output = $_.Exception.Message }
            }
        }
    }
}

function Invoke-APIAgent {
    param(
        [string]$AgentName,
        [string]$Prompt,
        [string]$ModelName,
        [int]$Iteration
    )
    
    $magiDir = $script:Config.paths.magiDir
    $agentConfig = $script:Config.agents[$AgentName]
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $apiEndpoint = if ($Endpoint) { $Endpoint } else { $agentConfig.endpoint }
    $apiModel = if ($ModelName) { $ModelName } else { $agentConfig.defaultModel }
    
    Write-Host "`n🚀 Starting $AgentName API (Iteration $Iteration)..." -ForegroundColor Cyan
    Write-Host "   Endpoint: $apiEndpoint" -ForegroundColor Gray
    Write-Host "   Model: $apiModel" -ForegroundColor Gray
    
    $apiKey = ""
    if ($agentConfig.apiKeyEnvVar) { $apiKey = [Environment]::GetEnvironmentVariable($agentConfig.apiKeyEnvVar) }
    
    $result = switch ($agentConfig.apiFormat) {
        "ollama" { Invoke-OllamaAPI -Endpoint $apiEndpoint -Prompt $Prompt -ModelName $apiModel }
        default { Invoke-OpenAICompatibleAPI -Endpoint $apiEndpoint -Prompt $Prompt -ModelName $apiModel -ApiKey $apiKey }
    }
    
    if ($result.Success) {
        Add-Content "$magiDir\activity.log" "[$timestamp] $AgentName API completed" -Encoding UTF8
        $response = $result.Content
        Write-Host "`n📝 Agent Response:" -ForegroundColor Cyan
        Write-Host $response.Substring(0, [Math]::Min(500, $response.Length)) -ForegroundColor Gray
        if ($response.Length -gt 500) { Write-Host "..." -ForegroundColor Gray }
        
        $responsePath = "$magiDir\last_response.md"
        Set-Content -Path $responsePath -Value $response -Encoding UTF8
        return @{ Success = $true; Output = $response }
    }
    else {
        Add-Content "$magiDir\errors.log" "[$timestamp] $AgentName API error: $($result.Error)" -Encoding UTF8
        return @{ Success = $false; Output = $result.Error }
    }
}

function Invoke-ManualAgent {
    param(
        [string]$Prompt,
        [int]$Iteration
    )
    
    $magiDir = $script:Config.paths.magiDir
    Write-Host "`n📋 Manual Mode - VS Code / IDE" -ForegroundColor Yellow
    Write-Host "=" * 60
    
    $promptPath = "$magiDir\current_prompt.md"
    Set-Content -Path $promptPath -Value $Prompt -Encoding UTF8
    
    Write-Host "`nPrompt saved to: $promptPath" -ForegroundColor Cyan
    Write-Host "`nInstructions:" -ForegroundColor White
    Write-Host "1. Open VS Code + Gemini Code Assist"
    Write-Host "2. Copy and paste the prompt from: $promptPath"
    Write-Host "3. Press Enter here when done"
    Read-Host "Press Enter when agent work is complete"
    
    return @{ Success = $true; Output = "Manual execution completed" }
}

# ============================================================================
# Progress Checking
# ============================================================================

function Test-TaskComplete {
    param([string]$TaskFilePath)
    $taskInfo = Get-TaskInfo -TaskFilePath $TaskFilePath
    return $taskInfo.RemainingCriteria -eq 0
}

function Test-GutterCondition {
    param([string]$magiDir)
    $errorLog = Join-Path $magiDir "errors.log"
    if (-not (Test-Path $errorLog)) { return $false }
    $recentErrors = Get-Content $errorLog -Tail 20 -ErrorAction SilentlyContinue
    if (-not $recentErrors) { return $false }
    
    $errorCount = ($recentErrors | Select-String -Pattern "error|failed|exception").Count
    return $errorCount -ge 3
}

# ============================================================================
# Main Loop
# ============================================================================

function Start-MAGILoop {
    param(
        [string]$AgentName,
        [string]$ModelName,
        [int]$MaxIter,
        [string]$TaskFilePath
    )
    
    $magiDir = $script:Config.paths.magiDir
    $iterationFile = Join-Path $magiDir ".iteration"
    $iteration = 1
    if (Test-Path $iterationFile) { $iteration = [int](Get-Content $iterationFile) }
    
    $taskInfo = Get-TaskInfo -TaskFilePath $TaskFilePath
    $agentConfig = $script:Config.agents[$AgentName]
    
    Write-Host "`n" + "=" * 70 -ForegroundColor Cyan
    Write-Host "  MAGI FOR WINDOWS - Multi-Agent Edition" -ForegroundColor White
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Agent:       $AgentName ($($agentConfig.type))" -ForegroundColor Gray
    Write-Host "  Model:       $(if ($ModelName) { $ModelName } else { $agentConfig.defaultModel })" -ForegroundColor Gray
    Write-Host "  Task:        $($taskInfo.Name)" -ForegroundColor Gray
    Write-Host "  Progress:    $($taskInfo.CompletedCriteria)/$($taskInfo.TotalCriteria) criteria" -ForegroundColor Gray
    Write-Host "  Iteration:   $iteration (max: $MaxIter)" -ForegroundColor Gray
    
    if ($agentConfig.type -eq "api") {
        $ep = if ($Endpoint) { $Endpoint } else { $agentConfig.endpoint }
        Write-Host "  Endpoint:    $ep" -ForegroundColor Gray
    }
    
    Write-Host "`n" + "-" * 70 -ForegroundColor DarkGray
    
    if (-not $Force) {
        $confirm = Read-Host "`nStart MAGI loop? (y/n)"
        if ($confirm -ne "y" -and $confirm -ne "Y") { return }
    }
    
    while ($iteration -le $MaxIter) {
        Write-Host "`n" + "=" * 70 -ForegroundColor Blue
        Write-Host "  ITERATION $iteration / $MaxIter" -ForegroundColor White
        Write-Host "=" * 70 -ForegroundColor Blue
        
        if (Test-TaskComplete -TaskFilePath $TaskFilePath) {
            Write-Host "`n✅ ALL CRITERIA COMPLETE!" -ForegroundColor Green
            break
        }
        
        if (Test-GutterCondition -magiDir $magiDir) {
            Write-Host "`n⚠️  GUTTER DETECTED - Same errors repeating" -ForegroundColor Red
            if ((Read-Host "Continue anyway? (y/n)") -ne "y") { break }
        }
        
        $taskInfo = Get-TaskInfo -TaskFilePath $TaskFilePath
        Write-Host "`n📊 Status: $($taskInfo.CompletedCriteria)/$($taskInfo.TotalCriteria) criteria complete" -ForegroundColor Cyan
        
        $prompt = Build-AgentPrompt -TaskInfo $taskInfo -Iteration $iteration -AgentName $AgentName
        $result = Invoke-Agent -AgentName $AgentName -Prompt $prompt -ModelName $ModelName -Iteration $iteration
        
        $iteration++
        Set-Content -Path $iterationFile -Value $iteration -Encoding UTF8
        Start-Sleep -Seconds 2
    }
    
    Write-Host "`n" + "=" * 70 -ForegroundColor Cyan
    Write-Host "  MAGI SESSION COMPLETE" -ForegroundColor White
    Write-Host "=" * 70 -ForegroundColor Cyan
}

# ============================================================================
# Watch Mode
# ============================================================================

function Start-WatchMode {
    Write-Host "`n👁️  Watch Mode - Monitoring MAGI activity..." -ForegroundColor Cyan
    $magiDir = $script:Config.paths.magiDir
    $activityLog = Join-Path $magiDir "activity.log"
    if (Test-Path $activityLog) { Get-Content $activityLog -Wait -Tail 20 }
    else { Write-Host "No activity log found. Run magi.ps1 first." -ForegroundColor Yellow }
}

function Show-AvailableModels {
    param([string]$AgentName)
    Write-Host "`n📋 Available models for $AgentName :" -ForegroundColor Cyan
    Get-AvailableModels -AgentName $AgentName | ForEach-Object { Write-Host "   - $_" -ForegroundColor Gray }
}

# ============================================================================
# Entry Point
# ============================================================================

Load-Configuration -ConfigPath $ConfigFile
$selectedAgent = if ($Agent) { $Agent } else { $script:Config.defaultAgent }

if ($ListModels) {
    Show-AvailableModels -AgentName $selectedAgent
    exit 0
}

Initialize-MAGI
if (-not (Test-AgentAvailable -AgentName $selectedAgent)) { exit 1 }

$selectedModel = if ($Model) { $Model } else { $script:Config.agents[$selectedAgent].defaultModel }
$maxIter = if ($MaxIterations -gt 0) { $MaxIterations } else { $script:Config.maxIterations }

if ($WatchOnly) { Start-WatchMode }
else { Start-MAGILoop -AgentName $selectedAgent -ModelName $selectedModel -MaxIter $maxIter -TaskFilePath $TaskFile }
