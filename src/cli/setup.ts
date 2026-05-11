import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import * as os from 'node:os';
import { UI } from './ui.js';

const ui = new UI();

export async function runSetup() {
  ui.logSystem('MAGI Setup', 'Starting auto-registration for AI clients...');

  const results = [];
  
  // 1. Gemini CLI Config
  const geminiConfigPath = path.join(os.homedir(), '.gemini', 'config.json');
  ui.startAction('Checking Gemini CLI config...');
  const geminiResult = await registerInConfig(geminiConfigPath, 'gemini');
  if (geminiResult.success) {
    ui.succeedAction('Registered in Gemini CLI');
  } else if (geminiResult.skipped) {
    ui.succeedAction('Already registered in Gemini CLI');
  } else {
    ui.failAction('Gemini CLI config not found or unreadable');
  }
  results.push({ name: 'Gemini CLI', ...geminiResult });

  // 2. Gemini CLI Skill (/magi)
  ui.startAction('Installing /magi Skill for Gemini CLI...');
  const skillResult = await installGeminiSkill();
  if (skillResult) {
    ui.succeedAction('Skill /magi installed successfully');
  } else {
    ui.failAction('Failed to install /magi skill');
  }

  // 3. Claude Desktop
  const claudeConfigPath = getClaudeConfigPath();
  ui.startAction('Checking Claude Desktop config...');
  const claudeResult = await registerInConfig(claudeConfigPath, 'claude');
  if (claudeResult.success) {
    ui.succeedAction('Registered in Claude Desktop');
  } else if (claudeResult.skipped) {
    ui.succeedAction('Already registered in Claude Desktop');
  } else {
    ui.failAction('Claude Desktop config not found or unreadable');
  }
  results.push({ name: 'Claude Desktop', ...claudeResult });

  // Summary
  const successCount = results.filter(r => r.success || r.skipped).length;
  if (successCount > 0 || skillResult) {
    ui.logSystem('Setup Complete', `Successfully verified/registered in supported clients. You can now use MAGI directly or type '/magi' in Gemini CLI!`);
  } else {
    ui.logSystem('Setup Incomplete', 'Could not find supported AI clients. You may need to manually add "magi-orchestrator" to your MCP config.');
  }
}

async function installGeminiSkill(): Promise<boolean> {
  try {
    const skillsDir = path.join(os.homedir(), '.gemini', 'skills', 'magi');
    await fs.mkdir(skillsDir, { recursive: true });

    const skillContent = `---
name: magi
description: "Triggers the MAGI MCP server to orchestrate a task iteration."
---
# MAGI Orchestrator Skill

## Purpose
You are an expert task orchestrator. When the user invokes this skill, you must delegate the task execution to the MAGI MCP server.

## Instructions
1. The user will provide a task name (e.g., \`/magi fix-auth-bug\`).
2. You MUST immediately call the \`run_ralph_iteration\` MCP tool.
3. Pass the provided text as the \`taskName\` argument to the tool.
4. Present the results returned by MAGI cleanly to the user. Do not ask for permission before calling the tool.
`;

    await fs.writeFile(path.join(skillsDir, 'SKILL.md'), skillContent);
    return true;
  } catch (error) {
    return false;
  }
}

function getClaudeConfigPath(): string {
  if (process.platform === 'win32') {
    return path.join(process.env.APPDATA || '', 'Claude', 'claude_desktop_config.json');
  } else if (process.platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'Claude', 'claude_desktop_config.json');
  } else {
    // Linux (unofficial/community builds usually follow this)
    return path.join(os.homedir(), '.config', 'Claude', 'claude_desktop_config.json');
  }
}

async function registerInConfig(configPath: string, clientType: 'gemini' | 'claude'): Promise<{ success: boolean; skipped: boolean }> {
  try {
    const dir = path.dirname(configPath);
    await fs.mkdir(dir, { recursive: true });

    let configData = '{}';
    try {
      configData = await fs.readFile(configPath, 'utf8');
    } catch {
      // File doesn't exist, we will create it if we have write access to the dir
    }

    let config;
    try {
      config = JSON.parse(configData);
    } catch {
      config = {};
    }

    if (!config.mcpServers) {
      config.mcpServers = {};
    }

    if (config.mcpServers['magi']) {
      return { success: true, skipped: true }; // Already registered
    }

    config.mcpServers['magi'] = {
      command: process.platform === 'win32' ? 'magi-orchestrator.cmd' : 'magi-orchestrator',
      args: []
    };

    await fs.writeFile(configPath, JSON.stringify(config, null, 2));
    return { success: true, skipped: false };
  } catch (error) {
    return { success: false, skipped: false };
  }
}
