# VS Code Integration Guide

MAGI supports VS Code through **Gemini Code Assist** agent mode. Since VS Code doesn't have a CLI agent interface like Gemini CLI or Cursor, MAGI operates in "manual mode" where you copy prompts to the agent.

## Prerequisites

1. **VS Code** installed
2. **Gemini Code Assist** extension installed
3. Google account authenticated with Gemini

## Setup

1. Install **Gemini Code Assist** extension in VS Code
2. Login with your Google account
3. Open the Gemini panel (Ctrl+Shift+I) and select the **Agent** tab

## Using MAGI with VS Code

### Starting a MAGI Session

```powershell
# Run MAGI in VS Code mode
magi run "my-task" --agent vscode
```

### The Manual Loop

1. **MAGI generates a prompt** and saves it to `.magi/current_prompt.md`
2. **Copy the prompt** from that file
3. **Paste into VS Code** Gemini Agent chat
4. **Let the agent work** (approve file changes and shell commands)
5. **When done**, return to MAGI and press Enter
6. **MAGI checks progress** and either:
   - Declares victory if all criteria are complete
   - Generates a new prompt for the next iteration

## Why use this mode?

- Use VS Code's rich UI and extensions
- Full control over which changes are accepted
- Continue with the next MAGI iteration seamlessly

## Tips

- **Use Split View**: Keep your code on the left and the Gemini agent on the right.
- **Watch the Activity**: The agent shows what it's doing in real-time.
- **Manual Rotation**: If the agent gets stuck, close the chat and start a fresh session with the next MAGI prompt.
- **Guardrails**: Add failures to `.magi/guardrails.md` to prevent the agent from repeating mistakes.
