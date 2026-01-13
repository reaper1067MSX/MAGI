# VS Code Integration Guide

Ralph for Windows supports VS Code through **Gemini Code Assist** agent mode. Since VS Code doesn't have a CLI agent interface like Gemini CLI or Cursor, Ralph operates in "manual mode" where you copy prompts to the agent.

## Prerequisites

1. **VS Code** installed
2. **Gemini Code Assist** extension installed
3. Google account authenticated with Gemini

## Setup

### 1. Install Gemini Code Assist

1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for "Gemini Code Assist"
4. Install the official Google extension
5. Sign in with your Google account

### 2. Enable Agent Mode

1. Open the Gemini Code Assist panel (Ctrl+Shift+I)
2. Click the "Agent" tab at the top
3. You should see the agent chat interface

## Using Ralph with VS Code

### Starting a Ralph Session

```powershell
# Run Ralph in VS Code mode
.\ralph.bat vscode

# Or with PowerShell directly
.\ralph.ps1 -Agent vscode
```

### Workflow

1. **Ralph generates a prompt** and saves it to `.ralph\current_prompt.md`

2. **Copy the prompt** to VS Code:
   - Open `.ralph\current_prompt.md`
   - Select all (Ctrl+A)
   - Copy (Ctrl+C)
   - Paste into Gemini Code Assist agent chat

3. **Let the agent work**
   - The agent will read files, make changes, run commands
   - Approve file changes and shell commands as prompted
   - Wait for the agent to complete or get stuck

4. **When done**, return to Ralph and press Enter

5. **Ralph checks progress** and either:
   - Declares victory if all criteria are complete
   - Generates a new prompt for the next iteration

### Manual Rotation

If the agent starts going in circles or context seems polluted:

1. Close the current Gemini Code Assist chat
2. Open a new Agent chat session
3. Continue with the next Ralph iteration

This gives you a fresh context window.

## Configuration

### Auto-Approve Settings

For faster iteration, you can enable auto-approve in VS Code:

1. Open Settings (Ctrl+,)
2. Search for "Gemini Code Assist"
3. Find "Agent: Auto Approve Changes"
4. Enable (use with caution)

### Workspace Settings

Create `.vscode/settings.json`:

```json
{
    "geminiCodeAssist.agent.autoApprove": false,
    "geminiCodeAssist.agent.yoloMode": false
}
```

## Tips for VS Code Mode

### 1. Use Split View

Keep two panels open:
- Left: Your code files
- Right: Gemini Code Assist agent

### 2. Watch the Activity

The agent shows what it's doing in real-time. Watch for:
- 🔍 File reads (context consumption)
- ✏️ File writes (progress)
- 💻 Shell commands (tests, builds)

### 3. Know When to Rotate

Signs the agent needs a fresh context:
- Repeating the same action
- Undoing its own changes
- Circular reasoning in explanations
- Confidence increasing while progress stalls

### 4. Use Guardrails

When something fails, add it to `.ralph\guardrails.md` before the next iteration:

```markdown
### Sign: Check TypeScript errors before committing
- **Trigger**: After any file change
- **Instruction**: Run `npx tsc --noEmit` and fix errors before git commit
- **Added after**: Iteration 4 - committed code with type errors
```

## Comparison: VS Code vs CLI Agents

| Feature | Gemini CLI | Cursor CLI | VS Code |
|---------|-----------|------------|---------|
| Automation | Full | Full | Manual |
| Context rotation | Automatic | Automatic | Manual |
| Token tracking | Yes | Yes | No |
| IDE integration | No | Yes | Native |
| Visual feedback | Terminal | Terminal | Rich UI |
| Approval workflow | --yolo flag | --force flag | Click-based |

## Troubleshooting

### "Agent mode not available"

- Ensure you're signed into Google
- Check your Gemini Code Assist subscription/quota
- Try reloading VS Code

### "Agent seems stuck"

- Check the terminal output for errors
- Look at the agent's "thinking" messages
- Consider manual rotation to fresh context

### "Changes not being saved"

- Approve file changes when prompted
- Check for pending approvals in the agent UI
- Ensure auto-approve is enabled if desired

## Hybrid Approach

You can combine VS Code for visualization with CLI agents for automation:

1. Run `.\ralph.bat gemini` in a terminal
2. Open the project in VS Code
3. Watch files change in real-time
4. Use VS Code for manual fixes if needed

This gives you the best of both worlds: automated iteration with visual feedback.
