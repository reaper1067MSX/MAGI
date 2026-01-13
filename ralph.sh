#!/bin/bash
# =============================================================================
# Ralph - Cross-Platform Autonomous AI Development
# =============================================================================
#
# Implements Geoffrey Huntley's Ralph Wiggum technique for multiple AI agents:
#   - Gemini CLI (Google)
#   - Claude Code CLI
#   - OpenAI API (GPT-4, GPT-4o)
#   - Local models (Ollama, LM Studio, LocalAI)
#   - Networked models (OpenAI-compatible APIs)
#
# Usage:
#   ./ralph.sh [agent] [options]
#
# Examples:
#   ./ralph.sh                          # Run with Gemini (default)
#   ./ralph.sh openai                   # Run with OpenAI
#   ./ralph.sh ollama --model codellama # Run with Ollama
#   ./ralph.sh watch                    # Monitor logs
#
# Supports: macOS, Ubuntu, Debian, Raspberry Pi OS, Fedora, Arch, and more
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# =============================================================================
# Default Configuration
# =============================================================================

DEFAULT_AGENT="gemini"
DEFAULT_MAX_ITERATIONS=20
RALPH_DIR=".ralph"
TASK_FILE="RALPH_TASK.md"
CONFIG_FILE=".ralph-scripts/ralph-config.json"

# Agent configurations (associative arrays)
declare -A AGENT_TYPE
declare -A AGENT_ENDPOINT
declare -A AGENT_MODEL
declare -A AGENT_CONTEXT
declare -A AGENT_API_KEY_VAR
declare -A AGENT_FORMAT

# CLI Agents
AGENT_TYPE[gemini]="cli"
AGENT_MODEL[gemini]="gemini-2.5-pro"
AGENT_CONTEXT[gemini]=1000000

AGENT_TYPE[claude]="cli"
AGENT_MODEL[claude]="claude-sonnet-4-20250514"
AGENT_CONTEXT[claude]=200000

# API Agents
AGENT_TYPE[openai]="api"
AGENT_ENDPOINT[openai]="https://api.openai.com/v1/chat/completions"
AGENT_MODEL[openai]="gpt-4o"
AGENT_CONTEXT[openai]=128000
AGENT_API_KEY_VAR[openai]="OPENAI_API_KEY"
AGENT_FORMAT[openai]="openai"

AGENT_TYPE[anthropic]="api"
AGENT_ENDPOINT[anthropic]="https://api.anthropic.com/v1/messages"
AGENT_MODEL[anthropic]="claude-sonnet-4-20250514"
AGENT_CONTEXT[anthropic]=200000
AGENT_API_KEY_VAR[anthropic]="ANTHROPIC_API_KEY"
AGENT_FORMAT[anthropic]="anthropic"

AGENT_TYPE[ollama]="api"
AGENT_ENDPOINT[ollama]="http://localhost:11434/api/chat"
AGENT_MODEL[ollama]="codellama:13b"
AGENT_CONTEXT[ollama]=32000
AGENT_FORMAT[ollama]="ollama"

AGENT_TYPE[lmstudio]="api"
AGENT_ENDPOINT[lmstudio]="http://localhost:1234/v1/chat/completions"
AGENT_MODEL[lmstudio]="local-model"
AGENT_CONTEXT[lmstudio]=32000
AGENT_FORMAT[lmstudio]="openai"

AGENT_TYPE[local]="api"
AGENT_ENDPOINT[local]="http://localhost:8080/v1/chat/completions"
AGENT_MODEL[local]="default"
AGENT_CONTEXT[local]=32000
AGENT_FORMAT[local]="openai"

AGENT_TYPE[network]="api"
AGENT_ENDPOINT[network]=""
AGENT_MODEL[network]="default"
AGENT_CONTEXT[network]=32000
AGENT_FORMAT[network]="openai"

# =============================================================================
# Utility Functions
# =============================================================================

log_info() {
    echo -e "${CYAN}$1${NC}"
}

log_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

log_error() {
    echo -e "${RED}✗ $1${NC}"
}

