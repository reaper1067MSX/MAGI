import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import * as os from 'node:os';
import { UI } from './ui.js';

const ui = new UI();

export async function runSetup() {
  ui.logSystem('MAGI Setup', 'Starting auto-registration for AI clients...');

  const results = [];
  
  // 1. Gemini CLI
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

  // 2. Claude Desktop
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
  if (successCount > 0) {
    ui.logSystem('Setup Complete', `Successfully verified/registered in ${successCount} client(s). You can now use MAGI directly from them!`);
  } else {
    ui.logSystem('Setup Incomplete', 'Could not find supported AI clients. You may need to manually add "magi-orchestrator" to your MCP config.');
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

    // If it's claude, we might need env vars if they don't want to use ralph-config.json
    // But for now, we rely on ralph-config.json or global env vars

    await fs.writeFile(configPath, JSON.stringify(config, null, 2));
    return { success: true, skipped: false };
  } catch (error) {
    return { success: false, skipped: false };
  }
}
