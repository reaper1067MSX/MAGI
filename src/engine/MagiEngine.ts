import * as fs from 'node:fs/promises';
import * as path from 'node:path';
import type { MagiConfig, IterationResult, AgentAdapter, AgentContext } from '../types/index.js';

export class MagiEngine {
  private config: MagiConfig;
  private stateDir: string;

  constructor(config: MagiConfig) {
    this.config = config;
    this.stateDir = config.stateDirectory || '.magi';
  }

  async runIteration(agent: AgentAdapter, taskName: string): Promise<IterationResult> {
    const context: AgentContext = {
      cwd: process.cwd(),
      stateDir: path.join(process.cwd(), this.stateDir, taskName)
    };

    try {
      // 1. Ensure state directory exists
      await fs.mkdir(context.stateDir, { recursive: true });

      // 2. Read guardrails and progress
      const guardrails = await this.readStateFile(context.stateDir, 'guardrails.md', '# Guardrails\n- Stay on task.');
      const progress = await this.readStateFile(context.stateDir, 'progress.md', '# Progress\n- Starting...');

      // 3. Build prompt
      const prompt = this.buildPrompt(guardrails, progress);

      // 4. Invoke agent
      const result = await agent.invoke(prompt, context);

      // 5. Update state if successful
      if (result.success) {
        await this.writeStateFile(context.stateDir, 'activity.log', `[${new Date().toISOString()}] ${result.message}\n`, true);
        if (result.nextStep) {
          await this.writeStateFile(context.stateDir, 'progress.md', result.nextStep);
        }
      }

      return result;
    } catch (error) {
      return {
        success: false,
        message: `Iteration failed: ${(error as Error).message}`,
        error: error as Error
      };
    }
  }

  private buildPrompt(guardrails: string, progress: string): string {
    return `
${guardrails}

${progress}

Analyze the progress and provide the next step or solution.
`.trim();
  }

  private async readStateFile(dir: string, fileName: string, fallback: string): Promise<string> {
    try {
      return await fs.readFile(path.join(dir, fileName), 'utf8');
    } catch {
      return fallback;
    }
  }

  private async writeStateFile(dir: string, fileName: string, content: string, append = false): Promise<void> {
    const filePath = path.join(dir, fileName);
    if (append) {
      await fs.appendFile(filePath, content);
    } else {
      await fs.writeFile(filePath, content);
    }
  }

  getStateDir(): string {
    return this.stateDir;
  }
}