log_gray() {
    echo -e "${GRAY}$1${NC}"
}

# =============================================================================
# Help
# =============================================================================

show_help() {
    cat << 'EOF'

============================================================================
  RALPH FOR LINUX - Multi-Agent Autonomous Development
============================================================================

Usage: ./ralph.sh [agent] [options]

AGENTS (Cloud):
  gemini       Google Gemini CLI (default) - 1M+ token context, free tier
  claude       Claude Code CLI
  openai       OpenAI API (GPT-4o, GPT-4-turbo, o1)
  anthropic    Anthropic Claude API

AGENTS (Local):
  ollama       Ollama - run models locally (CodeLlama, DeepSeek, Llama)
  lmstudio     LM Studio - GUI for local models
  local        Generic local server (LocalAI, vLLM, text-generation-webui)

AGENTS (Network):
  network      Custom endpoint - use --endpoint to specify URL

OPTIONS:
  --model <name>        Specify model (e.g., gpt-4o, codellama:34b)
  --endpoint <url>      API endpoint for local/network agents
  --max-iterations <n>  Maximum loop iterations (default: 20)
  --task <file>         Task file (default: RALPH_TASK.md)
  --force               Skip confirmation prompts
  --list-models         Show available models for agent
  --watch               Monitor activity logs in real-time
  --help, -h            Show this help

EXAMPLES:
  ./ralph.sh                                    Run with Gemini (default)
  ./ralph.sh openai                             Run with OpenAI GPT-4o
  ./ralph.sh openai --model gpt-4-turbo         Run with specific model
  ./ralph.sh ollama --model deepseek-coder:33b  Run with local DeepSeek
  ./ralph.sh network --endpoint http://myserver:8080/v1/chat/completions
  ./ralph.sh watch                              Monitor logs
  ./ralph.sh ollama --list-models               List Ollama models

ENVIRONMENT VARIABLES:
  OPENAI_API_KEY       Required for openai agent
  ANTHROPIC_API_KEY    Required for anthropic agent
  RALPH_AGENT          Default agent (overrides config)
  RALPH_MODEL          Default model

DOCUMENTATION:
  README.md              Full documentation
  docs/QUICKSTART.md     Quick setup guide
  docs/LOCAL_MODELS.md   Guide for local model setup
  docs/LINUX_SETUP.md    Linux-specific instructions

EOF
}

# =============================================================================
# Initialization
# =============================================================================

initialize_ralph() {
    # Create .ralph directory if it doesn't exist
    if [[ ! -d "$RALPH_DIR" ]]; then
        mkdir -p "$RALPH_DIR"
    fi

    # Initialize state files
    if [[ ! -f "$RALPH_DIR/progress.md" ]]; then
        cat > "$RALPH_DIR/progress.md" << 'EOF'
# Progress Log

## Completed Criteria
(None yet)

## Current Status
Starting fresh iteration.

## Notes
EOF
        echo "- Initialized: $(date '+%Y-%m-%d %H:%M:%S')" >> "$RALPH_DIR/progress.md"
    fi

    if [[ ! -f "$RALPH_DIR/guardrails.md" ]]; then
        cat > "$RALPH_DIR/guardrails.md" << 'EOF'
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
EOF
    fi

    if [[ ! -f "$RALPH_DIR/activity.log" ]]; then
        echo "# Activity Log" > "$RALPH_DIR/activity.log"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] INIT Started" >> "$RALPH_DIR/activity.log"
    fi

    if [[ ! -f "$RALPH_DIR/errors.log" ]]; then
        echo "# Error Log" > "$RALPH_DIR/errors.log"
    fi

    if [[ ! -f "$RALPH_DIR/.iteration" ]]; then
        echo "1" > "$RALPH_DIR/.iteration"
    fi

    # Check for task file
    if [[ ! -f "$TASK_FILE" ]]; then
        log_error "Task file not found: $TASK_FILE"
        log_warning "Create a RALPH_TASK.md file with your task definition."

        cat > "$TASK_FILE" << 'EOF'
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
EOF
        log_info "Created template at $TASK_FILE - please edit and run again."
        exit 1
    fi
}

