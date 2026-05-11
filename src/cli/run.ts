import { UI } from './ui.js';
import { RalphEngine } from '../engine/RalphEngine.js';
import { loadConfig } from '../config/index.js';
import { GeminiAgent } from '../agents/GeminiAgent.js';
import { ClaudeAgent } from '../agents/ClaudeAgent.js';
import { OpenAIAgent, OllamaAgent } from '../agents/OpenAIAgent.js';
import type { AgentAdapter } from '../types/index.js';

export async function runInteractive(taskName: string) {
  const ui = new UI();
  ui.logSystem('MAGI Interactive Run', `Starting task: ${taskName}`);

  try {
    const config = await loadConfig('ralph-config.json');
    const engine = new RalphEngine(config);

    const agents: Record<string, AgentAdapter> = {
      'gemini-cli': new GeminiAgent(),
      'claude': new ClaudeAgent(),
      'openai': new OpenAIAgent(),
      'ollama': new OllamaAgent(),
    };

    const agentName = config.defaultAgent;
    const agent = agents[agentName];

    if (!agent) {
      ui.logError('Setup Error', `Agent '${agentName}' not found. Please check your ralph-config.json`);
      process.exit(1);
    }

    ui.logUser(`Executing iteration with ${agent.name}...`);
    ui.startAction(`Running engine loop...`);

    const result = await engine.runIteration(agent, taskName);

    if (result.success) {
      ui.succeedAction('Iteration completed successfully');
      if (result.nextStep) {
        ui.logReasoning(agent.name, 'Generated next steps based on progress.');
      }
      ui.logSystem('Iteration Result', result.message);
    } else {
      ui.failAction('Iteration failed');
      ui.logError('Engine Error', result.message);
    }
  } catch (error) {
    ui.logError('Fatal Error', error as Error);
    process.exit(1);
  }
}
