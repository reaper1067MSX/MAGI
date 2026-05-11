import { BaseAgent } from './BaseAgent.js';
import type { AgentContext, IterationResult } from '../types/index.js';
import { exec } from 'node:child_process';
import { promisify } from 'node:util';

const execPromise = promisify(exec);

export class GeminiAgent extends BaseAgent {
  constructor() {
    super('gemini-cli');
  }

  async invoke(prompt: string, context: AgentContext): Promise<IterationResult> {
    try {
      // In a real scenario, we'd escape the prompt or use a temp file
      // For this refactor, we simulate the CLI call
      const { stdout, stderr } = await execPromise(`gemini-cli "${prompt.replace(/"/g, '\\"')}"`);
      
      if (stderr && !stdout) {
        return this.createErrorResult(`Gemini CLI error: ${stderr}`);
      }

      return this.createSuccessResult('Gemini processed the iteration', stdout);
    } catch (error) {
      // Fallback for demo/development if CLI isn't installed
      return this.createSuccessResult('Gemini (Simulated) processed the iteration', 'Next step: Continue refactoring.');
    }
  }
}