# =============================================================================
# Agent Detection
# =============================================================================

check_agent_available() {
    local agent=$1
    local agent_type=${AGENT_TYPE[$agent]}

    case $agent_type in
        cli)
            case $agent in
                gemini)
                    if ! command -v gemini &> /dev/null; then
                        log_error "Gemini CLI not found"
                        log_warning "Install: npm install -g @google/gemini-cli"
                        return 1
                    fi
                    ;;
                claude)
                    if ! command -v claude &> /dev/null; then
                        log_error "Claude Code CLI not found"
                        log_warning "Install: npm install -g @anthropic-ai/claude-code"
                        return 1
                    fi
                    ;;
            esac
            ;;
        api)
            local api_key_var=${AGENT_API_KEY_VAR[$agent]}
            if [[ -n "$api_key_var" ]]; then
                if [[ -z "${!api_key_var}" ]]; then
                    log_error "API key not found"
                    log_warning "Set environment variable: export $api_key_var=\"your-key\""
                    return 1
                fi
            fi

            if [[ "$agent" == "network" && -z "$ENDPOINT" ]]; then
                log_error "Endpoint required for network agent"
                log_warning "Use: --endpoint 'http://your-server:port/v1/chat/completions'"
                return 1
            fi
            ;;
    esac

    return 0
}

list_models() {
    local agent=$1

    echo ""
    log_info "Available models for $agent:"

    case $agent in
        ollama)
            if command -v curl &> /dev/null; then
                curl -s http://localhost:11434/api/tags 2>/dev/null | \
                    grep -o '"name":"[^"]*"' | cut -d'"' -f4 | while read model; do
                    echo "   - $model"
                done
            else
                echo "   - codellama:7b"
                echo "   - codellama:13b"
                echo "   - codellama:34b"
                echo "   - deepseek-coder:6.7b"
                echo "   - deepseek-coder:33b"
                echo "   - llama3:8b"
            fi
            ;;
        openai)
            echo "   - gpt-4o"
            echo "   - gpt-4o-mini"
            echo "   - gpt-4-turbo"
            echo "   - o1"
            echo "   - o1-mini"
            ;;
        anthropic)
            echo "   - claude-opus-4-20250514"
            echo "   - claude-sonnet-4-20250514"
            echo "   - claude-3-5-haiku-20241022"
            ;;
        gemini)
            echo "   - gemini-2.5-pro"
            echo "   - gemini-2.5-flash"
            echo "   - gemini-2.0-flash"
            ;;
        *)
            echo "   - ${AGENT_MODEL[$agent]}"
            ;;
    esac
    echo ""
}

# =============================================================================
# Task Parsing
# =============================================================================

get_task_info() {
    local task_file=$1

    # Count checkboxes
    UNCHECKED=$(grep -c '\[ \]' "$task_file" 2>/dev/null || echo 0)
    CHECKED=$(grep -cE '\[x\]|\[X\]' "$task_file" 2>/dev/null || echo 0)
    TOTAL=$((UNCHECKED + CHECKED))

    # Extract task name from frontmatter
    TASK_NAME=$(grep -m1 '^task:' "$task_file" 2>/dev/null | sed 's/task:\s*//' || echo "Unknown")

    # Extract test command
    TEST_COMMAND=$(grep -m1 '^test_command:' "$task_file" 2>/dev/null | sed 's/test_command:\s*//' || echo "")
}

# =============================================================================
# Prompt Building
# =============================================================================

