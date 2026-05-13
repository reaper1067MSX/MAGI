@echo off
REM ============================================================================
REM MAGI for Windows - Multi-Agent Batch Wrapper
REM ============================================================================
REM
REM Usage: magi.bat [agent] [options]
REM
REM Agents:
REM   gemini     - Google Gemini CLI (default, largest free context)
REM   cursor     - Cursor CLI (multi-model)
REM   openai     - OpenAI API (GPT-4, GPT-4o)
REM   codex      - OpenAI Codex/GPT-4 for code
REM   ollama     - Ollama local models
REM   lmstudio   - LM Studio local models
REM   local      - Generic local server
REM   network    - Network model (specify endpoint)
REM   vscode     - VS Code manual mode
REM
REM Examples:
REM   magi.bat                           - Run with Gemini (default)
REM   magi.bat openai                    - Run with OpenAI GPT-4o
REM   magi.bat ollama -Model codellama   - Run with Ollama CodeLlama
REM   magi.bat network -Endpoint http://192.168.1.100:8080/v1/chat/completions
REM   magi.bat watch                     - Monitor activity logs
REM   magi.bat models ollama             - List available Ollama models
REM
REM ============================================================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "MAGI_SCRIPT=%SCRIPT_DIR%.magi-scripts\magi.ps1"

REM Check if script exists in .magi-scripts
if not exist "%MAGI_SCRIPT%" (
    set "MAGI_SCRIPT=%SCRIPT_DIR%scripts\magi.ps1"
)
if not exist "%MAGI_SCRIPT%" (
    set "MAGI_SCRIPT=%SCRIPT_DIR%magi.ps1"
)

if not exist "%MAGI_SCRIPT%" (
    echo.
    echo ERROR: magi.ps1 not found
    echo Expected locations:
    echo   - %SCRIPT_DIR%.magi-scripts\magi.ps1
    echo   - %SCRIPT_DIR%scripts\magi.ps1
    echo   - %SCRIPT_DIR%magi.ps1
    echo.
    echo Run install.ps1 first to set up MAGI.
    echo.
    exit /b 1
)

REM Handle special commands
if /i "%1"=="help" goto :show_help
if /i "%1"=="-h" goto :show_help
if /i "%1"=="--help" goto :show_help
if /i "%1"=="/?" goto :show_help

if /i "%1"=="watch" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%MAGI_SCRIPT%" -WatchOnly
    exit /b %ERRORLEVEL%
)

if /i "%1"=="models" (
    if "%2"=="" (
        powershell -NoProfile -ExecutionPolicy Bypass -File "%MAGI_SCRIPT%" -ListModels
    ) else (
        powershell -NoProfile -ExecutionPolicy Bypass -File "%MAGI_SCRIPT%" -Agent %2 -ListModels
    )
    exit /b %ERRORLEVEL%
)

if /i "%1"=="init" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%.magi-scripts\init-magi.ps1" %2 %3 %4
    exit /b %ERRORLEVEL%
)

REM Parse agent name (first argument)
set "AGENT_ARG="
set "EXTRA_ARGS="

if "%1"=="" (
    set "AGENT_ARG=-Agent gemini"
    goto :run
)

REM Check if first arg is a known agent
for %%A in (gemini cursor openai codex ollama lmstudio local network vscode anthropic azure) do (
    if /i "%1"=="%%A" (
        set "AGENT_ARG=-Agent %1"
        shift
        goto :collect_args
    )
)

REM Not a known agent, pass everything through
set "EXTRA_ARGS=%*"
goto :run

:collect_args
if "%1"=="" goto :run
set "EXTRA_ARGS=!EXTRA_ARGS! %1"
shift
goto :collect_args

:run
echo.
echo Starting MAGI for Windows...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%MAGI_SCRIPT%" %AGENT_ARG% %EXTRA_ARGS%
exit /b %ERRORLEVEL%

:show_help
echo.
echo ============================================================================
echo   MAGI FOR WINDOWS - Multi-Agent Autonomous Development
echo ============================================================================
echo.
echo Usage: magi.bat [agent] [options]
echo.
echo AGENTS (Cloud):
echo   gemini       Google Gemini CLI (default) - 1M+ token context, free tier
echo   cursor       Cursor CLI - multi-model support
echo   openai       OpenAI API (GPT-4o, GPT-4-turbo, o1)
echo   codex        OpenAI Codex/GPT-4 code models
echo   anthropic    Anthropic Claude API
echo   azure        Azure OpenAI deployment
echo.
echo AGENTS (Local):
echo   ollama       Ollama - run models locally (CodeLlama, DeepSeek, Llama)
echo   lmstudio     LM Studio - GUI for local models
echo   local        Generic local server (LocalAI, vLLM, text-generation-webui)
echo.
echo AGENTS (Network):
echo   network      Custom endpoint - use -Endpoint to specify URL
echo.
echo AGENTS (Manual):
echo   vscode       VS Code with Gemini Code Assist (manual copy-paste)
echo.
echo OPTIONS:
echo   -Model ^<name^>        Specify model (e.g., gpt-4o, codellama:34b)
echo   -Endpoint ^<url^>      API endpoint for local/network agents
echo   -MaxIterations ^<n^>   Maximum loop iterations (default: 20)
echo   -Force               Skip confirmation prompts
echo   -WatchOnly           Monitor logs without running
echo   -ListModels          Show available models for agent
echo.
echo COMMANDS:
echo   watch                Monitor activity logs in real-time
echo   models [agent]       List available models
echo   init                 Reset MAGI state
echo   help                 Show this help
echo.
echo EXAMPLES:
echo   magi.bat                                    Run with Gemini (default)
echo   magi.bat openai                             Run with OpenAI GPT-4o
echo   magi.bat openai -Model gpt-4-turbo         Run with specific model
echo   magi.bat ollama -Model deepseek-coder:33b  Run with local DeepSeek
echo   magi.bat lmstudio                           Run with LM Studio
echo   magi.bat network -Endpoint http://myserver:8080/v1/chat/completions
echo   magi.bat watch                              Monitor logs
echo   magi.bat models ollama                      List Ollama models
echo.
echo ENVIRONMENT VARIABLES:
echo   OPENAI_API_KEY       Required for openai/codex agents
echo   ANTHROPIC_API_KEY    Required for anthropic agent
echo   AZURE_OPENAI_API_KEY Required for azure agent
echo   MAGI_AGENT          Default agent (overrides config)
echo   MAGI_MODEL          Default model
echo.
echo DOCUMENTATION:
echo   README.md            Full documentation
echo   QUICKSTART.md        3-minute setup guide
echo   docs\LOCAL_MODELS.md Guide for local model setup
echo.
exit /b 0