build_prompt() {
    local iteration=$1
    local agent=$2

    # Read state files
    local guardrails=""
    local progress=""
    local errors=""

    [[ -f "$RALPH_DIR/guardrails.md" ]] && guardrails=$(cat "$RALPH_DIR/guardrails.md")
    [[ -f "$RALPH_DIR/progress.md" ]] && progress=$(cat "$RALPH_DIR/progress.md")
    [[ -f "$RALPH_DIR/errors.log" ]] && errors=$(tail -30 "$RALPH_DIR/errors.log")

    # Get file list
    local file_list=$(find . -type f -maxdepth 3 \
        ! -path './node_modules/*' \
        ! -path './.git/*' \
        ! -path './.ralph/*' \
        ! -path './__pycache__/*' \
        ! -path './venv/*' \
        ! -path './dist/*' \
        ! -path './build/*' \
        2>/dev/null | head -50)

    local task_content=$(cat "$TASK_FILE")

    cat << EOF
# RALPH AUTONOMOUS AGENT - ITERATION $iteration

You are an autonomous coding agent working on a task. Your context is fresh each iteration.
Progress persists in FILES and GIT, not in conversation history.

## CRITICAL INSTRUCTIONS

1. **READ GUARDRAILS FIRST** - These are lessons from previous failures. Follow them.
2. **CHECK PROGRESS** - See what's already been done. Don't redo completed work.
3. **WORK ON UNCHECKED CRITERIA** - Focus on [ ] items, not [x] items.
4. **COMMIT FREQUENTLY** - Use git to save progress after each criterion.
5. **UPDATE STATE FILES** - Write to .ralph/progress.md after completing work.
6. **ADD GUARDRAILS** - If something fails repeatedly, add a Sign to .ralph/guardrails.md

## GUARDRAILS (READ FIRST!)

$guardrails

## CURRENT PROGRESS

$progress

## RECENT ERRORS (if any)

$errors

## PROJECT FILES

$file_list

## TASK DEFINITION

$task_content

## YOUR MISSION THIS ITERATION

1. Read and follow all guardrails above
2. Check what criteria are already completed [x]
3. Work on the next unchecked criterion [ ]
4. Run tests after changes: $TEST_COMMAND
5. Commit with: git add -A && git commit -m "ralph: [description]"
6. Update .ralph/progress.md with completed work
7. If something fails repeatedly, add a guardrail

## STATE FILE FORMATS

When updating .ralph/progress.md:
\`\`\`markdown
## Completed Criteria
- [x] Criterion 1 - completed in iteration N
- [x] Criterion 2 - completed in iteration N

## Current Status
Working on: [current criterion]

## Notes
[Any relevant notes]
\`\`\`

When adding a guardrail to .ralph/guardrails.md:
\`\`\`markdown
### Sign: [Short description]
- **Trigger**: [When this applies]
- **Instruction**: [What to do instead]
- **Added after**: Iteration $iteration - [what happened]
\`\`\`

---

BEGIN WORK. Focus on unchecked criteria. Commit progress. Update state files.
EOF
}

# =============================================================================
# API Clients
# =============================================================================

invoke_openai_api() {
    local endpoint=$1
    local prompt=$2
    local model=$3
    local api_key=$4

    local response=$(curl -s "$endpoint" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $api_key" \
        -d "{
            \"model\": \"$model\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are an expert coding assistant. Execute tasks precisely and update progress files.\"},
                {\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}
            ],
            \"max_tokens\": 4096,
            \"temperature\": 0.7
        }" 2>&1)

    echo "$response" | jq -r '.choices[0].message.content // .error.message // "Error: Unknown response"'
}

invoke_ollama_api() {
    local endpoint=$1
    local prompt=$2
    local model=$3

    local response=$(curl -s "$endpoint" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"$model\",
            \"messages\": [
                {\"role\": \"system\", \"content\": \"You are an expert coding assistant. Execute tasks precisely.\"},
                {\"role\": \"user\", \"content\": $(echo "$prompt" | jq -Rs .)}
            ],
            \"stream\": false
        }" 2>&1)

    echo "$response" | jq -r '.message.content // .error // "Error: Unknown response"'
}

# =============================================================================
# Agent Execution
# =============================================================================

invoke_agent() {
    local agent=$1
    local prompt=$2
    local model=$3
    local iteration=$4

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] === ITERATION $iteration - $agent ===" >> "$RALPH_DIR/activity.log"

    local agent_type=${AGENT_TYPE[$agent]}

    case $agent_type in
        cli)
            invoke_cli_agent "$agent" "$prompt" "$model" "$iteration"
            ;;
        api)
            invoke_api_agent "$agent" "$prompt" "$model" "$iteration"
            ;;
    esac
}

invoke_cli_agent() {
    local agent=$1
    local prompt=$2
    local model=$3
    local iteration=$4

    log_info "Starting $agent CLI (Iteration $iteration)..."

    case $agent in
        gemini)
            local args="-p --yolo"
            [[ -n "$model" ]] && args="$args --model $model"
            echo "$prompt" | gemini $args 2>&1
            ;;
        claude)
            echo "$prompt" | claude --print 2>&1
            ;;
    esac

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $agent completed" >> "$RALPH_DIR/activity.log"
}

invoke_api_agent() {
    local agent=$1
    local prompt=$2
    local model=$3
    local iteration=$4

    local endpoint=${ENDPOINT:-${AGENT_ENDPOINT[$agent]}}
    local api_model=${model:-${AGENT_MODEL[$agent]}}
    local api_format=${AGENT_FORMAT[$agent]}
    local api_key_var=${AGENT_API_KEY_VAR[$agent]}
    local api_key=${!api_key_var}

    log_info "Starting $agent API (Iteration $iteration)..."
    log_gray "   Endpoint: $endpoint"
    log_gray "   Model: $api_model"

    local response=""
    case $api_format in
        ollama)
            response=$(invoke_ollama_api "$endpoint" "$prompt" "$api_model")
            ;;
        *)
            response=$(invoke_openai_api "$endpoint" "$prompt" "$api_model" "$api_key")
            ;;
    esac

    echo ""
    log_info "Agent Response:"
    echo "${response:0:500}"
    [[ ${#response} -gt 500 ]] && echo "..."

    # Save full response
    echo "$response" > "$RALPH_DIR/last_response.md"

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $agent API completed" >> "$RALPH_DIR/activity.log"
}

# =============================================================================
# Progress Checking
# =============================================================================

check_task_complete() {
    get_task_info "$TASK_FILE"
    [[ $UNCHECKED -eq 0 ]]
}

check_gutter_condition() {
    if [[ ! -f "$RALPH_DIR/errors.log" ]]; then
        return 1
    fi

    # Check for repeated errors
    local error_count=$(tail -20 "$RALPH_DIR/errors.log" | grep -ciE 'error|failed|exception' || echo 0)
    [[ $error_count -ge 3 ]]
}

# =============================================================================
# Watch Mode
# =============================================================================

watch_mode() {
    log_info "Watch Mode - Monitoring Ralph activity..."
    log_gray "Press Ctrl+C to stop"
    echo ""

    if [[ -f "$RALPH_DIR/activity.log" ]]; then
        tail -f "$RALPH_DIR/activity.log"
    else
        log_warning "No activity log found. Run ralph.sh first."
    fi
}

# =============================================================================
# Main Loop
# =============================================================================

run_ralph_loop() {
    local agent=$1
    local model=$2
    local max_iter=$3

    # Get current iteration
    local iteration=1
    [[ -f "$RALPH_DIR/.iteration" ]] && iteration=$(cat "$RALPH_DIR/.iteration")

    # Get task info
    get_task_info "$TASK_FILE"

    # Display summary
    echo ""
    echo -e "${CYAN}======================================================================${NC}"
    echo -e "  RALPH FOR LINUX - Multi-Agent Edition"
    echo -e "${CYAN}======================================================================${NC}"
    echo ""
    log_gray "  Agent:       $agent (${AGENT_TYPE[$agent]})"
    log_gray "  Model:       ${model:-${AGENT_MODEL[$agent]}}"
    log_gray "  Task:        $TASK_NAME"
    log_gray "  Progress:    $CHECKED/$TOTAL criteria"
    log_gray "  Iteration:   $iteration (max: $max_iter)"

    if [[ "${AGENT_TYPE[$agent]}" == "api" ]]; then
        log_gray "  Endpoint:    ${ENDPOINT:-${AGENT_ENDPOINT[$agent]}}"
    fi

    echo ""
    echo -e "${GRAY}----------------------------------------------------------------------${NC}"

    if [[ "$FORCE" != "true" ]]; then
        echo ""
        read -p "Start Ralph loop? (y/n) " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            log_warning "Aborted."
            exit 0
        fi
    fi

    # Main loop
    while [[ $iteration -le $max_iter ]]; do
        echo ""
        echo -e "${BLUE}======================================================================${NC}"
        echo -e "  ITERATION $iteration / $max_iter"
        echo -e "${BLUE}======================================================================${NC}"

        # Check if complete
        if check_task_complete; then
            echo ""
            log_success "ALL CRITERIA COMPLETE!"
            log_info "Task finished in $iteration iterations."
            break
        fi

        # Check for gutter
        if check_gutter_condition; then
            echo ""
            log_error "GUTTER DETECTED - Same errors repeating"
            log_warning "Check .ralph/errors.log and add guardrails."

            read -p "Continue anyway? (y/n) " cont
            [[ "$cont" != "y" && "$cont" != "Y" ]] && break
        fi

        # Refresh task info
        get_task_info "$TASK_FILE"
        echo ""
        log_info "Status: $CHECKED/$TOTAL criteria complete"
        log_gray "   Remaining: $UNCHECKED criteria"

        # Build and execute
        local prompt=$(build_prompt "$iteration" "$agent")
        invoke_agent "$agent" "$prompt" "$model" "$iteration"

        # Update iteration
        iteration=$((iteration + 1))
        echo "$iteration" > "$RALPH_DIR/.iteration"

        log_gray "Rotating to fresh context..."
        sleep 2
    done

    if [[ $iteration -gt $max_iter ]]; then
        echo ""
        log_warning "Max iterations ($max_iter) reached"
    fi

    # Final summary
    get_task_info "$TASK_FILE"
    echo ""
    echo -e "${CYAN}======================================================================${NC}"
    echo -e "  RALPH SESSION COMPLETE"
    echo -e "${CYAN}======================================================================${NC}"
    echo "  Iterations:  $((iteration - 1))"
    echo "  Completed:   $CHECKED/$TOTAL criteria"
    echo "  Logs:        $RALPH_DIR/activity.log"
    echo "  Errors:      $RALPH_DIR/errors.log"
    echo ""
}

# =============================================================================
# Main Entry Point
# =============================================================================

# Parse arguments
AGENT=""
MODEL=""
ENDPOINT=""
MAX_ITERATIONS=$DEFAULT_MAX_ITERATIONS
FORCE="false"
LIST_MODELS="false"
WATCH="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        --endpoint)
            ENDPOINT="$2"
            shift 2
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        --task)
            TASK_FILE="$2"
            shift 2
            ;;
        --force)
            FORCE="true"
            shift
            ;;
        --list-models)
            LIST_MODELS="true"
            shift
            ;;
        --watch|watch)
            WATCH="true"
            shift
            ;;
        gemini|claude|openai|anthropic|ollama|lmstudio|local|network)
            AGENT="$1"
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Set default agent
AGENT=${AGENT:-$DEFAULT_AGENT}

# Handle special modes
if [[ "$WATCH" == "true" ]]; then
    watch_mode
    exit 0
fi

if [[ "$LIST_MODELS" == "true" ]]; then
    list_models "$AGENT"
    exit 0
fi

# Check dependencies
if ! command -v jq &> /dev/null; then
    log_error "jq is required but not installed"
    log_warning "Install with: sudo apt install jq"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    log_error "curl is required but not installed"
    log_warning "Install with: sudo apt install curl"
    exit 1
fi

# Initialize
initialize_ralph

# Check agent availability
if ! check_agent_available "$AGENT"; then
    exit 1
fi

# Run the loop
run_ralph_loop "$AGENT" "$MODEL" "$MAX_ITERATIONS"
